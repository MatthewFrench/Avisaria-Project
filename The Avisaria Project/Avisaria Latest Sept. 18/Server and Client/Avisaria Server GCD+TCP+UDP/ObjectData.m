#import "ObjectData.h"

@implementation ObjectData
@synthesize tile,attributes,name,anchorPoint;
- (id)init 
{
	attributes = [NSMutableArray new];
	anchorPoint = CGPointMake(0.5, 0.5);
	tile = 0;
	name = @"";
	[name retain];
	return self;
}
-(BOOL)containsAttribute:(int)attribute {
	if ([attributes count] > 0) {
		for (int i = 0; i < [attributes count]; i ++) {
			if ([[attributes objectAtIndex:i] intValue] == attribute) {
				return TRUE;
			}
		}
	}
	return FALSE;
}
- (void) encodeWithCoder: (NSCoder *)coder
{   
	if (tile != 0) {
		[coder encodeObject: [NSNumber numberWithInt:tile] forKey:@"tile" ];
	}
	if (anchorPoint.x != 0) {
		[coder encodeObject: [NSNumber numberWithFloat:anchorPoint.x] forKey:@"anchorPoint.x" ];
	}
	if (anchorPoint.y != 0) {
		[coder encodeObject: [NSNumber numberWithFloat:anchorPoint.y] forKey:@"anchorPoint.y" ];
	}
	[coder encodeObject: attributes forKey:@"attributes" ];
	[coder encodeObject: name forKey:@"name" ];
} 
//init a player from a coder
- (id) initWithCoder: (NSCoder *) coder
{
    //[self init];
	if ([coder containsValueForKey:@"tile"]) {
		tile = [[coder decodeObjectForKey:@"tile"] intValue];
	}
	if ([coder containsValueForKey:@"anchorPoint.x"]) {
		anchorPoint.x = [[coder decodeObjectForKey:@"anchorPoint.x"] floatValue];
	}
	if ([coder containsValueForKey:@"anchorPoint.y"]) {
		anchorPoint.y = [[coder decodeObjectForKey:@"anchorPoint.y"] floatValue];
	}
	[attributes release];
	attributes = [coder decodeObjectForKey:@"attributes"];
	[attributes retain];
	[name release];
	name = [coder decodeObjectForKey:@"name"];
	[name retain];
    return self;
}

-(void)dealloc {
	[name release];
	[attributes release];
	[super dealloc];
}

@end
