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
		
		socketQueue = dispatch_queue_create("SocketQueue", NULL);
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
		
		// Setup an array to store all accepted client connections
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
		
		isRunning = NO;
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
	@synchronized(connectedSockets)
	{
		NSUInteger i;
		for (i = 0; i < [connectedSockets count]; i++)
		{
			// Call disconnect on the socket,
			// which will invoke the socketDidDisconnect: method,
			// which will remove the socket from the list.
			[[connectedSockets objectAtIndex:i] disconnect];
		}
	}
	
	[delegate logMessage:@"Stopped server"];
	isRunning = false;
}
- (void)sendDataToAll:(NSData*)data {
	NSMutableData* sendData = [NSMutableData dataWithData:data];
	[sendData appendData:[NSData dataWithBytes:"\x0D\x0A" length:2]];
	for (int i = 0; i < [connectedSockets count]; i ++) {
		[[connectedSockets objectAtIndex:i] writeData:sendData withTimeout:-1 tag:0];
	}
}
- (void)sendDataToAll:(NSData*)data except:(int)num {
	NSMutableData* sendData = [NSMutableData dataWithData:data];
	[sendData appendData:[NSData dataWithBytes:"\x0D\x0A" length:2]];
	for (int i = 0; i < [connectedSockets count]; i ++) {
		if (i != num) {
			[[connectedSockets objectAtIndex:i] writeData:sendData withTimeout:-1 tag:0];
		}
	}
}
- (void)sendData:(NSData*)data to:(int)num {
	NSMutableData* sendData = [NSMutableData dataWithData:data];
	[sendData appendData:[NSData dataWithBytes:"\x0D\x0A" length:2]];
	[[connectedSockets objectAtIndex:num] writeData:sendData withTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
	
	@synchronized(connectedSockets)
	{
		[connectedSockets addObject:newSocket];
	}
	
	NSString *host = [newSocket connectedHost];
	UInt16 port = [newSocket connectedPort];
	
	int clientNum = [connectedSockets count]-1;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[delegate logMessage:[NSString stringWithFormat:@"Accepted client %@:%hu", host, port]];
		[delegate clientConnected:clientNum];
		[pool release];
	});
	
	
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
	
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	// Even if we were unable to write the incoming data to the log,
	// we're still going to echo it back to the client.
	//[sock writeData:data withTimeout:-1 tag:0];
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
	int clientNum = [connectedSockets indexOfObject:sock];
	data = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[delegate recievedMessage:data from:clientNum with:0];
		
		[pool release];
	});
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != listenSocket)
	{
		int clientNum = [connectedSockets indexOfObject:sock];
		@synchronized(connectedSockets)
		{
			[connectedSockets removeObject:sock];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			[delegate logMessage:[NSString stringWithFormat:@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
			[delegate clientDisconnected:clientNum];
			
			[pool release];
		});
	}
}
@end
