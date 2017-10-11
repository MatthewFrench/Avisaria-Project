//
//  Player.m
//  Move Server
//
//  Created by Matthew French on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player
@synthesize position,leftArrow,rightArrow,upArrow,downArrow,moveCount,username,layer,textLayer,velocity;
- (id)init {
	NSLog(@"Player Init");
	position = CGPointMake(9, 11);
	leftArrow = FALSE;
	rightArrow = FALSE;
	upArrow = FALSE;
	downArrow = FALSE;
	moveCount = FALSE;
	username = [NSString new];
	layer = [CALayer layer];
	[layer retain];
	textLayer = [CATextLayer layer];
	[textLayer retain];
	return self;
}
- (void) dealloc {
	NSLog(@"Player Dealloc");
	[username release];
	[layer removeFromSuperlayer];
	[layer release];
	[textLayer removeFromSuperlayer];
	[textLayer release];
	[super dealloc];
}
@end
