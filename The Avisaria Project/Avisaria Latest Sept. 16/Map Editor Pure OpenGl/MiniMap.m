#import "MiniMap.h"
#import "AppDelegate.h"

@implementation MiniMap
AppDelegate* delegate;

@synthesize updateScreen,tiles,maps,selectedMap,updateScreenBtn,selectedTile,teleport,saveImageBtn, updateWorld,
mapProgress, objects;


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
	delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	screenDimensions = CGPointMake([self bounds].size.width, [self bounds].size.height);
	updateScreen = TRUE;
	
	selectedTile = CGPointMake(-1, -1);
	
	[updateScreenBtn setTarget:self];
	[updateScreenBtn setAction:@selector(updateScreenBtn:)];
	
	[saveImageBtn setTarget:self];
	[saveImageBtn setAction:@selector(saveImageBtn:)];
	
	[mapProgress setUsesThreadedAnimation:TRUE];
	
	//***Turn on Game Timer
	gameTimer = [NSTimer scheduledTimerWithTimeInterval: 0.02
												 target: self
											   selector: @selector(handleGameTimer:)
											   userInfo: nil
												repeats: YES];
	
}

- (void)updateScreenBtn:(id)sender {
	[mapProgress startAnimation: self]; 
	updateScreen = TRUE;
	updateWorld = TRUE;
}
- (void)updateWorldImage {
	maps = delegate.maps;
	objects = delegate.objects;
	tiles = delegate.tileImages;
	selectedMap = [delegate.mapTableView selectedRow];
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	MapData* map = [maps objectAtIndex:selectedMap];
	//Update the resize
	int xmaporigin =  (map.xStart - map.yEnd) * 88/2;
	int ymaporigin =  (map.xStart + map.yStart) * 88/2;
	int xmapwidth =  (map.xEnd - map.yStart + 2) * 88/2 - xmaporigin;
	int ymapwidth =  (map.xEnd + map.yEnd + 2) * 88/2 - ymaporigin;
	float xworldresize = 1000.0/xmapwidth;
	float yworldresize = 1000.0/ymapwidth;
	if (worldImage != nil) {[worldImage release]; worldImage = nil;}
	worldImage = [[NSImage alloc] initWithSize:NSMakeSize(1000, 1000)];
	[worldImage lockFocus];
	[mapProgress setMaxValue:(map.xEnd-map.xStart)*(map.yEnd-map.yStart)*3];
	NSMutableArray* miniTiles = [[NSMutableArray alloc] initWithArray:tiles copyItems:YES];
	for (int t = 0; t < [miniTiles count];t++) {
		NSImage* tile = [miniTiles objectAtIndex:t];
		[tile setSize:NSMakeSize([tile size].width*xworldresize, [tile size].height*yworldresize)];
		[tile setFlipped:YES];
	}
	for (int l = 0; l < 3;l++) {
		for (int x = map.xStart; x <= map.xEnd; x ++) {
			for (int y = map.yStart; y <= map.yEnd; y ++) {
				//unsigned char * tile = [self staticallyGetTileAt:CGPointMake(x, y)];
				int xpos =  (x - y) * 88/2 - xmaporigin;
				int ypos =  (x + y) * 88/2 - ymaporigin;
				if (map.tiles[x-map.xStart][y-map.yStart][l] != -1) {
					ObjectData* object = [objects objectAtIndex:map.tiles[x-map.xStart][y-map.yStart][l]];
						NSImage* drawtile = [miniTiles objectAtIndex:object.tile];
						NSRect imageRect = NSMakeRect(0,0,[drawtile size].width, [drawtile size].height);
						[drawtile drawAtPoint:NSMakePoint((float)(xpos)*xworldresize,(float)(ypos)*yworldresize) 
									 fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0 ];
					}
				[mapProgress incrementBy:1];
				[mapProgress display];
			}
		}
	}
	[miniTiles release];
	[worldImage unlockFocus];
	updateWorld = FALSE;
	[mapProgress setDoubleValue:0];
	[mapProgress stopAnimation: self]; 
	updateScreen = TRUE;
	[pool release];
}
- (void)saveImageBtn:(id)sender {
	[self lockFocus];
	
	NSBitmapImageRep *bits;
	bits = [[NSBitmapImageRep alloc]
			initWithFocusedViewRect: [self bounds]];
	[self unlockFocus];	//Get path of app
	NSArray* splitPath = [[[NSBundle mainBundle] bundlePath] componentsSeparatedByString:@"/"];
	NSString* path = @"";
	for (int i = 0; i < [splitPath count]-1; i ++) {
		path = [NSString stringWithFormat:@"%@/%@",path,[splitPath objectAtIndex:i]];
	}
	path = [NSString stringWithFormat:@"%@/%@",path,@"World Image.png"];
	
	//create a NSBitmapImageRep
	//NSBitmapImageRep *bmpImageRep = [[NSBitmapImageRep alloc]initWithData:[saveImage TIFFRepresentation]];
	//add the NSBitmapImage to the representation list of the target
	NSImage* saveImage = [[NSImage alloc] initWithSize:self.bounds.size];
	[saveImage addRepresentation:bits];
	
	//get the data from the representation
	NSData *data = [bits representationUsingType: NSPNGFileType
											 properties: nil];
	
	//write the data to a file
	[data writeToFile: path
		   atomically: NO];
	[bits release];
	[saveImage release];
}

- (void) handleGameTimer: (NSTimer *) gameTimer {
	//All game logic goes here, this is updated 60 times a second
	if (updateWorld) {
		updateWorld = FALSE;
		[NSThread detachNewThreadSelector:@selector(updateWorldImage) toTarget:self withObject:nil];
	}
	if (updateScreen || updateWorld) {
		//This updates the screen
		[self setNeedsDisplay:YES];
	}
}
- (void)viewDidEndLiveResize:(NSEvent*)theEvent {
	screenDimensions = CGPointMake([self bounds].size.width, [self bounds].size.height);
	updateScreen = TRUE;
}
- (void)NSViewFrameDidChangeNotification:(NSNotification*)theNotification {
	screenDimensions = CGPointMake([self bounds].size.width, [self bounds].size.height);
	updateScreen = TRUE;
}
- (void)mouseDown:(NSEvent*)theEvent{
	MapData* map = [maps objectAtIndex:selectedMap];
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	float scrollX =  (map.xStart - map.yEnd) * 88/2;
	float scrollY =  (map.xStart + map.yStart) * 88/2;
	
	selectedTile = CGPointMake(
								floor( (((aMousePoint.x/xresize + scrollX)*2/88)+((aMousePoint.y/yresize + scrollY)*2/88))/2 -0.5),
							   floor( (((aMousePoint.x/xresize + scrollX)*2/88)-((aMousePoint.y/yresize + scrollY)*2/88))/-2 +0.5) );
	
	delegate.playerPosition = selectedTile;
	
	teleport = TRUE;
	[self setNeedsDisplay:YES];
}
- (BOOL)acceptsFirstResponder {
	return YES;
}
- (void)drawRect:(NSRect)theRect {
	
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	MapData* map = [maps objectAtIndex:selectedMap];
	//Update the resize
	int xmaporigin =  (map.xStart - map.yEnd) * 88/2;
	int ymaporigin =  (map.xStart + map.yStart) * 88/2;
	int xmapwidth =  (map.xEnd - map.yStart + 2) * 88/2 - xmaporigin;
	int ymapwidth =  (map.xEnd + map.yEnd + 2) * 88/2 - ymaporigin;
	xresize = [self bounds].size.width/xmapwidth;
	yresize = [self bounds].size.height/ymapwidth;
	
	CGContextSaveGState(context);
	CGContextScaleCTM(context, [self bounds].size.width/[worldImage size].width , [self bounds].size.height/[worldImage size].height);
	[self drawImage:worldImage point:CGPointMake(0, 0) rotation:0.0];
	CGContextRestoreGState(context);

	float color[] = {1.0,0.0,0.0,1.0};
	float xpos =  (selectedTile.x - selectedTile.y) * 88/2;
	float ypos =  (selectedTile.x + selectedTile.y) * 88/2;
	float scrollX =  (map.xStart - map.yEnd) * 88/2;
	float scrollY =  (map.xStart + map.yStart) * 88/2;
	[self drawRectangle:CGPointMake((xpos-scrollX)*xresize, (ypos-scrollY)*yresize) widthheight:CGPointMake(88*xresize, 88*yresize) color:color filled:FALSE linesize:1.0];
	updateScreen = FALSE;
}

- (NSImage*)loadImage:(NSString *)name type:(NSString*)imageType {
	//printf("File Exists!");
	//NSBundle *bundle;
	//NSString *path;
	
	//bundle = [NSBundle bundleForClass: [self class]];
	//path = [bundle pathForResource: @"atomsymbol"  ofType: @"jpg"];
	//return [[NSImage alloc] initWithContentsOfFile: path];
	
	NSString* filePath = [[NSBundle mainBundle] pathForResource:name ofType:imageType];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (fileExists) {
		NSImage* imageFile = [[NSImage alloc] initWithContentsOfFile:filePath];
		return imageFile;
	} else {
		return nil;
	}
}
- (NSString*)loadText:(NSString *)name type:(NSString*)fileType  {
	NSString* filePath = [[NSBundle mainBundle] pathForResource:name ofType:fileType];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (fileExists) {
		NSString* txtFile = [[NSString alloc] initWithContentsOfFile:filePath];
		return txtFile;
	} else {
		return nil;
	}
}
- (void) drawImage:(NSImage*)sprite point:(CGPoint)point rotation:(float)rotation {
	// Grab the drawing context
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	// like Processing pushMatrix
	CGContextSaveGState(context);
	//CGContextTranslateCTM(context, translate.x, translate.y);
	// Uncomment to see the rotated square
	CGContextRotateCTM(context, rotation * M_PI / 180);
	
	//***DRAW THE IMAGE
	//[sprite drawAtPoint:point];
	
	NSRect imageRect = NSMakeRect(0,0,[sprite size].width, [sprite size].height);
	[sprite setFlipped:YES];
	[sprite drawAtPoint:NSMakePoint(point.x,point.y) fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0 ];
	
	//***END DRAW THE IMAGE
	// like Processing popMatrix
	CGContextRestoreGState(context);
}
- (void) drawLine:(CGPoint)point topoint:(CGPoint)topoint linesize:(float)linesize color:(float[])color {
	// Grab the drawing context
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	// like Processing pushMatrix
	CGContextSaveGState(context);
	//CGContextTranslateCTM(context, translate.x, translate.y);
	// Uncomment to see the rotated square
	//CGContextRotateCTM(context,rotation * M_PI / 180);
	//Set the width of the pen mark
	CGContextSetLineWidth(context, linesize);
	// Set red stroke
	CGContextSetRGBStrokeColor(context, color[0], color[1], color[2], color[3]);
	// Draw a line
	//Starting point
	CGContextMoveToPoint(context, point.x, point.y);
	//Ending point
	CGContextAddLineToPoint(context,topoint.x, topoint.y);
	//Draw it
	CGContextStrokePath(context);
	// like Processing popMatrix
	CGContextRestoreGState(context);
}
- (void) drawOval:(float[])color point:(CGPoint)point dimensions:(CGPoint)dimensions filled:(BOOL)filled linesize:(float)linesize {
	// Grab the drawing context
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	// like Processing pushMatrix
	CGContextSaveGState(context);
	//CGContextTranslateCTM(context, translate.x, translate.y);
	// Uncomment to see the rotated square
	//CGContextRotateCTM(context, rotation * M_PI / 180);
	if (filled) {
		// Set red Fill
		CGContextSetRGBFillColor(context, color[0], color[1], color[2], color[3]);
		// Draw a circle (filled)
		CGContextFillEllipseInRect(context, CGRectMake(point.x, point.y, dimensions.x, dimensions.y));
	}else{
		//Set the width of the pen mark
		CGContextSetLineWidth(context, linesize);
		// Set red Fill
		CGContextSetRGBStrokeColor(context, color[0], color[1], color[2], color[3]);
		// Draw a circle (filled)
		CGContextStrokeEllipseInRect(context, CGRectMake(point.x, point.y, dimensions.x, dimensions.y));
	}
	// like Processing popMatrix
	CGContextRestoreGState(context);
}
- (void) drawString:(NSString*)text point:(CGPoint)point font:(NSString*)font color:(float[])color size:(int)textSize {
	
	
	// Grab the drawing context
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	// like Processing pushMatrix
	CGContextSaveGState(context);
	//CGContextTranslateCTM(context, translate.x, translate.y);
	// Uncomment to see the rotated square
	//CGContextRotateCTM(context, rotation * M_PI / 180);
	//***DRAW THE Text
	//[text drawAtPoint:point withFont:textFont];
	
	
	
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	NSDictionary *textAttribs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:font size:textSize],
								 NSFontAttributeName, [NSColor     colorWithDeviceRed:color[0] green:color[1] blue:color[2] alpha:color[3]], NSForegroundColorAttributeName, nil];
	[text drawAtPoint: NSMakePoint(point.x, point.y) withAttributes:textAttribs];
	[paragraphStyle release];
	
	//***END DRAW THE IMAGE
	// like Processing popMatrix
	CGContextRestoreGState(context);
}
- (void) drawRectangle:(CGPoint)point widthheight:(CGPoint)widthheight color:(float[])color filled:(BOOL)filled linesize:(float)linesize {
	//Positions/Dimensions of rectangle
	CGRect theRect = CGRectMake(point.x, point.y, widthheight.x, widthheight.y);
	// Grab the drawing context
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	// like Processing pushMatrix
	CGContextSaveGState(context);
	//CGContextTranslateCTM(context, translate.x, translate.y);
	// Uncomment to see the rotated square
	if (filled) {
		// Set red stroke
		CGContextSetRGBFillColor(context, color[0], color[1], color[2], color[3]);
		// Draw a rect with a red stroke
		CGContextFillRect(context, theRect);
	}else{
		//Set the width of the pen mark
		CGContextSetLineWidth(context, linesize);
		// Set red stroke
		CGContextSetRGBStrokeColor(context, color[0], color[1], color[2], color[3]);
		// Draw a rect with a red stroke
		CGContextStrokeRect(context, theRect);
	}
	//CGContextStrokeRect(context, theRect);
	// like Processing popMatrix
	CGContextRestoreGState(context);
}
- (BOOL) saveFileAtApp:(NSString*)name object:(NSMutableArray*)object {
	// save the people array
	NSArray* splitPath = [[[NSBundle mainBundle] bundlePath] componentsSeparatedByString:@"/"];
	NSString* path = @"";
	for (int i = 0; i < [splitPath count]-1; i ++) {
		path = [NSString stringWithFormat:@"%@/%@",path,[splitPath objectAtIndex:i]];
	}
	path = [NSString stringWithFormat:@"%@/%@",path,name];
	BOOL saved=[NSKeyedArchiver archiveRootObject:object toFile:path];
	return saved;
}
- (NSMutableArray*) openFileAtApp:(NSString*)name {
	NSArray* splitPath = [[[NSBundle mainBundle] bundlePath] componentsSeparatedByString:@"/"];
	NSString* path = @"";
	for (int i = 0; i < [splitPath count]-1; i ++) {
		path = [NSString stringWithFormat:@"%@/%@",path,[splitPath objectAtIndex:i]];
	}
	path = [NSString stringWithFormat:@"%@/%@",path,name];
	NSMutableArray* openedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	[openedObject retain];
	return openedObject;
}
- (NSImage*)loadImageAtApp:(NSString *)name type:(NSString*)imageType {
	NSArray* splitPath = [[[NSBundle mainBundle] bundlePath] componentsSeparatedByString:@"/"];
	NSString* path = @"";
	for (int i = 0; i < [splitPath count]-1; i ++) {
		path = [NSString stringWithFormat:@"%@/%@",path,[splitPath objectAtIndex:i]];
	}
	path = [NSString stringWithFormat:@"%@/%@.%@",path,name,imageType];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	if (fileExists) {
		NSImage* imageFile = [[NSImage alloc] initWithContentsOfFile:path];
		return imageFile;
	} else {
		return nil;
	}
}


- (void) dealloc{
	//This is where you release global variables with a * in them
	//Just make a [variablename release];
	//Allows you to free memory and not kill the player's device
	[gameTimer release];
	[super dealloc];
}


@end
