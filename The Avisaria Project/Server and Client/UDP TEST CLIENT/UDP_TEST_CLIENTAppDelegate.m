//
//  UDP_TEST_CLIENTAppDelegate.m
//  UDP TEST CLIENT
//
//  Created by Matthew French on 1/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UDP_TEST_CLIENTAppDelegate.h"

@implementation UDP_TEST_CLIENTAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	aSyncSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];  //We are the delegate for the asynchronous socket object.
	[aSyncSocket receiveWithTimeout:-1 tag:1];
}
-(IBAction)send:(id)sender {
	NSString* host = [ip stringValue];
	int portNum = [port intValue];
	NSString* sendMsg = [message stringValue];
	NSData* data = [sendMsg dataUsingEncoding:NSUTF8StringEncoding];
	[aSyncSocket sendData:data toHost:host port:portNum withTimeout:-1 tag:0];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
	NSString *theLine=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];  //Convert the UDP data to an NSString
	NSLog(@"%@", theLine);
	[self logMessage:theLine];
	[theLine release];
	
	[aSyncSocket receiveWithTimeout:-1 tag:1];  //Listen for the next UDP packet to arrive...which will call this method again in turn.
	return YES;  //Signal that we didn't ignore the packet.
}
- (void)logMessage:(NSString*)newmessage {
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", newmessage];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	[as autorelease];
	
	[[logView textStorage] appendAttributedString:as];
	//[self scrollToBottom];
}

@end
