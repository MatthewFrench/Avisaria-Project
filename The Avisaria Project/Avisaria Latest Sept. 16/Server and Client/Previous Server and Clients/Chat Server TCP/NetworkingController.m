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
		listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
		
		isRunning = NO;
		// Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
		[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	}
	return self;
}
- (void)startServerOnPort:(int)port {
	NSError *error = nil;
	if(![listenSocket acceptOnPort:port error:&error])
	{
		[delegate logMessage:[NSString stringWithFormat:@"Error starting server: %@", error]];
		return;
	}
	
	[delegate logMessage:[NSString stringWithFormat:@"Echo server started on port %hu", [listenSocket localPort]]];
	isRunning = YES;
}
- (void)stopServer {
	// Stop accepting connections
	[listenSocket disconnect];
	
	// Stop any client connections
	int i;
	for(i = 0; i < [connectedSockets count]; i++)
	{
		// Call disconnect on the socket,
		// which will invoke the onSocketDidDisconnect: method,
		// which will remove the socket from the list.
		[[connectedSockets objectAtIndex:i] disconnect];
	}
	
	[delegate logMessage:@"Stopped server"];
	isRunning = false;
}
- (void)sendDataToAll:(NSData*)data {
	for (int i = 0; i < [connectedSockets count]; i ++) {
		[[connectedSockets objectAtIndex:i] writeData:data withTimeout:-1 tag:0];
	}
}
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	[delegate logMessage:[NSString stringWithFormat:@"Accepted client %@:%hu", host, port]];
	
	//[sock writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
	
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
	[delegate clientConnected];
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
	[delegate logMessage:[NSString stringWithFormat:@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
	[delegate clientDisconnected];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[connectedSockets removeObject:sock];
}
@end
