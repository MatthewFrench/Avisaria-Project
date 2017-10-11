//
//  NetworkingController.h
//  Chat Server
//
//  Created by Matthew French on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "AsyncUdpSocket.h"

@interface NetworkingController : NSObject {
	dispatch_queue_t socketQueue;
	
	GCDAsyncSocket *listenSocket;
	AsyncUdpSocket *listenUdpSocket;
	NSMutableArray *connectedSockets,*udpPorts;
	
	BOOL isRunning;
	
}
@property(nonatomic) BOOL isRunning;
- (void)startServerOnPort:(int)port;
- (void)stopServer;
- (void)sendDataToAll:(NSData*)data;
- (void)sendDataToAll:(NSData*)data except:(int)num;
- (void)sendData:(NSData*)data to:(int)num;

- (void)sendUdpDataToAll:(NSData*)data except:(int)num;
- (void)sendUdpData:(NSData*)data to:(int)num;
- (void)sendUdpDataToAll:(NSData*)data;

- (void)initUdpSocket:(int)port Player:(int)num;
@end
