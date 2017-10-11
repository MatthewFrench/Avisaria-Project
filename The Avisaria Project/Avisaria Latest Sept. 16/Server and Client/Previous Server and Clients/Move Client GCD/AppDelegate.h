#import <Cocoa/Cocoa.h>
#import "NetworkingController.h"
#import "Player.h"
#import "WorldView.h"
#import <Quartz/Quartz.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NetworkingController* networkController;
	NSMutableArray* players;
	
	IBOutlet NSTextView* logView;
    IBOutlet id portField;
	IBOutlet NSTextField* ipField,*username;
    IBOutlet id startStopButton;
	IBOutlet id sendMessageButton;
	IBOutlet id textField;
	
	NSImage* guy;
	
	NSTimer* timer;
	
	IBOutlet WorldView* gameView;
	
	BOOL leftArrow,rightArrow,upArrow,downArrow;
}
@property (assign) IBOutlet NSWindow *window;

- (IBAction)startStop:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (NSString*)generateAction;
- (IBAction)updateName:(id)sender;
- (void)scrollToBottom;
- (void)logMessage:(NSString *)message;
- (void)connectedToServer;
- (void)recievedMessage:(NSData*)data;
- (void)disconnectedFromServer;

- (void)keyDown:(int)key;
- (void)keyUp:(int)key;

- (void)activateNewPlayer;
- (void)activateUpdatePlayer:(NSData*)data dataPos:(int)dataPos;
- (void)activateDeletePlayer:(int)num;
- (void)activateRecieveMessage:(NSData*)data dataPos:(int)dataPos;
- (NSData*)dataKeyPress:(int)num;
- (NSData*)dataKeyDepress:(int)num;
- (NSData*)dataMessage:(NSString*)msg;
- (NSData*)dataNameChange:(NSString*)msg;
- (unsigned char)getUnsignedCharFrom:(NSData*)data byteStart:(int*)byteStart;
- (unsigned int)getUnsignedIntFrom:(NSData*)data byteStart:(int*)byteStart;
- (unsigned int)getSignedShortIntFrom:(NSData*)data byteStart:(int*)byteStart;
- (NSString*)getNSStringFrom:(NSData*)data byteStart:(int*)byteStart length:(int)length;
@end