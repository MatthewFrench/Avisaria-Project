//
//  Chat_ServerAppDelegate.m
//  Chat Server
//
//  Created by Matthew French on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

//CLIENT RECIEVE SIDE
//0 = New Player
//1 = Update Player - Player Num - 0 = Pos - X - Y
//1 = Update Player - Player Num - 1 = Pressed - Key
//1 = Update Player - Player Num - 2 = Depressed - Key
//1 = Update Player - Player Num - 3 = Username - name
//2 = Delete Player - Player Num
//3 = Message
#define ClientActionNewPlayer 0
#define ClientActionUpdatePlayer 1
#define ClientActionUpdatePlayerPosition 0
#define ClientActionUpdatePlayerPressed 1
#define ClientActionUpdatePlayerDepressed 2
#define ClientActionUpdatePlayerUsername 3
#define ClientActionUpdatePlayerVelocity 4
#define ClientActionDeletePlayer 2
#define ClientActionRecieveMessage 3

//SERVER RECIEVE SIDE
//0 = Pressed - 0 = Left
//0 = Pressed - 1 = Right
//0 = Pressed - 2 = Up
//0 = Pressed - 3 = Down
//1 = Depressed - 0 = Left
//1 = Depressed - 1 = Right
//1 = Depressed - 2 = Up
//1 = Depressed - 3 = Down
//2 = Message
//3 = Name Change
//4 = Udp Connect
#define ServerActionPressed 0
#define ServerActionDepressed 1
#define ServerActionArrowLeft 0
#define ServerActionArrowRight 1
#define ServerActionArrowUp 2
#define ServerActionArrowDown 3
#define ServerActionMessage 2
#define ServerActionNameChange 3
#define ServerActionUdp 4


#define overflow 20

@implementation AppDelegate

@synthesize window,players;

- (void)tick {
	if (players) {
		CGPoint position,velocity;
		BOOL touchingGround = FALSE;
		for (int i = 0; i < [players count]; i ++) {
			Player* player = [players objectAtIndex:i];
			position = player.position;
			velocity = player.velocity;
			
			//Add the Velocities but make sure it doesn't pass overflow
			if (abs(velocity.y) > overflow) {
				if (velocity.y > overflow) {
					position.y += overflow;
				}
				if (velocity.y < -overflow) {
					position.y -= overflow;
				}
			} else {
				position.y += velocity.y;
			}
			if (abs(velocity.x) > overflow) {
				if (velocity.x > overflow) {
					position.x += overflow;
				}
				if (velocity.x < -overflow) {
					position.x -= overflow;
				}
			} else {
				position.x += velocity.x;
			}
			//Ball Collision
			for (int j = i + 1; j < [players count]; j ++) {
				Player* collideBall = [players objectAtIndex:j];
				
				if ([self collisionOfCircles:CGPointMake(ceil(position.x+25), ceil(position.y+25)) rad:25
										  c2:CGPointMake(ceil(collideBall.position.x+25), ceil(collideBall.position.y+25)) rad:25]) {
					double x, y, d2;
					if (position.x == collideBall.position.x && position.y == collideBall.position.y) {
						collideBall.position = CGPointMake(collideBall.position.x, collideBall.position.y+1);
					}
					// displacement from i to j
					y = (collideBall.position.y - position.y);
					x = (collideBall.position.x - position.x);
					
					// distance squared
					d2 = x * x + y * y;
					if (d2 == 0) {d2 = 1;}
					
					double kii, kji, kij, kjj;
					
					kji = (x * velocity.x + y * velocity.y) / d2; // k of j due to i
					kii = (x * velocity.y - y * velocity.x) / d2; // k of i due to i
					kij = (x * collideBall.velocity.x + y * collideBall.velocity.y) / d2; // k of i due to j
					kjj = (x *collideBall.velocity.y - y * collideBall.velocity.x) / d2; // k of j due to j
					
					// set velocity of i
					velocity.x = kij * x - kii * y;
					velocity.y = kij * y + kii * x;
					
					// set velocity of j
					collideBall.velocity = CGPointMake(kji * x - kjj * y, kji * y + kjj * x);
					
					// the ratio between what it should be and what it really is
					float k = ((25*2+25*2)/2.0+0.1) / sqrt(d2);
					
					// difference between x and y component of the two vectors
					y *= (k - 1) / 2;
					x *= (k - 1) / 2;
					
					// set new coordinates of disks
					position.x -= x;
					position.y -= y;
					collideBall.position = CGPointMake(collideBall.position.x + x,collideBall.position.y + y);
					//j.y += y;
					//j.x += x;
					//i.y -= y;
					//i.x -= x;
					collideBall.updateClient = TRUE;
					player.updateClient = TRUE;
				}
			}
			
			//Detect if touching ground
			if (position.y > 150) {
				//Apply Gravity
				touchingGround = FALSE;
				velocity.y -= 1;
			} else {
				//Stick on ground and reverse velocity
				position.y = 150;
				touchingGround = TRUE;
				velocity.y *= -0.5;
				if (abs(velocity.y) < 2) {
					velocity.y = 0;
				}
			}
			//Apply ground friction
			if (touchingGround) {
				velocity.x *= 0.9;
				if (abs(velocity.x) < 0.01) {
					velocity.x = 0;
				}
			}
			//If hit wall or ceiling
			if (position.x < 25) {
				position.x = 25;
				velocity.x *= -0.9;
			}
			if (position.x > 843 - 25) {
				position.x = 843 - 25;
				velocity.x *= -0.9;
			}
			if (position.y > 629 - 25) {
				position.y = 629 - 25;
				velocity.y *= -0.9;
			}
			//Detect key presses
			if (player.leftArrow) {velocity.x -= 3;}
			if (player.rightArrow) {velocity.x += 3;}
			if (player.upArrow) {
				//Jump
				if (touchingGround) {
					velocity.y += 20;
				}
			}
			if (abs(player.velocity.x-velocity.x) >= 1 && abs(player.velocity.y-velocity.y) >= 1) {player.updateClient = TRUE;}
			if (abs(player.position.x-position.x) >= 1 && abs(player.position.y-position.y) >= 1) {player.updateClient = TRUE;}
			player.velocity = velocity;
			player.position = position;
			player.updateCount += 1;
			if (player.updateCount >= 30 && player.updateClient) {
				[networkController sendUdpDataToAll:[self dataUpdatePlayerPos:i]];
				[networkController sendUdpDataToAll:[self dataUpdatePlayerVel:i]];
				player.updateCount = 0;
				player.updateClient = FALSE;
			}
		}
	}
}

- (void)activateKeyPress:(int)key Player:(int)num {
	Player* player = [players objectAtIndex:num];
	BOOL pressed = FALSE;
	if (key == ServerActionArrowLeft) {
		pressed = player.leftArrow;
		player.leftArrow = TRUE;
	}
	if (key == ServerActionArrowRight) {
		pressed = player.rightArrow;
		player.rightArrow = TRUE;
	}
	if (key == ServerActionArrowUp) {
		pressed = player.upArrow;
		player.upArrow = TRUE;
	}
	if (key == ServerActionArrowDown) {
		pressed = player.downArrow;
		player.downArrow = TRUE;
	}
	if (!pressed) {
		[networkController sendUdpDataToAll:[self dataUpdatePlayerPos:num]];
		[networkController sendUdpDataToAll:[self dataUpdatePlayerVel:num]];
		[networkController sendUdpDataToAll:[self dataUpdatePlayerPressed:num key:key]];
		//[networkController sendDataToAll:[self dataUpdatePlayerPressed:num key:key]];
	}
}
- (void)activateKeyDepress:(int)key Player:(int)num {
	Player* player = [players objectAtIndex:num];
	BOOL pressed = FALSE;
	if (key == ServerActionArrowLeft) {
		pressed = player.leftArrow;
		player.leftArrow = FALSE;
	}
	if (key == ServerActionArrowRight) {
		pressed = player.rightArrow;
		player.rightArrow = FALSE;
	}
	if (key == ServerActionArrowUp) {
		pressed = player.upArrow;
		player.upArrow = FALSE;
	}
	if (key == ServerActionArrowDown) {
		pressed = player.downArrow;
		player.downArrow = FALSE;
	}
	if (pressed) {
		[networkController sendUdpDataToAll:[self dataUpdatePlayerPos:num]];
		[networkController sendUdpDataToAll:[self dataUpdatePlayerVel:num]];
		[networkController sendUdpDataToAll:[self dataUpdatePlayerDepressed:num key:key]];
		//[networkController sendDataToAll:[self dataUpdatePlayerDepressed:num key:key]];
	}
}
- (void)activateRecieveMessage:(NSString*)message Player:(int)num {
	[self logMessage:message];
	[networkController sendDataToAll:[self dataMessage:message]];
}
- (void)activateNameChange:(NSString*)name Player:(int)num {
	Player* player = [players objectAtIndex:num];
	[self logMessage:[NSString stringWithFormat:@"%@ changed their name to %@",player.username,name]];
	if (player.username) {[player.username release];}
	player.username = [[NSString alloc] initWithString:name];
	[networkController sendDataToAll:[self dataNameChange:num]];
}
- (void)recievedMessage:(NSData*)data from:(int)num with:(int)dataPos {
	unsigned char action = [self getUnsignedCharFrom:data byteStart:&dataPos];

	switch (action) {
		case ServerActionPressed: {
			unsigned char key = [self getUnsignedCharFrom:data byteStart:&dataPos];
			[self activateKeyPress:key Player:num];
			break;
		}
		case ServerActionDepressed: {
			unsigned char key = [self getUnsignedCharFrom:data byteStart:&dataPos];
			[self activateKeyDepress:key Player:num];
			break;
		}
		case ServerActionMessage: {
			NSString* message = [self getNSStringFrom:data byteStart:&dataPos length:[data length] - dataPos];
			[self activateRecieveMessage:message Player:num];
			break;
		}
		case ServerActionNameChange: {
			NSString* name = [self getNSStringFrom:data byteStart:&dataPos length:[data length] - dataPos];
			[self activateNameChange:name Player:num];
			break;
		}
		case ServerActionUdp: {
			unsigned int port = [self getUnsignedIntFrom:data byteStart:&dataPos];
			[networkController initUdpSocket:port Player:num];
			NSLog(@"Port: %d",port);
			break;
		}
		default: {
			break;
		}	
	}
}
- (void)recievedUdpMessage:(NSData*)data player:(int)num {
	int dataPos = 0;
	unsigned char action = [self getUnsignedCharFrom:data byteStart:&dataPos];
	switch (action) {
		case ServerActionPressed: {
			unsigned char key = [self getUnsignedCharFrom:data byteStart:&dataPos];
			[self activateKeyPress:key Player:num];
			break;
		}
		case ServerActionDepressed: {
			unsigned char key = [self getUnsignedCharFrom:data byteStart:&dataPos];
			[self activateKeyDepress:key Player:num];
			break;
		}
		default: {
			break;
		}	
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[logView setString:@""];
	networkController = [[NetworkingController alloc] init];
	
	timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
											 target: self
										   selector: @selector(tick)
										   userInfo: nil
											repeats: YES];
}
- (IBAction)startStop:(id)sender{
	if(!networkController.isRunning)
	{
		int port = [portField intValue];
		if(port < 0 || port > 65535)
		{
			port = 0;
		}
		[networkController startServerOnPort:port];
		[portField setEnabled:NO];
		[startStopButton setTitle:@"Stop"];
		players = [NSMutableArray new];
	}
	else
	{
		[networkController stopServer];
		
		[portField setEnabled:YES];
		[startStopButton setTitle:@"Start"];
		[players removeAllObjects];
		[players release];
		players = nil;
	}
}
- (void)clientConnected:(int)num {
	Player* player = [[Player alloc] init];
	[players addObject:player];
	[player release];
	
	[networkController sendDataToAll:[self dataNewPlayer] except:num];
	
	for (int i = 0; i < [players count]; i ++) {
		
		[networkController sendData:[self dataNewPlayer] to:num];
		
		[networkController sendData:[self dataUpdatePlayerPos:i] to:num];
		
		[networkController sendData:[self dataNameChange:i] to:num];
	}
}
- (void)clientDisconnected:(int)num {
	[players removeObjectAtIndex:num];

	[networkController sendDataToAll:[self dataDeletePlayer:num]];
}
- (void)scrollToBottom {
	NSScrollView *scrollView = [logView enclosingScrollView];
	[[scrollView documentView] scrollPoint:NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]))];
}
- (void)logMessage:(NSString*)message {
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", message];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	[as autorelease];
	
	[[logView textStorage] appendAttributedString:as];
	[self scrollToBottom];
}

- (NSData*)dataNewPlayer {
	unsigned char action = 0;
	return [NSMutableData dataWithBytes:&action length:sizeof(action)];
}
- (NSData*)dataUpdatePlayerPos:(int)num {
	Player* player = [players objectAtIndex:num];
	unsigned char action = 1;
	unsigned int playerNum = num;
	unsigned char updateAction = 0;
	float x = player.position.x;
	float y = player.position.y;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&playerNum length:sizeof(playerNum)];
	[data appendBytes:&updateAction length:sizeof(updateAction)];
	[data appendBytes:&x length:sizeof(x)];
	[data appendBytes:&y length:sizeof(y)];
	return data;
}
- (NSData*)dataUpdatePlayerVel:(int)num {
	Player* player = [players objectAtIndex:num];
	unsigned char action = ClientActionUpdatePlayer;
	unsigned int playerNum = num;
	unsigned char updateAction = ClientActionUpdatePlayerVelocity;
	float x = player.velocity.x;
	float y = player.velocity.y;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&playerNum length:sizeof(playerNum)];
	[data appendBytes:&updateAction length:sizeof(updateAction)];
	[data appendBytes:&x length:sizeof(x)];
	[data appendBytes:&y length:sizeof(y)];
	return data;
}
- (NSData*)dataUpdatePlayerPressed:(int)num key:(int)key {
	//0 = Pressed - 0 = Left
	//0 = Pressed - 1 = Right
	//0 = Pressed - 2 = Up
	//0 = Pressed - 3 = Down-
	unsigned char action = 1;
	unsigned int playerNum = num;
	unsigned char updateAction = 1;
	unsigned char keyPress = key;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&playerNum length:sizeof(playerNum)];
	[data appendBytes:&updateAction length:sizeof(updateAction)];
	[data appendBytes:&keyPress length:sizeof(keyPress)];
	return data;
}
- (NSData*)dataUpdatePlayerDepressed:(int)num key:(int)key {
	//0 = Pressed - 0 = Left
	//0 = Pressed - 1 = Right
	//0 = Pressed - 2 = Up
	//0 = Pressed - 3 = Down-
	unsigned char action = 1;
	unsigned int playerNum = num;
	unsigned char updateAction = 2;
	unsigned char keyPress = key;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&playerNum length:sizeof(playerNum)];
	[data appendBytes:&updateAction length:sizeof(updateAction)];
	[data appendBytes:&keyPress length:sizeof(keyPress)];
	return data;
}
- (NSData*)dataDeletePlayer:(int)num {
	unsigned char action = 2;
	unsigned int player = num;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&player length:sizeof(player)];
	return data;
}
- (NSData*)dataMessage:(NSString*)msg {
	unsigned char action = 3;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
	return data;
}
- (NSData*)dataNameChange:(int)num {
	Player* player = [players objectAtIndex:num];
	unsigned char action = 1;
	unsigned int playerNum = num;
	unsigned char updateAction = 3;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&playerNum length:sizeof(playerNum)];
	[data appendBytes:&updateAction length:sizeof(updateAction)];
	[data appendData:[player.username dataUsingEncoding:NSUTF8StringEncoding]];
	return data;
}
- (unsigned char)getUnsignedCharFrom:(NSData*)data byteStart:(int*)byteStart {
	unsigned char var;
	[data getBytes:&var range:NSMakeRange(*byteStart, sizeof(unsigned char))];
	*byteStart += sizeof(unsigned char);
	return var;
}
- (unsigned int)getUnsignedIntFrom:(NSData*)data byteStart:(int*)byteStart {
	unsigned int var;
	[data getBytes:&var range:NSMakeRange(*byteStart, sizeof(unsigned int))];
	*byteStart += sizeof(unsigned int);
	return var;
}
- (signed short int)getSignedShortIntFrom:(NSData*)data byteStart:(int*)byteStart {
	signed short int var;
	[data getBytes:&var range:NSMakeRange(*byteStart, sizeof(signed short int))];
	*byteStart += sizeof(signed short int);
	return var;
}
- (float)getFloatFrom:(NSData*)data byteStart:(int*)byteStart {
	float var;
	[data getBytes:&var range:NSMakeRange(*byteStart, sizeof(float))];
	*byteStart += sizeof(float);
	return var;
}
- (NSString*)getNSStringFrom:(NSData*)data byteStart:(int*)byteStart length:(int)length {
	Byte buff[length];
	[data getBytes:&buff range:NSMakeRange(*byteStart, length)];
	*byteStart += length;
	NSString* message = 
	[[NSString alloc] initWithBytes:&buff length:length encoding:NSUTF8StringEncoding];
	return [message autorelease];
}


- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r  {
	float a, dx, dy, d, h, rx, ry;
	float x2, y2;
	
	/* dx and dy are the vertical and horizontal distances between
	 * the circle centers.
	 */
	dx = c2.x - c1.x;
	dy = c2.y - c1.y;
	
	/* Determine the straight-line distance between the centers. */
	//d = sqrt((dy*dy) + (dx*dx));
	d = hypot(dx,dy); // Suggested by Keith Briggs
	
	/* Check for solvability. */
	if (d > (c1r + c2r))
	{
		/* no solution. circles do not intersect. */
		return FALSE;
	}
	if (d < abs(c1r - c2r))
	{
		/* no solution. one circle is contained in the other */
		return TRUE;
	}
	
	/* 'point 2' is the point where the line through the circle
	 * intersection points crosses the line between the circle
	 * centers.  
	 */
	
	/* Determine the distance from point 0 to point 2. */
	a = ((c1r*c1r) - (c2r*c2r) + (d*d)) / (2.0 * d) ;
	
	/* Determine the coordinates of point 2. */
	x2 = c1.x + (dx * a/d);
	y2 = c1.y + (dy * a/d);
	
	/* Determine the distance from point 2 to either of the
	 * intersection points.
	 */
	h = sqrt((c1r*c1r) - (a*a));
	
	/* Now determine the offsets of the intersection points from
	 * point 2.
	 */
	rx = -dy * (h/d);
	ry = dx * (h/d);
	
	/* Determine the absolute intersection points. */
	
	return TRUE;
}
@end
