#import "MapData.h"

@implementation MapData
@synthesize tiles, name,xStart,xEnd,yStart,yEnd;
#define numberOfLayers 4
#define LayerGround 0
#define LayerMask 1
#define LayerMask2 2
#define LayerFringe 3
- (id)init {
	name = @"New Map";
	[name retain];
	xStart = 0;
	yStart = 0;
	tiles = (signed short int***)malloc((xEnd-xStart+1)*sizeof(**tiles));
	
    for (int x=0; x<(xEnd-xStart+1) ; x++) {
		
        tiles[x] = (signed short int**)malloc((yEnd-yStart+1)*sizeof(*tiles));
		
        for (int y=0; y<(yEnd-yStart+1); y++) {
			
            tiles[x][y] = (signed short int*)malloc(numberOfLayers*sizeof(tiles));
			for (int l = 0;l<numberOfLayers;l++) {
				if (l == 0) {
					tiles[x][y][l] = 0;
				} else {
					tiles[x][y][l] = -1;
				}
			}
        }
	}
	return self;
}
- (signed short int*)dynamicallyGetTileAt:(CGPoint)position {
	if (position.x >= xStart && position.x <= xEnd && position.y >= yStart && position.y <= yEnd) {
		//Send tiledata if exists
		int x = position.x - xStart;
		int y = position.y - yStart;
		signed short int* allTiles = tiles[x][y];
		return allTiles;
	}
	//Need to expand array
	CGPoint newStart = CGPointMake(xStart, yStart);
	CGPoint newEnd = CGPointMake(xEnd, yEnd);
	if (position.x < xStart) {newStart.x = position.x;}
	if (position.y < yStart) {newStart.y = position.y;}
	if (position.x > xEnd) {newEnd.x = position.x;}
	if (position.y > yEnd) {newEnd.y = position.y;}
	signed short int*** expandedTiles = (signed short int***)malloc((newEnd.x-newStart.x+1)*sizeof(**expandedTiles));
	
    for (int x=0; x<(newEnd.x-newStart.x+1) ; x++) {
		
        expandedTiles[x] = (signed short int**)malloc((newEnd.y-newStart.y+1)*sizeof(*expandedTiles));
		
        for (int y=0; y<(newEnd.y-newStart.y+1); y++) {
			
            expandedTiles[x][y] = (signed short int*)malloc(numberOfLayers*sizeof(expandedTiles));
			for (int l = 0;l<numberOfLayers;l++) {
				CGPoint newPos = CGPointMake(x+newStart.x,y+newStart.y);
				
				if (newPos.x >= xStart && newPos.x <= xEnd && newPos.y >= yStart && newPos.y <= yEnd) {
					int oldPosX = newPos.x-xStart;
					int oldPosY = newPos.y-yStart;
					expandedTiles[x][y][l] = tiles[oldPosX][oldPosY][l];
				} else {
					if (l == 0) {
						expandedTiles[x][y][l] = 0;
					} else {
						expandedTiles[x][y][l] = -1;
					}
				}
			}
        }
	}
	for (int x = 0;x<(xEnd-xStart+1);x++){
		for (int y = 0;y<(yEnd-yStart+1);y++){
			free (tiles[x][y]);
		}
		free (tiles[x]);
	}
	tiles = expandedTiles;
	
	xStart = newStart.x;
	yStart = newStart.y;
	xEnd = newEnd.x;
	yEnd = newEnd.y;
	
	//Get tile
	int x = position.x - newStart.x;
	int y = position.y - newStart.y;
	
	return tiles[x][y];
}
- (signed short int*)staticallyGetTileAt:(CGPoint)position {
	signed short int * toReturn = (signed short int *)-1;
	if (position.x >= xStart && position.x <= xEnd && position.y >= yStart && position.y <= yEnd) {
		//Send tiledata if exists
		int x = position.x - xStart;
		int y = position.y - yStart;
		signed short int* allTiles = tiles[x][y];
		toReturn = allTiles;
	}
	return toReturn;
}
- (void) encodeWithCoder: (NSCoder *)coder{   
	// Save to file
	NSMutableData * pSaveData = [[NSMutableData alloc] init];
	[pSaveData appendBytes:&xStart length:sizeof(xStart)];
	[pSaveData appendBytes:&xEnd length:sizeof(xEnd)];
	[pSaveData appendBytes:&yStart length:sizeof(yStart)];
	[pSaveData appendBytes:&yEnd length:sizeof(yEnd)];
	int numOfLayers = numberOfLayers;
	[pSaveData appendBytes:&numOfLayers length:sizeof(numOfLayers)];
	for (int x = 0; x < (xEnd-xStart+1); x++) {
		for (int y = 0; y < (yEnd-yStart+1); y++) {
			for (int v = 0; v < numberOfLayers; v++) {
				[pSaveData appendBytes:&tiles[x][y][v] length:sizeof(tiles[x][y][v])];
			}
		}
	}
	[coder encodeObject:pSaveData forKey:@"tiles" ];
	[coder encodeObject: name forKey:@"name" ];
	[pSaveData autorelease];
} 
- (id) initWithCoder: (NSCoder *) coder{
    //[self init];
	NSMutableData * pReadData = [coder decodeObjectForKey:@"tiles" ];
	
	int dimensionsBuffer;
	[pReadData getBytes:&dimensionsBuffer range:NSMakeRange(0, sizeof(int))];
	 xStart = dimensionsBuffer;
	[pReadData getBytes:&dimensionsBuffer range:NSMakeRange(sizeof(int), sizeof(int))];
	 xEnd = dimensionsBuffer;
	[pReadData getBytes:&dimensionsBuffer range:NSMakeRange(sizeof(int)*2, sizeof(int))];
	 yStart = dimensionsBuffer;
	[pReadData getBytes:&dimensionsBuffer range:NSMakeRange(sizeof(int)*3, sizeof(int))];
	 yEnd = dimensionsBuffer;
	[pReadData getBytes:&dimensionsBuffer range:NSMakeRange(sizeof(int)*4, sizeof(int))];
	int numOfLayers = dimensionsBuffer;
	tiles = (signed short int***)malloc((xEnd-xStart+1)*sizeof(**tiles));
	signed short int dataBuffer;
    for (int x=0; x<(xEnd-xStart+1) ; x++) {
		
        tiles[x] = (signed short int**)malloc((yEnd-yStart+1)*sizeof(*tiles));
		
        for (int y=0; y<(yEnd-yStart+1); y++) {
			
            tiles[x][y] = (signed short int*)malloc(numOfLayers*sizeof(tiles));
			for (int l = 0; l < numOfLayers; l++) {
				[pReadData getBytes:&dataBuffer range:NSMakeRange(sizeof(int)*5 + ((x*(yEnd-yStart+1)+y)*numOfLayers+l)*sizeof(signed short int), sizeof(signed short int))];
				tiles[x][y][l] = dataBuffer;
			}
        }
		
    }
	name = [coder decodeObjectForKey:@"name" ];
	[name retain];
    return self;
}

-(void)dealloc {
	
	for (int x = 0;x<(xEnd-xStart+1);x++){
		for (int y = 0;y<(yEnd-yStart+1);y++){
			free (tiles[x][y]);
		}
		free (tiles[x]);
	}
	
	free (tiles);
	[name release];
	[super dealloc];
}
@end
