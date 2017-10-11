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
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
		isRunning = NO;
	}
	return self;
}
- (void)connectIP:(NSString*)ip port:(int)port {
	NSError *error = nil;
	if(![listenSocket connectToHost:ip onPort:port error:&error])
	{
		[delegate logMessage: [NSString stringWithFormat:@"Error starting client: %@", error]];
		[delegate disconnectedFromServer];
	}
}
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
	[delegate logMessage:@"Stopped Echo server"];
	isRunning = false;	
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	isRunning = YES;
	[delegate logMessage: [NSString stringWithFormat:@"Accepted server %@:%hu", host, port]];
	
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
	[delegate connectedToServer];
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
		[delegate logMessage:[NSString stringWithFormat:@"Server Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort]]];
	} else {
		[delegate logMessage:@"Unable to Connect to Server"];
	}
	isRunning = NO;
	[delegate disconnectedFromServer];
	//[connectedSockets removeObject:sock];
}

@end
