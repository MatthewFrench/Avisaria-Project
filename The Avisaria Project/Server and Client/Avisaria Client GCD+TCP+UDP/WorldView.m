#import "WorldView.h"
#import "AppDelegate.h"

@implementation WorldView
AppDelegate* delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib{
	//Set any global variables you have made here.
	//For example, test = 10;
	delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
}
/**
- (void) reshape{
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	// Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho( screenDimensions.x/2, -screenDimensions.x/2, -screenDimensions.y / 2, screenDimensions.y / 2, -1, 1 );
	glMatrixMode(GL_MODELVIEW);
	glViewport(0, 0, -screenDimensions.x, -screenDimensions.y);
	glTranslatef(0.0f+screenDimensions.x / 2, 0.0f+screenDimensions.y / 2, 0.0f );
	glRotatef(180.0f, 0.0f, 0.0f, 1.0f);
	//glScalef(1.0, -1.0, 1.0);
	
	
	// Initialize OpenGL states
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
	glEnableClientState(GL_VERTEX_ARRAY);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}
**/

- (void)mouseDown:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate mouseDown:aMousePoint];
}
- (void)mouseDragged:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate mouseMove:aMousePoint];
}
- (void)mouseUp:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate mouseUp:aMousePoint];
}


- (void)keyDown:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate keyDown:aKey];
}
- (void)keyUp:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate keyUp:aKey];
}

- (BOOL)isOpaque{
    return NO;
}
/**
- (BOOL)isFlipped{
    return YES;
}
 **/
- (BOOL)acceptsFirstResponder {
	return YES;
}
- (void) dealloc
{
	[super dealloc];
}

@end
