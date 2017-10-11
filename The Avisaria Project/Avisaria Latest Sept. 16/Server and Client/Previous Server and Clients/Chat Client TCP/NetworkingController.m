//
//  NetworkingController.m
//  EchoClient
//
//  Created by Matthew French on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkingController.h"
#import "AppDelegate.h"
AppDelegate* delegate;

@implementation NetworkingController
@synthesize isRunning;

- (id)init
{
	if(self = [super init])
	{
		delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
		listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
		isRunning = NO;
	}
	return self;
}
- (void)setUp {
	// Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
	[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}
- (void)connectIP:(NSString*)ip port:(int)port {
	NSError *error = nil;
	if(![listenSocket connectToHost:ip onPort:port withTimeout:-1 error:&error])
	{
		[delegate logMessage: [NSString stringWithFormat:@"Error starting client: %@", error]];
	}
}
- (void)sendString:(NSString*)string {
	NSString *sendMsg = [NSString stringWithFormat:@"%@\r\n", string];
	NSData *sendData = [sendMsg dataUsingEncoding:NSUTF8StringEncoding];
	[listenSocket writeData:sendData withTimeout:-1 tag:0];
}
- (void)sendData:(NSMutableData*)data {
	NSData *sendData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:sendData];
	[listenSocket writeData:data withTimeout:-1 tag:0];
}
- (void)disconnect {
	[listenSocket disconnect];
	[delegate logMessage:@"Stopped Echo server"];
	isRunning = false;	
}
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	isRunning = YES;
	[delegate logMessage: [NSString stringWithFormat:@"Accepted server %@:%hu", host, port]];
	
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
	[delegate connectedToServer];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	// Even if we were unable to write the incoming data to the log,
	// we're still going to echo it back to the client.
	//[sock writeData:data withTimeout:-1 tag:0];
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
	
	[delegate recievedMessage:data];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	if (isRunning) {
		[delegate logMessage:[NSString stringWithFormat:@"Server Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
	} else {
		[delegate logMessage:@"Unable to Connect to Server"];
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	isRunning = NO;
	[delegate disconnectedFromServer];
	//[connectedSockets removeObject:sock];
}

@end
