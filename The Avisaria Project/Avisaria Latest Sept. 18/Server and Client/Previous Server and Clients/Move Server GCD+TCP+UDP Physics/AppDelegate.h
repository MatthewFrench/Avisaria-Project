#import <Cocoa/Cocoa.h>
#import "NetworkingController.h"
#import "Player.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	NetworkingController* networkController;
	NSMutableArray* players;
	NSTimer* timer;
	
	IBOutlet id logView;
    IBOutlet id portField;
    IBOutlet id startStopButton;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) NSMutableArray* players;

- (IBAction)startStop:(id)sender;
- (void)logMessage:(NSString *)msg;
- (void)scrollToBottom;
- (void)clientConnected:(int)num;
- (void)recievedMessage:(NSData*)data from:(int)num with:(int)dataPos;
- (void)recievedUdpMessage:(NSData*)data player:(int)num;
- (void)clientDisconnected:(int)num;

- (void)activateKeyPress:(int)key Player:(int)num;
- (void)activateKeyDepress:(int)key Player:(int)num;
- (void)activateRecieveMessage:(NSString*)message Player:(int)num;
- (void)activateNameChange:(NSString*)name Player:(int)num;

//Send To Client
- (NSData*)dataNewPlayer;
- (NSData*)dataUpdatePlayerPos:(int)num;
- (NSData*)dataDeletePlayer:(int)num;
- (NSData*)dataUpdatePlayerPressed:(int)num key:(int)key;
- (NSData*)dataUpdatePlayerDepressed:(int)num key:(int)key;
- (NSData*)dataUpdatePlayerVel:(int)num;
- (NSData*)dataMessage:(NSString*)msg;
- (NSData*)dataNameChange:(int)num;

- (unsigned char)getUnsignedCharFrom:(NSData*)data byteStart:(int*)byteStart;
- (unsigned int)getUnsignedIntFrom:(NSData*)data byteStart:(int*)byteStart;
- (signed short int)getSignedShortIntFrom:(NSData*)data byteStart:(int*)byteStart;
- (NSString*)getNSStringFrom:(NSData*)data byteStart:(int*)byteStart length:(int)length;

- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r;
@end
