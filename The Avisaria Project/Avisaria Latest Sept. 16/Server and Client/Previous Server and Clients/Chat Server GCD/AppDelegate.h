//
//  Chat_ServerAppDelegate.h
//  Chat Server
//
//  Created by Matthew French on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetworkingController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	NetworkingController* networkController;
	
	IBOutlet id logView;
    IBOutlet id portField;
    IBOutlet id startStopButton;
}
@property (assign) IBOutlet NSWindow *window;

- (IBAction)startStop:(id)sender;
- (void)logMessage:(NSString *)msg;
- (void)scrollToBottom;
- (void)clientConnected;
- (void)recievedMessage:(NSData*)data;
- (void)clientDisconnected;

@end
