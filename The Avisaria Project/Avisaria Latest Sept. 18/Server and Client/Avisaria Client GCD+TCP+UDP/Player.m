//
//  Player.m
//  Move Server
//
//  Created by Matthew French on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player
@synthesize position,moveCount,username,moveSpeed,animDir,usernameStr;
- (id)init {
	NSLog(@"Player Init");
	position = CGPointMake(10, 11);
	moveCount = 0;
	username = [NSString new];
	moveSpeed = 30;
	animDir = CGPointMake(0, 0);
	usernameStr = [GLString alloc];
	animDir = CGPointMake(0, 0);
	return self;
}
- (void) dealloc {
	NSLog(@"Player Dealloc");
	[username release];
	[usernameStr release];
	[super dealloc];
}
@end
