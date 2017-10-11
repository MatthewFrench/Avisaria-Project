//
//  NetworkingController.m
//  Chat Server
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
		listenSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
		
		isRunning = NO;
		// Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
		[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	}
	return self;
}
- (void)startServerOnPort:(int)port {
	NSError *error = nil;
	if(![listenSocket bindToPort:port error:&error])
	{
		[delegate logMessage:[NSString stringWithFormat:@"Error starting server: %@", error]];
		return;
	}
	
	[delegate logMessage:[NSString stringWithFormat:@"Echo server started on port %hu", [listenSocket localPort]]];
	isRunning = YES;
	[listenSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
}
- (void)stopServer {
	// Stop accepting connections
	[listenSocket close];
	
	// Stop any client connections
	int i;
	for(i = 0; i < [connectedSockets count]; i++)
	{
		// Call disconnect on the socket,
		// which will invoke the onSocketDidDisconnect: method,
		// which will remove the socket from the list.
		[[connectedSockets objectAtIndex:i] close];
	}
	
	[delegate logMessage:@"Stopped server"];
	isRunning = false;
}
- (void)sendDataToAll:(NSData*)data {
	for (int i = 0; i < [connectedSockets count]; i ++) {
		[[connectedSockets objectAtIndex:i] sendData:data withTimeout:-1 tag:0];
	}
}
- (void)onSocket:(AsyncUdpSocket *)sock didAcceptNewSocket:(AsyncUdpSocket *)newSocket
{
	[connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncUdpSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	[delegate logMessage:[NSString stringWithFormat:@"Accepted client %@:%hu", host, port]];
	
	//[sock writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
	[listenSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
	
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
	[delegate clientConnected];
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
	NSLog(@"NOES!");
}
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
	//[listenSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
	[listenSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
	[delegate recievedMessage:data];
	[listenSocket sendData:data toHost:host port:port withTimeout:-1 tag:0];
	NSLog(@"YAY");
	return YES;
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
	NSLog(@"NOES!!");
}
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
	[delegate logMessage:[NSString stringWithFormat:@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
	[delegate clientDisconnected];
	[connectedSockets removeObject:sock];
}
@end
