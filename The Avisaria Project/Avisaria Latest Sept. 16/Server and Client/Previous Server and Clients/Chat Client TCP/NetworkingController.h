//
//  NetworkingController.h
//  EchoClient
//
//  Created by Matthew French on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"

@interface NetworkingController : NSObject {
	AsyncSocket *listenSocket;
	BOOL isRunning;
}
@property(nonatomic) BOOL isRunning;
- (void)setUp;
- (void)connectIP:(NSString*)ip port:(int)port;
- (void)disconnect;
- (void)sendString:(NSString*)string;
- (void)sendData:(NSMutableData*)data;

@end
