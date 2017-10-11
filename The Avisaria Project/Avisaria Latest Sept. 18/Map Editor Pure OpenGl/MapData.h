#import <Cocoa/Cocoa.h>
#import <AppKit/Appkit.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
@class MapData;


@interface MapData : NSObject {
	signed short int*** tiles;
	NSString* name;
	int xStart,xEnd,yStart,yEnd;
};
- (signed short int*)dynamicallyGetTileAt:(CGPoint)position;
- (signed short int*)staticallyGetTileAt:(CGPoint)position;
-(void) dealloc;
@property(nonatomic) signed short int*** tiles;
@property(nonatomic, retain) NSString *name;
@property(nonatomic) int xStart,xEnd,yStart,yEnd;

@end