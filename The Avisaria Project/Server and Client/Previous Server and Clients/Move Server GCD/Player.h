//
//  Player.h
//  Move Server
//
//  Created by Matthew French on 12/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Player : NSObject {
	CGPoint position;
	BOOL leftArrow,rightArrow,upArrow,downArrow;
	int moveCount;
	NSString* username;
}
@property(nonatomic) CGPoint position;
@property(nonatomic) BOOL leftArrow,rightArrow,upArrow,downArrow;
@property(nonatomic) int moveCount;
@property(nonatomic,assign) NSString* username;

@end
