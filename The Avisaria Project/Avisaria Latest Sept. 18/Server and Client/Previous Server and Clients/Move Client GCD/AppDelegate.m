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
#define ServerActionPressed 0
#define ServerActionDepressed 1
#define ServerActionArrowLeft 0
#define ServerActionArrowRight 1
#define ServerActionArrowUp 2
#define ServerActionArrowDown 3
#define ServerActionMessage 2
#define ServerActionNameChange 3

@implementation AppDelegate

@synthesize window;


- (void)tick {
	[CATransaction begin];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[CATransaction setValue:[NSNumber numberWithFloat:1.0/60.0] forKey:kCATransactionAnimationDuration];
	if (players) {
		for (int i = 0; i < [players count]; i ++) {
			Player* player = [players objectAtIndex:i];
				if (player.leftArrow) {player.position = CGPointMake(player.position.x - 4, player.position.y);}
				if (player.rightArrow) {player.position = CGPointMake(player.position.x + 4, player.position.y);}
				if (player.upArrow) {player.position = CGPointMake(player.position.x, player.position.y + 4);}
				if (player.downArrow) {player.position = CGPointMake(player.position.x, player.position.y - 4);}
			player.layer.position = player.position;
			player.textLayer.position = CGPointMake(player.position.x, player.position.y + 20);
		}
	}
	[CATransaction commit];
}

- (void)activateNewPlayer {
	Player* player = [Player new];
	[players addObject:player];
	[player release];
	
	player.layer.contents = guy;
	[player.layer setFrame:CGRectMake(0, 0, guy.size.width, guy.size.height)];
	[player.layer setPosition:CGPointMake(0, 0)];
	[gameView.rootLayer addSublayer:player.layer];
	[gameView.rootLayer addSublayer:player.textLayer];
}
- (void)activateUpdatePlayer:(NSData*)data dataPos:(int)dataPos {
	unsigned int playerNum = [self getUnsignedIntFrom:data byteStart:&dataPos];
	Player* player = [players objectAtIndex:playerNum];
	
	unsigned char updateAction = [self getUnsignedCharFrom:data byteStart:&dataPos];
	
	switch (updateAction)
	{
		case ClientActionUpdatePlayerPosition:{
			signed short int x = [self getSignedShortIntFrom:data byteStart:&dataPos];
			signed short int y = [self getSignedShortIntFrom:data byteStart:&dataPos];
			player.position = CGPointMake(x, y);
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
			[player.textLayer setString:player.username];
			player.textLayer.font = [NSFont fontWithName:@"Helvetica" size:10];
			player.textLayer.fontSize = 14;
			
			player.textLayer.wrapped = NO;
			player.textLayer.foregroundColor=CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
			[player.textLayer setFrame:CGRectMake(0, 0, [name length]*12, 30)];
			player.textLayer.anchorPoint = CGPointMake(0.5, 0.5);
			break;
		}
		default:{
			break;
		}	
	}
}
- (void)activateDeletePlayer:(int)num {
	//Player* playerObj = [players objectAtIndex:num];
	[players removeObjectAtIndex:num];
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
		default: {
			break;
		}	
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	networkController = [[NetworkingController alloc] init];
	[logView setString:@""];
	guy = [NSImage imageNamed:@"stickman.png"];
	[guy retain];
	players = [NSMutableArray new];
	[[self window] makeFirstResponder:gameView];
	srand(time(NULL));
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
	[networkController sendData:[self dataNameChange:[username stringValue]]];
}
- (void)disconnectedFromServer {
	[portField setEnabled:YES];
	[startStopButton setTitle:@"Start"];
	for (int i = 0; i < [players count]; i ++) {
		Player* playerObj = [players objectAtIndex:i];
	}
	[players removeAllObjects];
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
			[networkController sendData:[self dataKeyPress:0]];
			leftArrow = TRUE;
		}
	}
	if (key == NSRightArrowFunctionKey) {
		if (!rightArrow) {
			[networkController sendData:[self dataKeyPress:1]];
			rightArrow = TRUE;
		}
	}
	if (key == NSUpArrowFunctionKey) {
		if (!upArrow) {
			[networkController sendData:[self dataKeyPress:2]];
			upArrow = TRUE;
		}
	}
	if (key == NSDownArrowFunctionKey) {
		if (!downArrow) {
			[networkController sendData:[self dataKeyPress:3]];
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
			[networkController sendData:[self dataKeyDepress:0]];
			leftArrow = FALSE;
		}
	}
	if (key == NSRightArrowFunctionKey) {
		if (rightArrow) {
			[networkController sendData:[self dataKeyDepress:1]];
			rightArrow = FALSE;
		}
	}
	if (key == NSUpArrowFunctionKey) {
		if (upArrow) {
			[networkController sendData:[self dataKeyDepress:2]];
			upArrow = FALSE;
		}
	}
	if (key == NSDownArrowFunctionKey) {
		if (downArrow) {
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
- (unsigned int)getSignedShortIntFrom:(NSData*)data byteStart:(int*)byteStart {
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
@end