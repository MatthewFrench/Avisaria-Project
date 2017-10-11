//
//  Chat_ClientAppDelegate.m
//  Chat Client
//
//  Created by Matthew French on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	networkController = [[NetworkingController alloc] init];
	[logView setString:@""];
}
- (IBAction)startStop:(id)sender {
	if(!networkController.isRunning)
	{
		int port = [portField intValue];
		if(port < 0 || port > 65535)
		{
			port = 0;
		}
		
		[networkController connectIP:[ipField stringValue] port:port];
	}
	else
	{
		[networkController disconnect];
	}
}
- (IBAction)sendMessage:(id)sender {
	[networkController sendString:[textField stringValue]];
	[textField setStringValue:@""];
}
- (void)scrollToBottom {
	NSScrollView *scrollView = [logView enclosingScrollView];
	[[scrollView documentView] scrollPoint:NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]))];
}
- (void)logMessage:(NSString*)message {
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", message];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	[as autorelease];
	
	[[logView textStorage] appendAttributedString:as];
	[self scrollToBottom];
}

- (void)connectedToServer {
	[portField setEnabled:NO];
	[startStopButton setTitle:@"Stop"];
}
- (void)recievedMessage:(NSData*)data {
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		[self logMessage:msg];
	}
	else
	{
		[self logMessage:@"Error converting received data into UTF-8 String"];
	}
}
- (void)disconnectedFromServer {
	[portField setEnabled:YES];
	[startStopButton setTitle:@"Start"];
}

@end