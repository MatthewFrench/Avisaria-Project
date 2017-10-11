//
//  UDP_TEST_CLIENTAppDelegate.h
//  UDP TEST CLIENT
//
//  Created by Matthew French on 1/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncUdpSocket.h"

@interface UDP_TEST_CLIENTAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	AsyncUdpSocket *aSyncSocket;
	IBOutlet NSTextField* ip,*port,*message;
	IBOutlet NSTextView* logView;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)send:(id)sender;
- (void)logMessage:(NSString*)message;

@end
