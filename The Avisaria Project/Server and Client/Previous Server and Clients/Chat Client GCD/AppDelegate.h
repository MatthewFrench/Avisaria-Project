#import <Cocoa/Cocoa.h>
#import "NetworkingController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NetworkingController* networkController;
	
	IBOutlet NSTextView* logView;
    IBOutlet id portField;
	IBOutlet NSTextField* ipField;
    IBOutlet id startStopButton;
	IBOutlet id sendMessageButton;
	IBOutlet id textField;
}
@property (assign) IBOutlet NSWindow *window;

- (IBAction)startStop:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (void)scrollToBottom;
- (void)logMessage:(NSString *)message;
- (void)connectedToServer;
- (void)recievedMessage:(NSData*)data;
- (void)disconnectedFromServer;
@end
