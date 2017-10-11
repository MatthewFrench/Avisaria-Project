//
//  Player.h
//  Move Server
//
//  Created by Matthew French on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "GLString.h"

@interface Player : NSObject {
	CGPoint position,animDir;
	int moveCount,moveSpeed;
	NSString* username;
	GLString* usernameStr;
}
@property(nonatomic) CGPoint position,animDir;
@property(nonatomic) int moveCount,moveSpeed;
@property(nonatomic,assign) NSString* username;
@property(nonatomic,assign) GLString* usernameStr;


- (void) dealloc;

@end
