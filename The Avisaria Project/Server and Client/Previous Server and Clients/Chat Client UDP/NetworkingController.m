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
		listenSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
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
	if(![listenSocket connectToHost:ip onPort:port error:&error])
	{
		[delegate logMessage: [NSString stringWithFormat:@"Error starting client: %@", error]];
	} else {
		isRunning = YES;
		[delegate logMessage: [NSString stringWithFormat:@"Accepted server %@:%hu", ip, port]];
		
		[listenSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
		[delegate connectedToServer];
	}
}
- (void)sendString:(NSString*)string {
	NSString *sendMsg = [NSString stringWithFormat:@"%@\r\n", string];
	NSData *sendData = [sendMsg dataUsingEncoding:NSUTF8StringEncoding];
	//Returns bool. May be of interest.
	[listenSocket sendData:sendData withTimeout:-1 tag:0];
}
- (void)sendData:(NSMutableData*)data {
	NSData *sendData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
	[data appendData:sendData];
	[listenSocket sendData:data withTimeout:-1 tag:0];
}
- (void)disconnect {
	[listenSocket close];
	[delegate logMessage:@"Stopped Echo server"];
	isRunning = false;	
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
	NSLog(@"Sent Data");
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
	NSLog(@"NOES!");
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
	NSLog(@"NOES!!");
}
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
	[listenSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
	NSLog(@"YAY");
	[delegate recievedMessage:data];
	return NO;
}
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
	[delegate logMessage:[NSString stringWithFormat:@"Server Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
	isRunning = NO;
	[delegate disconnectedFromServer];
}

@end
