//
//  Texture.h
//  OpenGl TEST
//
//  Created by Matthew French on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/Appkit.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <OpenGL/glu.h>


@interface Texture : NSObject {
	GLuint currentTexture;
	size_t width;
	size_t height;
}
@property(nonatomic) size_t width, height;
- (void) initWithImageAtPath:(NSString*)path;
- (void) initWithImage:(NSImage*)image;
- (void) drawAt:(CGPoint)position;

@end
