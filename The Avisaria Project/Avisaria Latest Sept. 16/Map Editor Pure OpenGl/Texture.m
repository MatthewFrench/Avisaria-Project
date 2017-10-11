//
//  Texture.m
//  OpenGl TEST
//
//  Created by Matthew French on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Texture.h"


@implementation Texture
@synthesize width,height;

- (void) initWithImageAtPath:(NSString *)path {
	CFURLRef	url = CFURLCreateWithFileSystemPath(NULL,(CFStringRef)path,kCFURLPOSIXPathStyle,false);
	
	CGImageSourceRef	myImageSourceRef = CGImageSourceCreateWithURL(url, nil);
	CGImageRef			myImageRef = CGImageSourceCreateImageAtIndex(myImageSourceRef,0,nil);
	
	GLuint myTextureName;
	
	width = CGImageGetWidth(myImageRef);
	height = CGImageGetHeight(myImageRef);
	
	CGRect rect = {{0,0},{width,height}};
	void * myData = calloc(width * 4, height );
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef myBitmapContext = CGBitmapContextCreate (myData, 
														  width, height, 8,
														  width*4, space, 
														  kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(myBitmapContext, rect, myImageRef);
	CGContextRelease(myBitmapContext);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glGenTextures(1, &myTextureName);
	
	glBindTexture(GL_TEXTURE_2D, myTextureName);
	glTexParameteri(GL_TEXTURE_2D, 
					GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, 4, width, height,
				 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, myData);
	
	free(myData);	
	
	currentTexture = myTextureName;
}
- (void) initWithImage:(NSImage *)image {
	CGImageSourceRef	myImageSourceRef = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
	CGImageRef			myImageRef = CGImageSourceCreateImageAtIndex(myImageSourceRef,0,nil);
	
	GLuint myTextureName;
	
	width = CGImageGetWidth(myImageRef);
	height = CGImageGetHeight(myImageRef);
	
	CGRect rect = {{0,0},{width,height}};
	void * myData = calloc(width * 4, height );
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef myBitmapContext = CGBitmapContextCreate (myData, 
														  width, height, 8,
														  width*4, space, 
														  kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(myBitmapContext, rect, myImageRef);
	CGContextRelease(myBitmapContext);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glGenTextures(1, &myTextureName);
	
	glBindTexture(GL_TEXTURE_2D, myTextureName);
	glTexParameteri(GL_TEXTURE_2D, 
					GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, 4, width, height,
				 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, myData);
	
	free(myData);	
	
	currentTexture = myTextureName;
}

- (void) drawAt:(CGPoint)position {
	// bind our texture
	glBindTexture( GL_TEXTURE_2D, currentTexture);
	
	glBegin(GL_QUADS);
	{
		glTexCoord2f(0.0f,0.0f); glVertex2f( position.x,  position.y);   // bottom left
		glTexCoord2f(1.0f,0.0f); glVertex2f( width+position.x,  position.y);   // bottom right
		glTexCoord2f(1.0f,1.0f); glVertex2f( width+position.x, height+position.y);   // top right
		glTexCoord2f(0.0f,1.0f); glVertex2f( position.x,  height+position.y);   // top left
	}
	glEnd();
}

- (void) dealloc{
	glDeleteTextures(1, &currentTexture);
	
	[super dealloc];
}
@end
