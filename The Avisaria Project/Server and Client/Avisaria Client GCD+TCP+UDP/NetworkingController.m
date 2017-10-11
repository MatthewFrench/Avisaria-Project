#import "NetworkingController.h"
#import "AppDelegate.h"
AppDelegate* delegate;

@implementation NetworkingController
@synthesize isRunning, listenSocket,listenUdpSocket;

- (id)init
{
	if(self = [super init])
	{
		delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
		isRunning = NO;
	}
	return self;
}
- (void)connectIP:(NSString*)ip port:(int)port {
	hostString = ip;
	portNum = port;
	NSError *error = nil;
	if(![listenSocket connectToHost:ip onPort:port error:&error])
	{
		[delegate logMessage: [NSString stringWithFormat:@"Error starting TCP client: %@", error]];
		[delegate disconnectedFromServer];
	}
	//Connect UDP
	listenUdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
	//[listenUdpSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];

	udpID = 0;
	[listenUdpSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
	//Resend the UDP port just in case
	if (isRunning) {
		[self sendData:[delegate dataUdpInfo]];
	}
}

//TCP
- (void)sendString:(NSString*)string {
	NSString *sendMsg = [NSString stringWithFormat:@"%@\r\n", string];
	NSData *sendData = [sendMsg dataUsingEncoding:NSUTF8StringEncoding];
	[listenSocket writeData:sendData withTimeout:-1 tag:0];
}
- (void)sendData:(NSData*)data {
	NSMutableData* sendData = [NSMutableData dataWithData:data];
	[sendData appendData:[NSData dataWithBytes:"\x0D\x0A" length:2]];
	[listenSocket writeData:sendData withTimeout:-1 tag:0];
}
- (void)disconnect {
	[listenSocket disconnect];
	[listenUdpSocket close];
	[listenUdpSocket release];
	[delegate logMessage:@"Stopped TCP and UDP Client"];
	isRunning = FALSE;
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	isRunning = YES;
	[delegate logMessage: [NSString stringWithFormat:@"Accepted TCP server %@:%hu", host, port]];
	
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
	[delegate connectedToServer];
	
	//Resend the UDP port just in case
	[self sendData:[delegate dataUdpInfo]];
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
	
	[delegate recievedMessage:data];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (isRunning) {
		[delegate logMessage:[NSString stringWithFormat:@"TCP Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
	} else {
		[delegate logMessage:@"Unable to Connect to Server"];
	}
	isRunning = NO;
	[delegate disconnectedFromServer];
	//[connectedSockets removeObject:sock];
}


//UDP
- (void)sendUdpData:(NSData*)data {
	int playerNum = delegate.isPlayer;
	NSMutableData* data2 = [NSMutableData dataWithBytes:&playerNum length:sizeof(int)];
	[data2 appendData:data];
	[listenUdpSocket sendData:data2 toHost:hostString port:portNum withTimeout:-1 tag:0];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
	//[delegate logMessage:@"Sent UDP Message"];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
	//[delegate logMessage:@"Did Not Send UDP Message"];
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
	//[delegate logMessage:@"Did Not UDP Message"];
}
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
	BOOL recieve = FALSE;
	unsigned char number;
	[data getBytes:&number length:1];
	if (number > udpID) {
		udpID = number;
		recieve = TRUE;
	} else {
		if (udpID > 255/2 && number < 255/2) {
			udpID = number;
			recieve = TRUE;
		}
	}
	if (recieve) {
		[delegate recievedUdpMessage:data];
	}
	[listenUdpSocket receiveWithTimeout:-1 tag:1];  //Start listening for a UDP packet.
	return NO;
}
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
	//[delegate logMessage:[NSString stringWithFormat:@"Server Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
}

@end
