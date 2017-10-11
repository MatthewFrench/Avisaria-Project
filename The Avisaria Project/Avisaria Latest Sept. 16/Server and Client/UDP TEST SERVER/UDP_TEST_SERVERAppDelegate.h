//
//  UDP_TEST_SERVERAppDelegate.h
//  UDP TEST SERVER
//
//  Created by Matthew French on 1/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncUdpSocket.h"

@interface UDP_TEST_SERVERAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	AsyncUdpSocket *aSyncSocket;
	IBOutlet NSTextView* logView;
	IBOutlet NSTextField* ipField,*portField,*messageField;
}

@property (assign) IBOutlet NSWindow *window;

- (void)logMessage:(NSString*)message;
- (IBAction)send:(id)sender;

@end
