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
- (id)init {
	if(self = [super init])
	{
		delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
		
		socketQueue = dispatch_queue_create("SocketQueue", NULL);
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
		
		// Setup an array to store all accepted client connections
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
		udpPorts  = [NSMutableArray new];
		
		isRunning = NO;
	}
	return self;
}
- (void)startServerOnPort:(int)port {
	NSError *error = nil;
	if(![listenSocket acceptOnPort:port error:&error])
	{
		[delegate logMessage:[NSString stringWithFormat:@"Error starting TCP server: %@", error]];
		return;
	}
	
	[delegate logMessage:[NSString stringWithFormat:@"TCP server started on port %hu", [listenSocket localPort]]];
	isRunning = YES;
	
	//Udp
	listenUdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
	// Advanced options - enable the socket to contine operations even during modal dialogs, and menu browsing
	[listenUdpSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	
	if(![listenUdpSocket bindToPort:port error:&error])
	{
		[delegate logMessage:[NSString stringWithFormat:@"Error starting UDP server: %@", error]];
	} else {
		[delegate logMessage:[NSString stringWithFormat:@"UDP server started on port %hu", [listenUdpSocket localPort]]];
	}
	[listenUdpSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
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
	
	[delegate logMessage:@"Stopped TCP and UDP server"];
	isRunning = false;
	
	[listenUdpSocket close];
	[listenUdpSocket release];
}

//TCP
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
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	// This method is executed on the socketQueue (not the main thread)
	
	@synchronized(connectedSockets)
	{
		[connectedSockets addObject:newSocket];
		[udpPorts addObject:[NSNumber numberWithInt:-1]];
	}
	
	NSString *host = [newSocket connectedHost];
	UInt16 port = [newSocket connectedPort];
	
	int clientNum = [connectedSockets count]-1;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[delegate logMessage:[NSString stringWithFormat:@"Accepted TCP client %@:%hu", host, port]];
		[delegate clientConnected:clientNum];
		[pool release];
	});
	
	
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
	
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
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

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
	if (sock != listenSocket)
	{
		int clientNum = [connectedSockets indexOfObject:sock];
		@synchronized(connectedSockets)
		{
			if ([udpPorts count] > [connectedSockets indexOfObject:sock]) {
				[udpPorts removeObjectAtIndex:[connectedSockets indexOfObject:sock]];
			}
			
			[connectedSockets removeObject:sock];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			[delegate logMessage:[NSString stringWithFormat:@"TCP Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
			[delegate clientDisconnected:clientNum];
			
			[pool release];
		});
	}
}


//UDP
- (void)sendUdpDataToAll:(NSData*)data except:(int)num {
	unsigned char udpID;
	for (int i = 0; i < [connectedSockets count]; i ++) {
		GCDAsyncSocket* socket = [connectedSockets objectAtIndex:i];
		if ([udpPorts count] > i && i != num) {
			int port = [[udpPorts objectAtIndex:i] intValue];
			Player* sendTo = [delegate.players objectAtIndex:i];
			//Add UPD ID to front
			udpID = (unsigned char)sendTo.udpID;
			NSMutableData* sendData = [NSMutableData dataWithData:[NSData dataWithBytes:&udpID length:1]];
			[sendData appendData:data];
			
			[listenUdpSocket sendData:sendData toHost:[socket connectedHost] port:port withTimeout:0.1 tag:0];
			sendTo.udpID += 1;
			if (sendTo.udpID > 255) {sendTo.udpID = 0;}
			
		}
	}
}
- (void)sendUdpData:(NSData*)data to:(int)num {
	unsigned char udpID;
	GCDAsyncSocket* socket = [connectedSockets objectAtIndex:num];
	if ([udpPorts count] > num) {
		int port = [[udpPorts objectAtIndex:num] intValue];
		Player* sendTo = [delegate.players objectAtIndex:num];
		//Add UPD ID to front
		udpID = (unsigned char)sendTo.udpID;
		NSMutableData* sendData = [NSMutableData dataWithData:[NSData dataWithBytes:&udpID length:1]];
		[sendData appendData:data];
		
		[listenUdpSocket sendData:sendData toHost:[socket connectedHost] port:port withTimeout:0.1 tag:0];
		sendTo.udpID += 1;
		if (sendTo.udpID > 255) {sendTo.udpID = 0;}
		
	}
}
- (void)sendUdpDataToAll:(NSData*)data {
	unsigned char udpID;
	for (int i = 0; i < [connectedSockets count]; i ++) {
		GCDAsyncSocket* socket = [connectedSockets objectAtIndex:i];
		if ([udpPorts count] > i) {
			int port = [[udpPorts objectAtIndex:i] intValue];
			if (port != -1) {
				Player* sendTo = [delegate.players objectAtIndex:i];
				//Add UPD ID to front
				udpID = (unsigned char)sendTo.udpID;
				NSMutableData* sendData = [NSMutableData dataWithData:[NSData dataWithBytes:&udpID length:1]];
				[sendData appendData:data];
				
				[listenUdpSocket sendData:sendData toHost:[socket connectedHost] port:port withTimeout:0.1 tag:0];
				sendTo.udpID += 1;
				if (sendTo.udpID > 255) {sendTo.udpID = 0;}
			}
		}
	}
}
- (void)onSocket:(AsyncUdpSocket *)sock didAcceptNewSocket:(AsyncUdpSocket *)newSocket
{
}

- (void)onSocket:(AsyncUdpSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	[delegate logMessage:[NSString stringWithFormat:@"Accepted UDP client %@:%hu", host, port]];
	[listenUdpSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
	NSLog(@"Did not send UDP data");
}
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
	int player = -1;
	[data getBytes:&player length:sizeof(int)];
	if (player > -1 && player < [connectedSockets count]) {
		GCDAsyncSocket* socket = [connectedSockets objectAtIndex:player];
		int portNum = [[udpPorts objectAtIndex:player] intValue];
		if ([[socket connectedHost] isEqualToString:host] && portNum == 0 || portNum == -1) {
			[udpPorts replaceObjectAtIndex:player withObject:[NSNumber numberWithInt:port]];
			portNum = port;
		}
		if ([[socket connectedHost] isEqualToString:host] && portNum == port) {
			[delegate recievedUdpMessage:data player:player];
		}
	}
	
	/**
	for (int i = 0; i < [connectedSockets count]; i ++) {
		GCDAsyncSocket* socket = [connectedSockets objectAtIndex:i];
		if ([udpPorts count] > i) {
			NSNumber* portNum = [udpPorts objectAtIndex:i];
			if ([[socket connectedHost] isEqualToString:host] && (int)port == [portNum intValue]) {
				player = i;
			}
		}
	}
	 **/
	[listenUdpSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
	return YES;
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
	NSLog(@"Did not recieve UDP data");
}
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
	[delegate logMessage:[NSString stringWithFormat:@"Client UDP Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
}
- (void)initUdpSocket:(int)port Player:(int)num {
	[udpPorts addObject: [NSNumber numberWithInt:port]];
	[udpPorts replaceObjectAtIndex:num withObject:[NSNumber numberWithInt:port]];
}


@end
