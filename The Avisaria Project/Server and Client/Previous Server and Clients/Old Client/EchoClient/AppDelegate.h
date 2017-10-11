#import <Cocoa/Cocoa.h>
#import "NetworkingController.h"

@interface AppDelegate : NSObject
{
	NetworkingController* networkController;
	
    IBOutlet id portField;
    IBOutlet id startStopButton;
	IBOutlet id sendMessageButton;
	IBOutlet id textField;
}
@property(nonatomic,assign) IBOutlet NSTextView* logView;
- (IBAction)startStop:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (void)scrollToBottom;
@end
