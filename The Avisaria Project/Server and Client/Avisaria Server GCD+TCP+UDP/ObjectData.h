#import <Cocoa/Cocoa.h>
@class ObjectData;


@interface ObjectData : NSObject {
	NSMutableArray* attributes;
	int tile;
	CGPoint anchorPoint;
	NSString* name;
};
-(BOOL)containsAttribute:(int)attribute;
-(void) dealloc;

@property(nonatomic) int tile;
@property(nonatomic) CGPoint anchorPoint;
@property(nonatomic, retain) NSMutableArray* attributes;
@property(nonatomic, retain) NSString* name;

@end
