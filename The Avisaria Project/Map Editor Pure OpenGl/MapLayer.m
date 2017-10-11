#import <OpenGL/OpenGL.h>
#import "AppDelegate.h"
#import "MapLayer.h"

@implementation MapLayer
AppDelegate* delegate;

- (id)init
{
	if(self = [super init])
	{
		delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	}
	return self;
}

- (CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask: (uint32_t)mask {
	NSLog(@"Creatin pixel thingy");
	CGLPixelFormatAttribute attributes[] =
	{
		kCGLPFADisplayMask, mask,
		kCGLPFAAccelerated,
		kCGLPFAColorSize, 24,
		kCGLPFAAlphaSize, 8,
		kCGLPFADepthSize, 16,
		kCGLPFANoRecovery,
		kCGLPFAMultisample,
		kCGLPFASupersample,
		kCGLPFASampleAlpha,
		0
	};
	CGLPixelFormatObj pixelFormatObj = NULL;
	GLint numPixelFormats = 0;
	CGLChoosePixelFormat(attributes, &pixelFormatObj, &numPixelFormats);
	if(pixelFormatObj == NULL)
		NSLog(@"Error: Could not choose pixel format!");
	return pixelFormatObj;
}

- (void)releaseCGLPixelFormat:(CGLPixelFormatObj)pixelFormat {
	CGLDestroyPixelFormat(pixelFormat);
}

- (CGLContextObj)copyCGLContextForPixelFormat: (CGLPixelFormatObj)pixelFormat {
	NSLog(@"Creatin context");
	CGLContextObj contextObj = NULL;
	CGLCreateContext(pixelFormat, NULL, &contextObj);
	if(contextObj == NULL)
		NSLog(@"Error: Could not create context!");
	
	CGLSetCurrentContext(contextObj);
	
	//
	// Setup OpenGL environment.
	//
	CGLLockContext(contextObj);
	[delegate setUpOpenGl:self];
	CGLUnlockContext(contextObj);
	
	return contextObj;
}

- (void)releaseCGLContext:(CGLContextObj)glContext {
	
	//
	// Clean up OpenGL environment.
	//
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	
	CGLDestroyContext(glContext);
}-(BOOL)canDrawInCGLContext:(CGLContextObj)glContext pixelFormat:(CGLPixelFormatObj)pixelFormat forLayerTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp
{
	// Just like the default, we'll just always return YES and always refresh.
	// You normally would not override this method to do this.
	return YES;
}

// 4)	[Required] Implement this message in order to actually draw anything.
//		Typically you will do the following when you recieve this message:
//		1. Draw your OpenGL content! (the current context has already been set)
//		2. call [super drawInContext:pixelFormat:forLayerTime:displayTime:] to finalize the layer content, or call glFlush().
//		NOTE: The viewport has already been set correctly by the time this message is sent, so you do not need to set it yourself.
//		The viewport is automatically updated whenever the layer is displayed (that is, when the -display message is sent).
//		This is arranged for when you send the -setNeedsDisplay message, or when the needsDisplayOnBoundsChange property is set to YES
//		and the layer's size changes.
-(void)drawInCGLContext:(CGLContextObj)glContext pixelFormat:(CGLPixelFormatObj)pixelFormat forLayerTime:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp
{
	// Set the current context to the one given to us.
	CGLSetCurrentContext(glContext);
	
	[delegate drawMapLayer:self timeInterval:timeInterval];
	
	// Call super to finalize the drawing. By default all it does is call glFlush().
	[super drawInCGLContext:glContext pixelFormat:pixelFormat forLayerTime:timeInterval displayTime:timeStamp];
}

@end
