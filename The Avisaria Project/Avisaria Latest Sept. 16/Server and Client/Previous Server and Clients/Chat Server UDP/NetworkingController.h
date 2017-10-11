//
//  NetworkingController.h
//  Chat Server
//
//  Created by Matthew French on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncUdpSocket.h"

@interface NetworkingController : NSObject {
	AsyncUdpSocket *listenSocket;
	NSMutableArray *connectedSockets;
	
	BOOL isRunning;
	
}
@property(nonatomic) BOOL isRunning;
- (void)startServerOnPort:(int)port;
- (void)stopServer;
- (void)sendDataToAll:(NSData*)data;
@end
