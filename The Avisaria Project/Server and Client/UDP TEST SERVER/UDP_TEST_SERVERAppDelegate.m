//
//  UDP_TEST_SERVERAppDelegate.m
//  UDP TEST SERVER
//
//  Created by Matthew French on 1/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UDP_TEST_SERVERAppDelegate.h"

@implementation UDP_TEST_SERVERAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	aSyncSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];  //We are the delegate for the asynchronous socket object.
    [aSyncSocket bindToPort:7777 error:nil];  //We want to listen on port 1234...don't care about errors for now.
    [aSyncSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
}
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
	NSString *theLine=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];  //Convert the UDP data to an NSString
	NSLog(@"%@", theLine);
	[self logMessage:theLine];
	[theLine release];
	
	[aSyncSocket sendData:data toHost:host port:port withTimeout:-1 tag:0];
	
	[aSyncSocket receiveWithTimeout:-1 tag:1];  //Listen for the next UDP packet to arrive...which will call this method again in turn.
	
	[ipField setStringValue:host];
	[portField setStringValue:[NSString stringWithFormat:@"%d",port]];
	
	return YES;  //Signal that we didn't ignore the packet.
}
- (void)logMessage:(NSString*)message {
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", message];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	[as autorelease];
	
	[[logView textStorage] appendAttributedString:as];
	//[self scrollToBottom];
}

- (IBAction)send:(id)sender {
	NSString* host = [ipField stringValue];
	int portNum = [portField intValue];
	NSString* sendMsg = [messageField stringValue];
	NSData* data = [sendMsg dataUsingEncoding:NSUTF8StringEncoding];
	[aSyncSocket sendData:data toHost:host port:portNum withTimeout:-1 tag:0];
}


@end
