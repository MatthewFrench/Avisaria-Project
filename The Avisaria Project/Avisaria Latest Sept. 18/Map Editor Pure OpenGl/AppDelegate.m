#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window,objectPlatform,tileImages,playerImage,tileView, objectTableView, objectAttributeTableView
,attributesComboBox,objectTableView2,mapTableView,layerMatrix,drawMatrix,worldView,widthTxt,heightTxt,maps,objects,playerPosition;

#pragma mark Object Editor
- (void) prepareObjectEditor {
	// Get folder path that the app is in.
	NSArray* splitPath = [[[NSBundle mainBundle] bundlePath] componentsSeparatedByString:@"/"];
	applicationDirectory = @"";
	for (int i = 0; i < [splitPath count]-1; i ++) {
		applicationDirectory = [NSString stringWithFormat:@"%@/%@",applicationDirectory,[splitPath objectAtIndex:i]];
	}
	[applicationDirectory retain];
	
	tileImages = [NSMutableArray new];
	
	//Load tiles
	for (int i = 1; i > 0; i ++) {
		NSString* filePath = [NSString stringWithFormat:@"%@/tiles/%d.png",applicationDirectory,i];
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
		if (fileExists) {
			NSImage* imageFile = [[NSImage alloc] initWithContentsOfFile:filePath];
			[tileImages addObject:imageFile];
			[imageFile release];
		} else {
			i = -1;
		}
	}
	tileView.tiles = tileImages;
	
	playerImage = [NSImage imageNamed:@"player.png"];
	[playerImage retain];
	
	if (!objects) {
		objects = [NSMutableArray new];
		[self addObject:nil];
	}
	
	objectLayer = [CALayer layer];
	[objectLayer retain];
	//player.contents = playerImage;
	//[player setFrame:CGRectMake(0, 0, playerImage.size.width, playerImage.size.height)];
	//[player setPosition:CGPointMake(worldView.bounds.size.width/2.0, worldView.bounds.size.height/2.0)];
	[objectPlatform.rootLayer addSublayer:objectLayer];
	
	anchorImage = [NSImage imageNamed:@"Anchor.png"];
	[anchorImage retain];
	anchorLayer = [CALayer layer];
	[anchorLayer retain];
	anchorLayer.contents = anchorImage;
	[anchorLayer setFrame:CGRectMake(0, 0, anchorImage.size.width, anchorImage.size.height)];
	[anchorLayer setPosition:CGPointMake(objectPlatform.bounds.size.width/2.0, objectPlatform.bounds.size.height/2.0)];
	[objectLayer addSublayer:anchorLayer];
	[attributesComboBox selectItemAtIndex:0];
	
	[objectTableView2 reloadData];
}
- (IBAction) addObject:(id)sender {
	ObjectData* newObject = [[ObjectData alloc] init];
	newObject.name = @"New Object";
	newObject.anchorPoint = CGPointMake(0.5, 0.5);
	[objects addObject:newObject];
	[objectTableView reloadData];
	[objectAttributeTableView reloadData];
	[self updateObjectPlayerform];
}
- (IBAction) addObjectAttribute:(id)sender {
	if ([objectTableView selectedRow] > -1) {
		ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
		int addAttribute = [attributesComboBox indexOfSelectedItem];
		BOOL addIt = TRUE;
		for (int i = 0; i < [object.attributes count];i++) {
			if ([[object.attributes objectAtIndex:i] intValue] == addAttribute) {
				addIt = FALSE;
			}
		}
		if (addIt) {
			[object.attributes addObject:[NSNumber numberWithInt:addAttribute]];
			[objectAttributeTableView reloadData];
		}
	}
}
- (IBAction) deleteObjectAttribute:(id)sender {
	if ([objectTableView selectedRow] > -1) {
		ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
		if ([objectAttributeTableView selectedRow] > -1) {
			[object.attributes removeObjectAtIndex:[objectAttributeTableView selectedRow]];
			[objectAttributeTableView reloadData];
		}
	}
}
- (IBAction) setObjectTile:(id)sender {
	if ([objectTableView selectedRow] > -1) {
		ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
		object.tile = [tileView selectedTile];
		[self updateObjectPlayerform];
		[objectAttributeTableView reloadData];
	}
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	if (tableView == objectTableView || tableView == objectTableView2) {
		ObjectData* object = [objects objectAtIndex:row];
		[self updateObjectPlayerform];
		return object.name;
	} else if (tableView == objectAttributeTableView) {
		ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
		return [object.attributes objectAtIndex:row];
	} else if (tableView == mapTableView) {
		MapData* map = [maps objectAtIndex:row];
		return map.name;
	}
	return nil;
}
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == objectTableView || tableView == objectTableView2) {
        return [objects count];
	}
	if (tableView == objectAttributeTableView) {
		if ([objectTableView selectedRow] > -1) {
			ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
			return [object.attributes count];
		}
	}
	if (tableView == mapTableView) {
        return [maps count];
	}
	return 0;
}
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	if (aTableView == objectTableView) {
		ObjectData* object = [objects objectAtIndex:rowIndex];
		object.name = anObject;
	}
	if (aTableView == mapTableView) {
		MapData* map = [maps objectAtIndex:rowIndex];
		map.name = anObject;
	}
}
- (IBAction)tableViewSelected:(id)sender {
    [self updateObjectPlayerform];
	[objectAttributeTableView reloadData];
}
- (void) updateObjectPlayerform {
	if ([objectTableView selectedRow] > -1) {
		ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
		if (object.tile > -1) {
			NSImage* tile = [tileImages objectAtIndex:object.tile];
			[tile setFlipped:NO];
			objectLayer.contents = tile;
			[objectLayer setFrame:CGRectMake(0, 0, tile.size.width, tile.size.height)];
			[objectLayer setPosition:CGPointMake(objectPlatform.bounds.size.width/2.0+0.5, objectPlatform.bounds.size.height/2.0)];
			[anchorLayer setPosition:CGPointMake(tile.size.width * object.anchorPoint.x, tile.size.height * object.anchorPoint.y)];
		}
	}
}
- (void)  setAnchorPoint:(CGPoint)pos {
	if ([objectTableView selectedRow] > -1) {
		ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
		if (object.tile > -1) {
			NSImage* tile = [tileImages objectAtIndex:object.tile];
			CGPoint newPoint = CGPointMake(objectPlatform.bounds.size.width/2.0 - tile.size.width/2.0, 
										   objectPlatform.bounds.size.height/2.0 - tile.size.height/2.0);
			if (pos.x >= newPoint.x && pos.x <= newPoint.x + tile.size.width &&
				pos.y >= newPoint.y && pos.y <= newPoint.y + tile.size.height) {
					[anchorLayer setPosition:CGPointMake(pos.x - newPoint.x, newPoint.y - pos.y + tile.size.height*1.0)];
				object.anchorPoint = CGPointMake((pos.x - newPoint.x)/tile.size.width, 
												 (newPoint.y - pos.y + tile.size.height*1.0)/tile.size.height);
			}
		}
	}
}
- (void) resetAnchorPoint {
	if ([objectTableView selectedRow] > -1) {
		ObjectData* object = [objects objectAtIndex:[objectTableView selectedRow]];
		if (object.tile > -1) {
			NSImage* tile = [tileImages objectAtIndex:object.tile];
				[anchorLayer setPosition:CGPointMake(tile.size.width/2.0, tile.size.height/2.0)];
				object.anchorPoint = CGPointMake(0.5, 0.5);
		}
	}
}

#pragma mark Map Editor
- (void) prepareMapEditor {
	if (!maps) {
		maps = [NSMutableArray new];
		[self newMap:nil];
	}
	[mapTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	playerPosition = CGPointMake(5, 5);
	moveSpeed = 0.25;
	
	gridStart = CGPointMake(-2, -2);
	gridEnd = CGPointMake(xtiles - 1, ytiles - 1);
	
	selectedTool = 2;
	
	player = [CALayer layer];
	[player retain];
	player.contents = playerImage;
	[player setFrame:CGRectMake(0, 0, playerImage.size.width, playerImage.size.height)];
	[player setPosition:CGPointMake(worldView.bounds.size.width/2.0, worldView.bounds.size.height/2.0)];
	//[worldView.rootLayer addSublayer:player];
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}
- (void)timerTick {
	CGPoint layerGridMove = CGPointMake(0.0, 0.0);
	if (moveCount == 0 && (leftArrow || rightArrow || upArrow || downArrow)) {
		moveCount = animSpeed-1.0;
		animDir = CGPointMake(0, 0);
		if (leftArrow) {
			layerGridMove.x = -1;
			layerGridMove.y = 1;
			animDir.x = 1;
		} else if (rightArrow) {
			layerGridMove.x = 1;
			layerGridMove.y = -1;
			animDir.x = -1;
		}
		if (downArrow) {
			layerGridMove.x = -1;
			layerGridMove.y = -1;
			animDir.y = -1;
			if (leftArrow) {layerGridMove.y = 0;animDir.x /=2.0;animDir.y /=2.0;}
			if (rightArrow) {layerGridMove.x = 0;animDir.x /=2.0;animDir.y /=2.0;}
		} else if (upArrow) {
			layerGridMove.x = 1;
			layerGridMove.y = 1;
			animDir.y = 1;
			if (leftArrow) {layerGridMove.x = 0;animDir.x /=2.0;animDir.y /=2.0;}
			if (rightArrow) {layerGridMove.y = 0;animDir.x /=2.0;animDir.y /=2.0;}
		}
		//Determine if can move
		BOOL move = TRUE;
		if ([mapTableView selectedRow] > -1) {
			MapData* map = [maps objectAtIndex:[mapTableView selectedRow]];
			signed short int* tile = [map staticallyGetTileAt:CGPointMake(playerPosition.x+layerGridMove.x, playerPosition.y+layerGridMove.y)];
			if (tile != (signed short int *)-1) {
				for (int z = 0; z < layers; z ++) {
					if (tile[z] > -1) {
						ObjectData* object = [objects objectAtIndex:tile[z]];
						if ([object containsAttribute:0]) {
							move = FALSE;
						}
					}
				}
			}
		}
		if (!move) {
			moveCount = 0;
			animDir = CGPointMake(0, 0);
		} else {
			playerPosition.x += layerGridMove.x;
			playerPosition.y += layerGridMove.y;
		}
	} else {
		if (moveCount != 0) {
			moveCount -= 1;
		}
	}
	[self drawMap];
}
- (void)setUpOpenGl:(CGPoint)size {
	[[worldView openGLContext] makeCurrentContext];
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint swapInt = 1;
	[[worldView openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
	//glEnable(GL_DEPTH_TEST);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	CGLLockContext([[worldView openGLContext] CGLContextObj]);
	
	// Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho( size.x/2, -size.x/2, -size.y / 2, size.y / 2, -1, 1 );
	glMatrixMode(GL_MODELVIEW);
	glViewport(0, 0, -size.x, -size.y);
	glTranslatef(0.0f+size.x / 2, 0.0f+size.y / 2, 0.0f );
	glRotatef(180.0f, 0.0f, 0.0f, 1.0f);
	//glScalef(1.0, -1.0, 1.0);
	
	
	// Initialize OpenGL states
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
	glEnableClientState(GL_VERTEX_ARRAY);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	
	glShadeModel(GL_SMOOTH);
	
	GLint zeroOpacity = 0;
	[[worldView openGLContext] setValues:&zeroOpacity forParameter:NSOpenGLCPSurfaceOpacity];
	
	CGLUnlockContext([[worldView openGLContext] CGLContextObj]);
	
	//Load textures
	tileTextures = [NSMutableArray new];
	for (int i = 0; i < [tileImages count]; i ++) {
		Texture* newTex = [Texture new];
		[newTex initWithImage:[tileImages objectAtIndex:i]];
		[tileTextures addObject:newTex];
		[newTex release];
	}
	playerTexture = [Texture new];
	[playerTexture initWithImage:playerImage];
}
- (void)drawMap {
	[[worldView openGLContext] makeCurrentContext];
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// get ready for texture rendering
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	for (int z = 0; z < layers; z ++) {
		if (z == selectedLayer && selectedTool == 0) {
			glColor4f(1.0f,0.4f,0.4f,0.9f);
		} else {
			glColor4f(1.0f,1.0f,1.0f,1.0f);
		}
		for (int x = gridEnd.x; x > gridStart.x; x -=1) {
			for (int y = gridEnd.y; y > gridStart.y; y -=1) {
				MapData* map = [maps objectAtIndex:[mapTableView selectedRow]];
				//NSLog(@"tile: %d and %d vs Player: %d and %d",(int)(x-9+playerPosition.x),(int)(y-9+playerPosition.y),(int)(playerPosition.x),(int)(playerPosition.y));
				signed short int * tile = [map staticallyGetTileAt:CGPointMake(x-10+playerPosition.x, y-10+playerPosition.y)];
				if (tile != (signed short int *)-1 && tile[z] > -1) {
					ObjectData* object = [objects objectAtIndex:tile[z]];
					//tileLayer.anchorPoint = object.anchorPoint;
					float xpos =  (x - y) * (tileSize/2) + screenWidth;
					float ypos =  (-x - y) * (tileSize/2) + screenHeight + yOffset*tileSize;
					NSImage* tileImage = [tileImages objectAtIndex:object.tile];
					CGPoint drawPos = CGPointMake(
												  floor(xpos-(tileImage.size.width*(object.anchorPoint.x))/*+(tileSize))*/ - (animDir.x*moveCount/animSpeed*tileSize)), 
												  floor(ypos-(tileImage.size.height*(1.0-object.anchorPoint.y))/*+(tileSize))*/-10 - (animDir.y*moveCount/animSpeed*tileSize))
												  );
					//CGPoint drawPos = CGPointMake(round(xpos)+0.5, round(ypos));
					[[tileTextures objectAtIndex:object.tile] drawAt:drawPos];
				}
				if (x-9+playerPosition.x-1 == playerPosition.x && y-9+playerPosition.y-1 == playerPosition.y && z == 2) {
					[playerTexture drawAt:CGPointMake(round(screenWidth-playerImage.size.width/2.0), round(screenHeight-playerImage.size.height/2.0))];
				}
			}
		}
	}
	
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	
	glFlush();

}
/**
- (void)updateAllTiles:(CGPoint)layerGridMove {
	//Update Tile Position
	[CATransaction begin];
	[CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
	for (int x = 0; x < xtiles; x ++) {
		for (int y = 0; y < ytiles; y ++) {
			//NSLog(@"%d vs %d",i,(x)*ytiles + y+1);
			tilePositions[x][y].x += layerGridMove.x;
			tilePositions[x][y].y += layerGridMove.y;
			BOOL reorient = FALSE;
			if (tilePositions[x][y].x < gridStart.x) {tilePositions[x][y].x = gridEnd.x; reorient = TRUE;}
			if (tilePositions[x][y].x > gridEnd.x) {tilePositions[x][y].x = gridStart.x; reorient = TRUE;}
			if (tilePositions[x][y].y < gridStart.y) {tilePositions[x][y].y = gridEnd.y; reorient = TRUE;}
			if (tilePositions[x][y].y > gridEnd.y) {tilePositions[x][y].y = gridStart.y; reorient = TRUE;}
			for (int z = 0; z < layers; z ++) {
				//NSLog(@"%d vs %d",i, (z+1)+y*layers+x*xtiles*layers);
				if (reorient) {
					[worldLayers[z] insertSublayer:tiles[x][y][z] atIndex:(x)*xtiles + y+1];
					[self updateTileX:x Y:y Z:z];
				}
			}
		}
	}
	//Update player's layers position
	int playerIndex = (playerPosition.x+5)*xtiles + (playerPosition.y+5)+2;
	[worldLayers[2] insertSublayer:player atIndex:playerIndex];
	[CATransaction commit];
}
 **/
- (void)keydown:(UniChar)key {
	if (key == NSLeftArrowFunctionKey) {
		leftArrow = TRUE;
	}
	if (key == NSRightArrowFunctionKey) {
		rightArrow = TRUE;
	}
	if (key == NSUpArrowFunctionKey) {
		upArrow = TRUE;
	}
	if (key == NSDownArrowFunctionKey) {
		downArrow = TRUE;
	}
}
- (void)keyup:(UniChar)key {
	if (key == NSLeftArrowFunctionKey) {
		leftArrow = FALSE;
	}
	if (key == NSRightArrowFunctionKey) {
		rightArrow = FALSE;
	}
	if (key == NSUpArrowFunctionKey) {
		upArrow = FALSE;
	}
	if (key == NSDownArrowFunctionKey) {
		downArrow = FALSE;
	}
}
- (void)mouseDown:(CGPoint)point {
	[self drawTileAt:point];
}
- (void)mouseDragged:(CGPoint)point {
	[self drawTileAt:point];
}
- (void)mouseUp:(CGPoint)point {
}
- (IBAction)newMap:(id)sender {
	//Fill empty map
	MapData* map = [MapData alloc];
	map.xEnd = 10;
	map.yEnd = 10;
	[map init];
	[maps addObject:map];
	[map release];
	[mapTableView reloadData];
	[widthTxt setStringValue:[NSString stringWithFormat:@"%d",map.xEnd-map.xStart]];
	[heightTxt setStringValue:[NSString stringWithFormat:@"%d",map.yEnd-map.yStart]];
}
- (IBAction)deleteMap:(id)sender {
	if ([mapTableView selectedRow] > -1 && [maps count] > 1) {
		[maps removeObjectAtIndex:[mapTableView selectedRow]];
		[mapTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		[mapTableView reloadData];
		[mapTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	}
}
- (IBAction)saveWorld:(id)sender {
	NSMutableDictionary* toSave = [[NSMutableDictionary alloc] init];
	[toSave setObject:maps forKey:@"maps"];
	[toSave setObject:objects forKey:@"objects"];
	[self saveFileAtApp:@"World Data.ganrocks" object:toSave];
	[toSave release];
}
- (IBAction)openMiniMap:(id)sender {
	[miniMap setIsVisible:TRUE];
}
- (IBAction)mapTableViewSelected:(id)sender {
	if ([mapTableView selectedRow] > -1 && [mapTableView selectedRow] < [maps count]) {
		MapData* map = [maps objectAtIndex:[mapTableView selectedRow]];
		[widthTxt setStringValue:[NSString stringWithFormat:@"%d",map.xEnd-map.xStart]];
		[heightTxt setStringValue:[NSString stringWithFormat:@"%d",map.yEnd-map.yStart]];
	} else {
		[mapTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];	
	}
}
/**
- (void) updateTileX:(int)x Y:(int)y Z:(int)z {
	CALayer* tileLayer = tiles[x][y][z];
	if ([mapTableView selectedRow]>-1) {
		MapData* map = [maps objectAtIndex:[mapTableView selectedRow]];
		signed short int * tile = [map staticallyGetTileAt:CGPointMake(tilePositions[x][y].x-9+playerPosition.x, tilePositions[x][y].y-9+playerPosition.y)];
		if (tile != (signed short int *)-1 && tile[z] > -1) {
			ObjectData* object = [objects objectAtIndex:tile[z]];
			tileLayer.anchorPoint = object.anchorPoint;
			float xpos =  (tilePositions[x][y].x - tilePositions[x][y].y) * (tileSize/2) + screenWidth;
			float ypos =  (-tilePositions[x][y].x - tilePositions[x][y].y) * (tileSize/2) + screenHeight + yOffset*tileSize;
			[tileLayer setPosition:CGPointMake(round(xpos)+0.5+worldLayers[z].bounds.origin.x, round(ypos)+worldLayers[z].bounds.origin.y)];
			if (object.tile > -1) {
				NSImage* tileImage = [tileImages objectAtIndex:object.tile];
				tileLayer.bounds = CGRectMake(0, 0, tileImage.size.width, tileImage.size.height);
				tileLayer.contents = [tileImages objectAtIndex:object.tile];
			}
		} else {
			float xpos =  (tilePositions[x][y].x - tilePositions[x][y].y) * (tileSize/2) + screenWidth;
			float ypos =  (-tilePositions[x][y].x - tilePositions[x][y].y) * (tileSize/2) + screenHeight + yOffset*tileSize;
			tileLayer.bounds = CGRectMake(0, 0, tileSize, tileSize+1);
			[tileLayer setPosition:CGPointMake(round(xpos)+0.5+worldLayers[z].bounds.origin.x, round(ypos)+worldLayers[z].bounds.origin.y)];
			tileLayer.contents = nil;
		}
	}
}
**/
- (void)drawTileAt:(CGPoint)point {
	CGPoint selectedTile = CGPointMake(
									   floor( (((point.x)*2/(tileSize))+((point.y)*2/(tileSize)))/2) + playerPosition.x - 8-1,
									   floor( (((point.x)*2/(tileSize))-((point.y)*2/(tileSize)))/-2) + playerPosition.y + 2-1
									   );
	MapData* map = [maps objectAtIndex:[mapTableView selectedRow]];
	if (selectedTool == 2 && [objectTableView2 selectedRow] > -1) {
		signed short int* tile = [map dynamicallyGetTileAt:selectedTile];
		tile[selectedLayer] = [objectTableView2 selectedRow];
	} else if (selectedTool == 0) {
		signed short int* tile = [map dynamicallyGetTileAt:selectedTile];
		tile[selectedLayer] = -1;
	} else if (selectedTool == 1 && [objectTableView2 selectedRow] > -1) {
		//Fill Tool
		signed short int* tile = [map dynamicallyGetTileAt:selectedTile];
		int layer = selectedLayer;
		int findFillColor = tile[layer];
		unsigned short int** fillArray = (unsigned short int**)malloc((map.xEnd-map.xStart+1)*sizeof(*fillArray));
		
		for (int x=0; x<(map.xEnd-map.xStart+1) ; x++) {
			
			fillArray[x] = (unsigned short int*)malloc((map.yEnd-map.yStart+1)*sizeof(fillArray));
			
			for (int y=0; y<(map.yEnd-map.yStart+1); y++) {
				
				fillArray[x][y] = 0;
				if (map.tiles[x][y][layer] == findFillColor) {
					fillArray[x][y] = 1;
				}
			}
		}
		
		fillArray[(int)(selectedTile.x-map.xStart)][(int)(selectedTile.y-map.yStart)] = 2;
		int i = 0;
		//Go through array and change 1s to 2s if they touch
		while (i == 0) {
			i = 1;
			for (int x = 0; x<(map.xEnd-map.xStart+1);x++) {
				for (int y = 0; y<(map.yEnd-map.yStart+1);y++) {
					if (fillArray[x][y] == 1) {
						if (x != 0) {
							if (fillArray[x-1][y] == 2) {
								fillArray[x][y] = 2;
								i = 0;
							}
						}
						if (x != map.xEnd-map.xStart) {
							if (fillArray[x+1][y] == 2) {
								fillArray[x][y] = 2;
								i = 0;
							}
						}
						if (y != 0) {
							if (fillArray[x][y-1] == 2) {
								fillArray[x][y] = 2;
								i = 0;
							}
						}
						if (y != map.yEnd-map.yStart) {
							if (fillArray[x][y+1] == 2) {
								fillArray[x][y] = 2;
								i = 0;
							}
						}
					}
				}
				
			}
			
		}
		//Fill all colors that are 2
		for (int x = 0; x<map.xEnd-map.xStart+1;x++) {
			for (int y = 0; y<map.yEnd-map.yStart+1;y++) {
				if (fillArray[x][y] == 2) {
					map.tiles[x][y][layer] = [objectTableView2 selectedRow];
				}
				
			}
		}
		//Now free the stack array
		for (int x = 0;x<(map.xEnd-map.xStart+1);x++){
			free (fillArray[x]);
		}
		
		free (fillArray);
		
	}
	[widthTxt setStringValue:[NSString stringWithFormat:@"%d",map.xEnd-map.xStart]];
	[heightTxt setStringValue:[NSString stringWithFormat:@"%d",map.yEnd-map.yStart]];
}
- (IBAction)layerMatrixClick:(NSMatrix*)sender {
	selectedLayer = [sender selectedColumn];
}
- (IBAction)drawMatrixClick:(NSMatrix*)sender {
	selectedTool = [sender selectedColumn];
}

#pragma mark Application
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSMutableDictionary* dictionary = (NSMutableDictionary*)[self openFileAtApp:@"World Data.ganrocks"];
	if (dictionary) {
		if ([dictionary objectForKey:@"maps"]) {
			maps = [dictionary objectForKey:@"maps"];
			[maps retain];
			[mapTableView reloadData];
		}
		if ([dictionary objectForKey:@"objects"]) {
			objects = [dictionary objectForKey:@"objects"];
			[objects retain];
			[objectTableView reloadData];
		}
		[dictionary release];
	}
	[self prepareObjectEditor];
	[self prepareMapEditor];
	[self setUpOpenGl:CGPointMake(worldView.bounds.size.width, worldView.bounds.size.height)];
	[mapTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}
- (void) dealloc {
	[timer invalidate];
	[playerImage release];
	/**
	for (int x = 0; x < xtiles; x ++) {
		for (int y = 0; y < ytiles; y ++) {
			for (int z = 0; z < layers; z ++) {
				[tiles[x][y][z] release];
			}
		}
	}
	 **/
	[maps removeAllObjects];
	[maps release];
	[applicationDirectory release];
	[tileImages removeAllObjects];
	[tileImages release];
	[player release];
	[objects removeAllObjects];
	[objects release];
	[super dealloc];
}

- (BOOL) saveFileAtApp:(NSString*)name object:(NSObject*)object {
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
- (NSObject*) openFileAtApp:(NSString*)name {
	NSArray* splitPath = [[[NSBundle mainBundle] bundlePath] componentsSeparatedByString:@"/"];
	NSString* path = @"";
	for (int i = 0; i < [splitPath count]-1; i ++) {
		path = [NSString stringWithFormat:@"%@/%@",path,[splitPath objectAtIndex:i]];
	}
	path = [NSString stringWithFormat:@"%@/%@",path,name];
	NSObject* openedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	[openedObject retain];
	return openedObject;
}
@end
