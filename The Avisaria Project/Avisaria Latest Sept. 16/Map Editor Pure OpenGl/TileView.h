#import <Cocoa/Cocoa.h>
#import <AppKit/Appkit.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface TileView : NSView {
	//Don't touch these variables unless you wish a slow and painful death.
	NSTimer *gameTimer;
	CGPoint screenDimensions;
	
	//Put your global game variables here, but don't set a value to them!!
	//This works: int test;
	//This doesn't: int test = 0;
	
	BOOL keysPressed[178];
	
	BOOL updateScreen;
	
	//TileView
	NSMutableArray* tiles;
	
	CGPoint mouseDown;
	float scroll;
	int selectedTile;
	CGPoint selectedTilePos;
	IBOutlet NSScroller* scroller;
	float porportion;
}
@property(nonatomic) int selectedTile;
@property(nonatomic, retain) NSMutableArray* tiles;
@property(nonatomic, retain) NSScroller* scroller;

-(void) setTile:(int)tile;

- (NSImage*) loadImage:(NSString*)name type:(NSString*)imageType;
- (NSString*) loadText:(NSString*)name type:(NSString*)fileType;
- (void) drawLine:(CGContextRef)context translate:(CGPoint)translate point:(CGPoint)point topoint:(CGPoint)topoint rotation:(float)rotation linesize:(float)linesize color:(float[])color;
- (void) drawImage:(CGContextRef)context translate:(CGPoint)translate image:(NSImage*)sprite point:(CGPoint)point rotation:(float)rotation;
- (void) drawOval:(CGContextRef)context translate:(CGPoint)translate color:(float[])color point:(CGPoint)point dimensions:(CGPoint)dimensions rotation:(float)rotation filled:(BOOL)filled linesize:(float)linesize;
- (void) drawString:(CGContextRef)context translate:(CGPoint)translate text:(NSString*)text point:(CGPoint)point rotation:(float)rotation font:(NSString*)font color:(float[])color size:(int)textSize;
- (void) drawRectangle:(CGContextRef)context translate:(CGPoint)translate point:(CGPoint)point widthheight:(CGPoint)widthheight color:(float[])color rotation:(float)rotation filled:(BOOL)filled linesize:(float)linesize;
- (NSMutableArray*) openFileInDocs:(NSString*)name;
- (BOOL) saveFileInDocs:(NSString*)name object:(NSMutableArray*)object;
- (void) deleteFileInDocs:(NSString*)name;
- (NSImage*)imageByCropping:(NSImage *)imageToCrop toRect:(CGRect)rect;
- (CGColorRef)createCGColor:(float[])rgba;

@end
