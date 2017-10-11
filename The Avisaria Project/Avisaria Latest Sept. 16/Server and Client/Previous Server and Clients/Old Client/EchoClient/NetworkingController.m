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
- (BOOL)connectIP:(NSString*)ip port:(int)port {
	NSError *error = nil;
	if(![listenSocket connectToHost:ip onPort:port withTimeout:-1 error:&error])
	{
		[self logError: [NSString stringWithFormat:@"Error starting client: %@", error]];
		return FALSE;
	}
	[self logInfo: [NSString stringWithFormat:@"Echo client started on port %hu", [listenSocket localPort]]];
	isRunning = YES;
	return TRUE;
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
	[self logInfo:@"Stopped Echo server"];
	isRunning = false;	
}
- (void)logError:(NSString *)msg
{
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	[as autorelease];
	
	[[delegate.logView textStorage] appendAttributedString:as];
	[delegate scrollToBottom];
}

- (void)logInfo:(NSString *)msg
{
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor purpleColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	[as autorelease];
	
	[[delegate.logView textStorage] appendAttributedString:as];
	[delegate scrollToBottom];
}

- (void)logMessage:(NSString *)msg
{
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	[as autorelease];
	
	[[delegate.logView textStorage] appendAttributedString:as];
	[delegate scrollToBottom];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	[self logInfo: [NSString stringWithFormat:@"Accepted server %@:%hu", host, port]];
	
	//[sock writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
	
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		[self logMessage:msg];
	}
	else
	{
		[self logError:@"Error converting received data into UTF-8 String"];
	}
	
	// Even if we were unable to write the incoming data to the log,
	// we're still going to echo it back to the client.
	//[sock writeData:data withTimeout:-1 tag:0];
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	[self logInfo:[NSString stringWithFormat:@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	//[connectedSockets removeObject:sock];
}

@end
