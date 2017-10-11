//
//  WorldView.m
//  Simple ORPG Client
//
//  Created by Matthew French on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorldView.h"
#import "AppDelegate.h"
AppDelegate* delegate;

@implementation WorldView
@synthesize rootLayer;

- (void)awakeFromNib {
	delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	rootLayer = [CALayer layer];
	[rootLayer retain];
	
	[self setLayer: rootLayer];
	[self setWantsLayer:YES];
}
- (void)mouseDown:(NSEvent*)theEvent{
	//CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	//[delegate mouseDown:aMousePoint];
}
- (void)mouseDragged:(NSEvent*)theEvent{
	//CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	//[delegate mouseDragged:aMousePoint];
}
- (void)mouseUp:(NSEvent*)theEvent{
	//CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	//[delegate mouseUp:aMousePoint];
}

- (void)keyDown:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	[delegate keyDown:aKey];
}
- (void)keyUp:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	[delegate keyUp:aKey];
}
- (BOOL)acceptsFirstResponder {
	return YES;
}


@end
