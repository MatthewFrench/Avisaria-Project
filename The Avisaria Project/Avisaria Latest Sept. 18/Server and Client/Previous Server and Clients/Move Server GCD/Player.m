//
//  Player.m
//  Move Server
//
//  Created by Matthew French on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player
@synthesize position,leftArrow,rightArrow,upArrow,downArrow,moveCount,username;
- (id)init {
	position = CGPointMake(0,0);
	leftArrow = FALSE;
	rightArrow = FALSE;
	upArrow = FALSE;
	downArrow = FALSE;
	moveCount = FALSE;
	username = [NSString new];
	return self;
}
- (void)dealloc {
	[username release];
	[super dealloc];
}
@end
