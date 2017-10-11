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
#define ClientActionIsPlayer 4

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

@synthesize window;


- (void)tick {
	/**
	[CATransaction begin];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[CATransaction setValue:[NSNumber numberWithFloat:1.0/60.0] forKey:kCATransactionAnimationDuration];
	if (players) {
		for (int i = 0; i < [players count]; i ++) {
			Player* player = [players objectAtIndex:i];
						
			//player.textLayer.position = CGPointMake(position.x, position.y + 20);
		}
	}
	[CATransaction commit];
	 **/
}
- (void)updateWorld {
	if (isPlayer > -1 && isPlayer < [players count]) {
		Player* clientPlayer = [players objectAtIndex:isPlayer];
		//Set the client player to the middle
		clientPlayer.layer.position = CGPointMake(844/2, 506/2);
		clientPlayer.textLayer.position = CGPointMake(844/2, 506/2+20);
		//Set the world position
		worldLayer.position = CGPointMake(-clientPlayer.position.x*44+844/2+playerImage.size.width/2, -clientPlayer.position.y*44+506/2+playerImage.size.height/2);
		
		for (int i = 0; i < [players count]; i ++) {
			if (i != isPlayer) {
				Player* player = [players objectAtIndex:i];
				player.layer.position = CGPointMake(player.position.x*44-clientPlayer.position.x*44+844/2, player.position.y*44-clientPlayer.position.y*44+506/2);
				player.textLayer.position = CGPointMake(player.position.x*44-clientPlayer.position.x*44+844/2, player.position.y*44-clientPlayer.position.y*44+506/2+20);
			}
		}
	}
}


- (void)activateNewPlayer {
	Player* player = [[Player alloc] init];
	[players addObject:player];
	[player release];
	
	player.layer.contents = playerImage;
	[player.layer setFrame:CGRectMake(0, 0, playerImage.size.width, playerImage.size.height)];
	[player.layer setPosition:CGPointMake(0, 0)];
	[gameView.rootLayer addSublayer:player.layer];
	[gameView.rootLayer addSublayer:player.textLayer];
	[self updateWorld];
}
- (void)activateUpdatePlayer:(NSData*)data dataPos:(int)dataPos {
	unsigned int playerNum = [self getUnsignedIntFrom:data byteStart:&dataPos];
	Player* player = [players objectAtIndex:playerNum];
	
	unsigned char updateAction = [self getUnsignedCharFrom:data byteStart:&dataPos];
	
	switch (updateAction)
	{
		case ClientActionUpdatePlayerPosition:{
			float x = [self getFloatFrom:data byteStart:&dataPos];
			float y = [self getFloatFrom:data byteStart:&dataPos];
			player.position = CGPointMake(x+1, y);
			[self updateWorld];
			break;
		}
		case ClientActionUpdatePlayerPressed:{
			unsigned char key = [self getUnsignedCharFrom:data byteStart:&dataPos];
			if (key == 0) {
				player.leftArrow = TRUE;
			}
			if (key == 1) {
				player.rightArrow = TRUE;
			}
			if (key == 2) {
				player.upArrow = TRUE;
			}
			if (key == 3) {
				player.downArrow = TRUE;
			}
			break;
		}
		case ClientActionUpdatePlayerDepressed:{
			unsigned char key = [self getUnsignedCharFrom:data byteStart:&dataPos];
			if (key == 0) {
				player.leftArrow = FALSE;
			}
			if (key == 1) {
				player.rightArrow = FALSE;
			}
			if (key == 2) {
				player.upArrow = FALSE;
			}
			if (key == 3) {
				player.downArrow = FALSE;
			}
			break;
		}
		case ClientActionUpdatePlayerUsername:{
			NSString* name = [self getNSStringFrom:data byteStart:&dataPos length:[data length] - dataPos];
			if (player.username) {[player.username release];}
			player.username = [[NSString alloc] initWithString:name];
			player.textLayer.string = player.username;
			player.textLayer.font = [NSFont fontWithName:@"Helvetica" size:10];
			player.textLayer.fontSize = 14;
			if (isPlayer == playerNum) {
				CGColorRef fgColor = CGColorCreateGenericRGB(0.0, 0.0, 1.0, 1.0);
				player.textLayer.foregroundColor = fgColor;
				CGColorRelease(fgColor);
			} else {
				CGColorRef fgColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
				player.textLayer.foregroundColor = fgColor;
				CGColorRelease(fgColor);
			}
			player.textLayer.wrapped = NO;
			//player.textLayer.foregroundColor=CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
			[player.textLayer setFrame:CGRectMake(0, 0, [self widthOfString:name withFont:[NSFont fontWithName:@"Helvetica" size:14]], 36)];
			player.textLayer.anchorPoint = CGPointMake(0.5, 0.5);
			player.textLayer.position = CGPointMake(player.position.x*44, player.position.y*44+20);
			[self updateWorld];
			break;
		}
		case ClientActionUpdatePlayerVelocity:{
			float x = [self getFloatFrom:data byteStart:&dataPos];
			float y = [self getFloatFrom:data byteStart:&dataPos];
			player.velocity = CGPointMake(x, y);
			break;
		}
		default:{
			break;
		}	
	}

}
- (void)activateDeletePlayer:(int)num {
	Player* playerObj = [players objectAtIndex:num];
	[playerObj.layer removeFromSuperlayer];
	[playerObj.textLayer removeFromSuperlayer];
	[players removeObjectAtIndex:num];
	if (num < isPlayer) {isPlayer -= 1;}
}
- (void)activateRecieveMessage:(NSData*)data dataPos:(int)dataPos {
	NSString* message = [self getNSStringFrom:data byteStart:&dataPos length:[data length] - dataPos];
	[self logMessage:message];
}
- (void)recievedMessage:(NSData*)data {
	data = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	int dataPos = 0;
	unsigned char action = [self getUnsignedCharFrom:data byteStart:&dataPos];
	
	switch (action) {
		case ClientActionNewPlayer: {
			[self activateNewPlayer];
			break;
		}
		case ClientActionUpdatePlayer: {
			[self activateUpdatePlayer:data dataPos:dataPos];
			break;
		}
		case ClientActionDeletePlayer: {
			unsigned int player = [self getUnsignedIntFrom:data byteStart:&dataPos];
			[self activateDeletePlayer:player];
			break;
		}
		case ClientActionRecieveMessage: {
			[self activateRecieveMessage:data dataPos:dataPos];
			break;
		}
		case ClientActionIsPlayer: {
			isPlayer = [self getUnsignedIntFrom:data byteStart:&dataPos];
			Player* player = [players objectAtIndex:isPlayer];
			NSLog(@"Recieved an is player %d",isPlayer);
			CGColorRef fgColor = CGColorCreateGenericRGB(0.0, 0.0, 1.0, 1.0);
			player.textLayer.foregroundColor = fgColor;
			CGColorRelease(fgColor);
			[self updateWorld];
			break;
		}
		default: {
			break;
		}	
	}
}
- (void)recievedUdpMessage:(NSData*)data {
	int dataPos = 1;
	unsigned char action = [self getUnsignedCharFrom:data byteStart:&dataPos];
	switch (action) {
		case ClientActionUpdatePlayer: {
			[self activateUpdatePlayer:data dataPos:dataPos];
			break;
		}
		default: {
			break;
		}	
	}
	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	networkController = [[NetworkingController alloc] init];
	[logView setString:@""];
	worldImage = [NSImage imageNamed:@"room1.gif"];
	[worldImage retain];
	playerImage = [NSImage imageNamed:@"humanM1.gif"];
	[playerImage retain];
	players = [[NSMutableArray alloc] init];
	[[self window] makeFirstResponder:gameView];
	srand(time(NULL));
	isPlayer = -1;
	
	worldLayer = [CALayer layer];
	[worldLayer retain];
	worldLayer.contents = worldImage;
	[worldLayer setFrame:CGRectMake(0, 0, worldImage.size.width, worldImage.size.height)];
	[worldLayer setAnchorPoint:CGPointMake(0, 0)];
	[worldLayer setPosition:CGPointMake(0,0)];
	
	//***Turn on Game Timer
	timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
											 target: self
										   selector: @selector(tick)
										   userInfo: nil
											repeats: YES];
}
- (void)connectedToServer {
	[portField setEnabled:NO];
	[startStopButton setTitle:@"Stop"];
	
	[gameView.rootLayer addSublayer:worldLayer];
	
	[networkController sendData:[self dataNameChange:[username stringValue]]];
}
- (void)disconnectedFromServer {
	[portField setEnabled:YES];
	[startStopButton setTitle:@"Start"];
	for (int i = 0; i < [players count]; i ++) {
		Player* playerObj = [players objectAtIndex:i];
		[playerObj.layer removeFromSuperlayer];
		[playerObj.textLayer removeFromSuperlayer];
	}
	[players removeAllObjects];
	[worldLayer removeFromSuperlayer];
}

- (IBAction)startStop:(id)sender {
	if(!networkController.isRunning)
	{
		int port = [portField intValue];
		if(port < 0 || port > 65535)
		{
			port = 0;
		}
		
		[networkController connectIP:[ipField stringValue] port:port];
	}
	else
	{
		[networkController disconnect];
	}
}
- (void)keyDown:(int)key {
	if (key == NSLeftArrowFunctionKey) {
		if (!leftArrow) {
			[networkController sendUdpData:[self dataKeyPress:0]];
			[networkController sendData:[self dataKeyPress:0]];
			//[networkController sendData:[self dataKeyPress:0]];
			leftArrow = TRUE;
		}
	}
	if (key == NSRightArrowFunctionKey) {
		if (!rightArrow) {
			[networkController sendUdpData:[self dataKeyPress:1]];
			[networkController sendData:[self dataKeyPress:1]];
			//[networkController sendData:[self dataKeyPress:1]];
			rightArrow = TRUE;
		}
	}
	if (key == NSUpArrowFunctionKey) {
		if (!upArrow) {
			[networkController sendUdpData:[self dataKeyPress:2]];
			[networkController sendData:[self dataKeyPress:2]];
			//[networkController sendData:[self dataKeyPress:2]];
			upArrow = TRUE;
		}
	}
	if (key == NSDownArrowFunctionKey) {
		if (!downArrow) {
			[networkController sendUdpData:[self dataKeyPress:3]];
			[networkController sendData:[self dataKeyPress:3]];
			//[networkController sendData:[self dataKeyPress:3]];
			downArrow = TRUE;
		}
	}
	if (key == NSEnterCharacter || key == 13) {
		[[self window] makeFirstResponder:textField];
	}
}
- (void)keyUp:(int)key {
	if (key == NSLeftArrowFunctionKey) {
		if (leftArrow) {
			[networkController sendUdpData:[self dataKeyDepress:0]];
			[networkController sendData:[self dataKeyDepress:0]];
			leftArrow = FALSE;
		}
	}
	if (key == NSRightArrowFunctionKey) {
		if (rightArrow) {
			[networkController sendUdpData:[self dataKeyDepress:1]];
			[networkController sendData:[self dataKeyDepress:1]];
			rightArrow = FALSE;
		}
	}
	if (key == NSUpArrowFunctionKey) {
		if (upArrow) {
			[networkController sendUdpData:[self dataKeyDepress:2]];
			[networkController sendData:[self dataKeyDepress:2]];
			upArrow = FALSE;
		}
	}
	if (key == NSDownArrowFunctionKey) {
		if (downArrow) {
			[networkController sendUdpData:[self dataKeyDepress:3]];
			[networkController sendData:[self dataKeyDepress:3]];
			downArrow = FALSE;
		}
	}
}
- (IBAction)sendMessage:(id)sender {
	if ([[textField stringValue] length] > 0) {
		[networkController sendData:[self dataMessage:[NSString stringWithFormat:@"%@%@\"%@\"",[username stringValue],[self generateAction],[textField stringValue]]]];
		[textField setStringValue:@""];
		[[self window] makeFirstResponder:gameView];
	}
}
- (IBAction)updateName:(id)sender {
	[networkController sendData:[self dataNameChange:[username stringValue]]];
	[[self window] makeFirstResponder:gameView];
}
- (NSString*)generateAction {
	int num = rand() % 14; //Gives a number between 0 and 13 inclusive.
	if (num == 0) {return @" said ";}
	if (num == 1) {return @" screamed ";}
	if (num == 2) {return @" cried ";}
	if (num == 3) {return @" yelled ";}
	if (num == 4) {return @" whimpered ";}
	if (num == 5) {return @" barked ";}
	if (num == 6) {return @" giggled ";}
	if (num == 7) {return @" preached ";}
	if (num == 8) {return @" retorted ";}
	if (num == 9) {return @" stammered ";}
	if (num == 10) {return @" mumbled ";}
	if (num == 11) {return @" begged ";}
	if (num == 12) {return @" retorted ";}
	if (num == 13) {return @" laughed ";}
	return nil;
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
- (void)scrollToBottom {
	NSScrollView *scrollView = [logView enclosingScrollView];
	[[scrollView documentView] scrollPoint:NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]))];
}
- (NSData*)dataUdpInfo {
	unsigned char action = ServerActionUdp;
	unsigned int port = [networkController.listenUdpSocket localPort];
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&port length:sizeof(port)];
	return data;
}
- (NSData*)dataKeyPress:(int)num {
	//0 = Pressed - 0 = Left
	//0 = Pressed - 1 = Right
	//0 = Pressed - 2 = Up
	//0 = Pressed - 3 = Down-
	unsigned char action = 0;
	unsigned char key = num;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&key length:sizeof(key)];
	return data;
}
- (NSData*)dataKeyDepress:(int)num {
	
	//0 = Pressed - 0 = Left
	//0 = Pressed - 1 = Right
	//0 = Pressed - 2 = Up
	//0 = Pressed - 3 = Down-
	unsigned char action = 1;
	unsigned char key = num;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendBytes:&key length:sizeof(key)];
	return data;
}
- (NSData*)dataMessage:(NSString*)msg {
	unsigned char action = 2;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
	
	return data;
}
- (NSData*)dataNameChange:(NSString*)msg {
	unsigned char action = 3;
	NSMutableData* data = [NSMutableData dataWithBytes:&action length:sizeof(action)];
	[data appendData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
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
- (NSString*)getNSStringFrom:(NSData*)data byteStart:(int*)byteStart length:(int)length {
	Byte buff[length];
	[data getBytes:&buff range:NSMakeRange(*byteStart, length)];
	*byteStart += length;
	NSString* message = 
	[[NSString alloc] initWithBytes:&buff length:length encoding:NSUTF8StringEncoding];
	return [message autorelease];
}
- (float)getFloatFrom:(NSData*)data byteStart:(int*)byteStart {
	float var;
	[data getBytes:&var range:NSMakeRange(*byteStart, sizeof(float))];
	*byteStart += sizeof(float);
	return var;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	return [[[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease] size].width;
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

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end