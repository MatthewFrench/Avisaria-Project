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
	CATextLayer *textLayer;
	CALayer* layer;
	CGPoint position,velocity;
	BOOL leftArrow,rightArrow,upArrow,downArrow;
	int moveCount;
	NSString* username;
}
@property(nonatomic) CGPoint position,velocity;
@property(nonatomic) BOOL leftArrow,rightArrow,upArrow,downArrow;
@property(nonatomic) int moveCount;
@property(nonatomic,assign) NSString* username;
@property(nonatomic,assign) CALayer* layer;
@property(nonatomic,assign) CATextLayer *textLayer;


- (void) dealloc;

@end
