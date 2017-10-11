//
//  Player.h
//  Move Server
//
//  Created by Matthew French on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface Player : NSObject {
	CGPoint position,velocity;
	BOOL leftArrow,rightArrow,upArrow,downArrow, updateClient;
	int moveCount,updateCount;
	NSString* username;
	int udpID;
}
@property(nonatomic) CGPoint position,velocity;
@property(nonatomic) BOOL leftArrow,rightArrow,upArrow,downArrow,updateClient;
@property(nonatomic) int moveCount, updateCount,udpID;
@property(nonatomic,assign) NSString* username;

@end
