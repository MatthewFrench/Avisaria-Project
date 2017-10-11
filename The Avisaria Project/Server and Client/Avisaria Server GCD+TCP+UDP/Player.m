//
//  Player.m
//  Move Server
//
//  Created by Matthew French on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player
@synthesize position,leftArrow,rightArrow,upArrow,downArrow,moveCount,username,updateCount,udpID,updateClient
,animDir,moveSpeed;
- (id)init {
	position = CGPointMake(9, 11);
	leftArrow = FALSE;
	rightArrow = FALSE;
	upArrow = FALSE;
	downArrow = FALSE;
	moveCount = 0;
	username = [NSString new];
	updateCount = 0;
	udpID = 0;
	updateClient = FALSE;
	moveSpeed = 30;
	animDir = CGPointMake(0, 0);
	
	return self;
}
- (void) dealloc {
	[username release];
	[super dealloc];
}
@end
