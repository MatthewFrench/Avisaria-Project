//
//  ObjectEditorView.m
//  Avisaria World Editor
//
//  Created by Matthew French on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ObjectPlatform.h"
#import "AppDelegate.h"


@implementation ObjectPlatform
@synthesize rootLayer;

- (void)awakeFromNib {
	rootLayer = [CALayer layer];
	[rootLayer retain];
	
	[self setLayer: rootLayer];
	[self setWantsLayer:YES];
}
- (void)mouseDown:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate setAnchorPoint:aMousePoint];
}
- (void)mouseDragged:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate setAnchorPoint:aMousePoint];
}
- (void)mouseUp:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	if (([theEvent modifierFlags] & (NSShiftKeyMask | NSAlphaShiftKeyMask)) != 0) {
		[delegate resetAnchorPoint];
	} else {
		[delegate setAnchorPoint:aMousePoint];
	}
}
- (BOOL)isFlipped{
    return YES;
}
- (BOOL)acceptsFirstResponder {
	return YES;
}

@end