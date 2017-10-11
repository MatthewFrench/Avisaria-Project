//
//  ObjectEditorView.h
//  Avisaria World Editor
//
//  Created by Matthew French on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface ObjectPlatform : NSView {
	CALayer* rootLayer;
}
@property(nonatomic,retain) CALayer* rootLayer;

@end
