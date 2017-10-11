#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "AsyncUdpSocket.h"

@interface NetworkingController : NSObject {
	GCDAsyncSocket *listenSocket;
	AsyncUdpSocket *listenUdpSocket;
	BOOL isRunning;
	int udpID;
	
	NSString* hostString;
	int portNum;
}
@property(nonatomic) BOOL isRunning;
@property(nonatomic,assign) GCDAsyncSocket* listenSocket;
@property(nonatomic,assign) AsyncUdpSocket* listenUdpSocket;
- (void)connectIP:(NSString*)ip port:(int)port;
- (void)disconnect;
- (void)sendString:(NSString*)string;
- (void)sendData:(NSData*)data;

- (void)sendUdpData:(NSData*)data;

@end
