#import "AppDelegate.h"


/**
 FOR SECURITY
 -Write ticket IDs like what UDP has. It a packet has the same or previous ID then kick it out.
 -Probably a secure login based on time formula.
 -If too many fault packets then boot the client.
 
 -Maybe find some sort of encryption for each packet
 **/

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
#define ClientActionUpdatePlayerUsername 3
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
#define ServerTestUdp 5


#define overflow 20
@implementation AppDelegate


@synthesize mainWindow,loginWindow,isPlayer;


- (void)tick {
	for (int i = 0; i < [players count]; i ++) {
		Player* player = [players objectAtIndex:i];
		if (player.moveCount > 0) {player.moveCount -= 1;updateMap = TRUE;}
	}
	if (updateMap) {
		[self drawMap];
		updateMap = FALSE;
	}
}

- (void)activateNewPlayer {
	Player* player = [[Player alloc] init];
	[players addObject:player];
	[player release];
	updateMap = TRUE;
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
			if (player.position.x != x+1 || player.position.y != y) {
				
				CGPoint animDir = CGPointMake(0, 0);
				CGPoint layerGrid = CGPointMake(x+1-player.position.x, y-player.position.y); 
				
				if (layerGrid.x == -1 && layerGrid.y == 1) { //left
					animDir.x = 1;
				} else if (layerGrid.x == 1 && layerGrid.y == -1) { //right
					animDir.x = -1;
				} else if (layerGrid.x == -1 && layerGrid.y == -1) { //Down
					animDir.y = -1;
				} else if (layerGrid.x == 1 && layerGrid.y == 1) { //up
					animDir.y = 1;
				}
				if (layerGrid.x == 0 && layerGrid.y == 1) {
					animDir = CGPointMake(0.5, 0.5);
				}
				if (layerGrid.x == 0 && layerGrid.y == -1) {
					animDir = CGPointMake(-0.5, -0.5);
				}
				if (layerGrid.x == 1 && layerGrid.y == 0) {
					animDir = CGPointMake(-0.5, 0.5);
				}
				if (layerGrid.x == -1 && layerGrid.y == 0) {
					animDir = CGPointMake(0.5, -0.5);
				}
			
			
			//if (abs(x+1-player.position.x) <= 1 && abs(y-player.position.y) <= 1 && animDir.x < 2 && animDir.y < 2) {
				player.animDir = animDir;
				player.moveCount = player.moveSpeed;
			//}
				updateMap = TRUE;
		}
			player.position = CGPointMake(x+1, y);
			break;
		}
		case ClientActionUpdatePlayerUsername:{
			NSString* name = [self getNSStringFrom:data byteStart:&dataPos length:[data length] - dataPos];
			if (player.username) {[player.username release];}
			player.username = [[NSString alloc] initWithString:name];
			[player.usernameStr release];
			player.usernameStr = [[GLString alloc] initWithString:player.username withAttributes:stanStringAttrib withTextColor:[NSColor whiteColor] withBoxColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.3] withBorderColor:[NSColor blackColor]];
			updateMap = TRUE;
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
	if (num < isPlayer) {isPlayer -= 1;}
	updateMap = TRUE;
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
			//Player* player = [players objectAtIndex:isPlayer];
			updateMap = TRUE;
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
	playerImage = [NSImage imageNamed:@"player.png"];
	[playerImage retain];
	players = [[NSMutableArray alloc] init];
	[[self mainWindow] makeFirstResponder:worldView];
	srand(time(NULL));
	isPlayer = -1;
	mousePressed = FALSE;
	
	//Load World
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"World Data" ofType:@"ganrocks"];
	NSMutableDictionary* dictionary = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
	if (dictionary) {
		if ([dictionary objectForKey:@"maps"]) {
			maps = [dictionary objectForKey:@"maps"];
			[maps retain];
		}
		if ([dictionary objectForKey:@"objects"]) {
			objects = [dictionary objectForKey:@"objects"];
			[objects retain];
		}
	}
	tileImages = [NSMutableArray new];
	
	//Load tiles
	for (int i = 1; i > 0; i ++) {
		NSString* filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d",i] ofType:@"png"];
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
		if (fileExists) {
			NSImage* imageFile = [[NSImage alloc] initWithContentsOfFile:filePath];
			[tileImages addObject:imageFile];
			[imageFile release];
		} else {
			i = -1;
		}
	}
	[self setUpOpenGl:CGPointMake(worldView.bounds.size.width, worldView.bounds.size.height)];
	
	gridStart = CGPointMake(-2, -2);
	gridEnd = CGPointMake(xtiles - 1, ytiles - 1);
	
	// init fonts for use with strings
	NSFont * font =[NSFont fontWithName:@"Helvetica" size:12.0];
	stanStringAttrib = [[NSMutableDictionary dictionary] retain];
	[stanStringAttrib setObject:font forKey:NSFontAttributeName];
	[stanStringAttrib setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[font release];
	
	//***Turn on Game Timer
	timer = [NSTimer scheduledTimerWithTimeInterval: 1.0/60.0
											 target: self
										   selector: @selector(tick)
										   userInfo: nil
											repeats: YES];
}
- (void)setUpOpenGl:(CGPoint)size {
	[[worldView openGLContext] makeCurrentContext];
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint swapInt = 1;
	[[worldView openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
	//glEnable(GL_DEPTH_TEST);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	CGLLockContext([[worldView openGLContext] CGLContextObj]);
	
	// Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho( size.x/2, -size.x/2, -size.y / 2, size.y / 2, -1, 1 );
	glMatrixMode(GL_MODELVIEW);
	glViewport(0, 0, -size.x, -size.y);
	glTranslatef(0.0f+size.x / 2, 0.0f+size.y / 2, 0.0f );
	glRotatef(180.0f, 0.0f, 0.0f, 1.0f);
	//glScalef(1.0, -1.0, 1.0);
	
	
	// Initialize OpenGL states
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
	glEnableClientState(GL_VERTEX_ARRAY);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	
	glShadeModel(GL_SMOOTH);
	
	GLint zeroOpacity = 0;
	[[worldView openGLContext] setValues:&zeroOpacity forParameter:NSOpenGLCPSurfaceOpacity];
	
	CGLUnlockContext([[worldView openGLContext] CGLContextObj]);
	
	//Load textures
	tileTextures = [NSMutableArray new];
	for (int i = 0; i < [tileImages count]; i ++) {
		Texture* newTex = [Texture new];
		[newTex initWithImage:[tileImages objectAtIndex:i]];
		[tileTextures addObject:newTex];
		[newTex release];
	}
	playerTexture = [Texture new];
	[playerTexture initWithImage:playerImage];
}
- (void)connectedToServer {
	[loginWindow close];
	[mainWindow makeKeyAndOrderFront:nil];
	
	
	[networkController sendData:[self dataNameChange:[username stringValue]]];
}
- (void)disconnectedFromServer {
	[loginWindow makeKeyAndOrderFront:nil];
	[mainWindow close];
	[players removeAllObjects];
	isPlayer = -1;
	updateMap = TRUE;
}
- (void)drawMap {
	[[worldView openGLContext] makeCurrentContext];
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	if (isPlayer > -1) {
		Player* player = [players objectAtIndex:isPlayer];
		for (int z = 0; z < layers; z ++) {
			for (int x = gridEnd.x; x > gridStart.x; x -=1) {
				for (int y = gridEnd.y; y > gridStart.y; y -=1) {
					MapData* map = [maps objectAtIndex:0];
					
					signed short int * tile = [map staticallyGetTileAt:CGPointMake(x-11+player.position.x, y-10+player.position.y)];
					if (tile != (signed short int *)-1 && tile[z] > -1) {
						ObjectData* object = [objects objectAtIndex:tile[z]];
						//tileLayer.anchorPoint = object.anchorPoint;
						float xpos =  (x - y) * (tileSize/2) + screenWidth;
						float ypos =  (-x - y) * (tileSize/2) + screenHeight + yOffset*tileSize;
						NSImage* tileImage = [tileImages objectAtIndex:object.tile];
						CGPoint drawPos = CGPointMake(
													  floor(xpos-(tileImage.size.width*(object.anchorPoint.x)) - (player.animDir.x*player.moveCount/player.moveSpeed*tileSize)), 
													  floor(ypos-(tileImage.size.height*(1.0-object.anchorPoint.y)) - 10 - (player.animDir.y*player.moveCount/player.moveSpeed*tileSize))
													  );
						//CGPoint drawPos = CGPointMake(round(xpos)+0.5, round(ypos));
						[[tileTextures objectAtIndex:object.tile] drawAt:drawPos];
					}
					if (z == 2) {
						for (int i = 0;i < [players count]; i ++) {
							if (isPlayer != i) {
								Player* drawPlayer = [players objectAtIndex:i];
								CGPoint position = CGPointMake(drawPlayer.position.x-player.position.x, drawPlayer.position.y-player.position.y);
								if (x == 10+(drawPlayer.position.x-player.position.x) && y == 10+(drawPlayer.position.y-player.position.y)) {
									float xpos =  (position.x - position.y) * (tileSize/2) + screenWidth - (player.animDir.x*player.moveCount/player.moveSpeed*tileSize)  + (drawPlayer.animDir.x*drawPlayer.moveCount/drawPlayer.moveSpeed*tileSize);
									float ypos =  (-position.x - position.y) * (tileSize/2) + screenHeight- (player.animDir.y*player.moveCount/player.moveSpeed*tileSize) + (drawPlayer.animDir.y*drawPlayer.moveCount/drawPlayer.moveSpeed*tileSize);// + yOffset*tileSize;
									[playerTexture drawAt:CGPointMake(floor(xpos-playerImage.size.width/2.0), floor(ypos-playerImage.size.height/2.0))];
								}
							}
						}
						if (x == 10 && y == 10) {
							[playerTexture drawAt:CGPointMake(floor(screenWidth-playerImage.size.width/2.0), floor(screenHeight-playerImage.size.height/2.0))];
						}
					}
				}
			}
		}
		//Draw names
		for (int i = 0;i < [players count]; i ++) {
			if (isPlayer != i) {
				Player* drawPlayer = [players objectAtIndex:i];
				CGPoint position = CGPointMake(drawPlayer.position.x-player.position.x, drawPlayer.position.y-player.position.y);
					float xpos =  (position.x - position.y) * (tileSize/2) + screenWidth - (player.animDir.x*player.moveCount/player.moveSpeed*tileSize)  + (drawPlayer.animDir.x*drawPlayer.moveCount/drawPlayer.moveSpeed*tileSize);
					float ypos =  (-position.x - position.y) * (tileSize/2) + screenHeight- (player.animDir.y*player.moveCount/player.moveSpeed*tileSize) + (drawPlayer.animDir.y*drawPlayer.moveCount/drawPlayer.moveSpeed*tileSize);// + yOffset*tileSize;
					[drawPlayer.usernameStr drawAtPoint:NSMakePoint(floor(xpos-drawPlayer.usernameStr.frameSize.width/2.0), floor(ypos-playerImage.size.height/2.0) - 20)];
			}
		}
		[player.usernameStr drawAtPoint:NSMakePoint(floor(screenWidth-player.usernameStr.frameSize.width/2.0), floor(screenHeight-playerImage.size.height/2.0) - 20)];
	}
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	
	glFlush();
	
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
	if (!mousePressed) {
	if (key == NSLeftArrowFunctionKey || key == 'a' || key == '4') {
		if (!leftArrow) {
			[networkController sendUdpData:[self dataKeyPress:0]];
			[networkController sendData:[self dataKeyPress:0]];
			leftArrow = TRUE;
		}
	}
	if (key == NSRightArrowFunctionKey || key == 'd' || key == '6') {
		if (!rightArrow) {
			[networkController sendUdpData:[self dataKeyPress:1]];
			[networkController sendData:[self dataKeyPress:1]];
			rightArrow = TRUE;
		}
	}
	if (key == NSUpArrowFunctionKey || key == 'w' || key == '8') {
		if (!upArrow) {
			[networkController sendUdpData:[self dataKeyPress:2]];
			[networkController sendData:[self dataKeyPress:2]];
			upArrow = TRUE;
		}
	}
	if (key == NSDownArrowFunctionKey || key == 's' || key == '5') {
		if (!downArrow) {
			[networkController sendUdpData:[self dataKeyPress:3]];
			[networkController sendData:[self dataKeyPress:3]];
			downArrow = TRUE;
		}
	}
	}
	if (key == NSEnterCharacter || key == 13) {
		[[self mainWindow] makeFirstResponder:textField];
	}
}
- (void)keyUp:(int)key {
	if (!mousePressed) {
	if (key == NSLeftArrowFunctionKey || key == 'a' || key == '4') {
		if (leftArrow) {
			[networkController sendUdpData:[self dataKeyDepress:0]];
			[networkController sendData:[self dataKeyDepress:0]];
			leftArrow = FALSE;
		}
	}
	if (key == NSRightArrowFunctionKey || key == 'd' || key == '6') {
		if (rightArrow) {
			[networkController sendUdpData:[self dataKeyDepress:1]];
			[networkController sendData:[self dataKeyDepress:1]];
			rightArrow = FALSE;
		}
	}
	if (key == NSUpArrowFunctionKey || key == 'w' || key == '8') {
		if (upArrow) {
			[networkController sendUdpData:[self dataKeyDepress:2]];
			[networkController sendData:[self dataKeyDepress:2]];
			upArrow = FALSE;
		}
	}
	if (key == NSDownArrowFunctionKey || key == 's' || key == '5') {
		if (downArrow) {
			[networkController sendUdpData:[self dataKeyDepress:3]];
			[networkController sendData:[self dataKeyDepress:3]];
			downArrow = FALSE;
		}
	}
	}
}
- (void)mouseDown:(CGPoint)pos {
	mousePressed = TRUE;
	
	//22.5 to -22.5 = Right
	//22.5 to 67.5 = Up Right
	//67.5 to 112.5 = Up
	//112.5 to 157.5 = Up Left
	// 157.5 to -157.5 = Left
	//-157.5 to -112.5 = Down Left
	//-112.5 to -67.5 = Down
	//-67.5 to -22.5 = Down Right
	float mouseAngle = atan2(pos.y - screenHeight, pos.x - screenWidth)*180.0/M_PI;
	BOOL rightMouse = FALSE,leftMouse = FALSE,upMouse = FALSE,downMouse = FALSE;
	
	
	if (mouseAngle >= -22.5 && mouseAngle <= 22.5) {rightMouse = TRUE;}
	if (mouseAngle > 22.5 && mouseAngle < 67.5) {rightMouse = TRUE;upMouse = TRUE;}
	if (mouseAngle >= 67.5 && mouseAngle <= 112.5) {upMouse = TRUE;}
	if (mouseAngle > 112.5 && mouseAngle < 157.5) {upMouse = TRUE;leftMouse = TRUE;}
	if (mouseAngle >= 157.5 || mouseAngle <= -157.5) {leftMouse = TRUE;}
	if (mouseAngle > -157.5 && mouseAngle < -112.5) {leftMouse = TRUE;downMouse = TRUE;}
	if (mouseAngle >= -112.5 && mouseAngle <= -67.5) {downMouse = TRUE;}
	if (mouseAngle > -67.5 && mouseAngle < -22.5) {downMouse = TRUE;rightMouse = TRUE;}
	
	if (!rightMouse && rightArrow) {
		rightArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowRight]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowRight]];
	}
	if (!leftMouse && leftArrow) {
		leftArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowLeft]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowLeft]];
	}
	if (!upMouse && upArrow) {
		upArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowUp]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowUp]];
	}
	if (!downMouse && downArrow) {
		downArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowDown]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowDown]];
	}
	
	if (rightMouse && !rightArrow) {
		rightArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowRight]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowRight]];
	}
	if (leftMouse && !leftArrow) {
		leftArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowLeft]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowLeft]];
	}
	if (upMouse && !upArrow) {
		upArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowUp]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowUp]];
	}
	if (downMouse && !downArrow) {
		downArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowDown]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowDown]];
	}
}
- (void)mouseMove:(CGPoint)pos {
	float mouseAngle = atan2(pos.y - screenHeight, pos.x - screenWidth)*180.0/M_PI;
	BOOL rightMouse = FALSE,leftMouse = FALSE,upMouse = FALSE,downMouse = FALSE;
	
	
	if (mouseAngle >= -22.5 && mouseAngle <= 22.5) {rightMouse = TRUE;}
	if (mouseAngle > 22.5 && mouseAngle < 67.5) {rightMouse = TRUE;upMouse = TRUE;}
	if (mouseAngle >= 67.5 && mouseAngle <= 112.5) {upMouse = TRUE;}
	if (mouseAngle > 112.5 && mouseAngle < 157.5) {upMouse = TRUE;leftMouse = TRUE;}
	if (mouseAngle >= 157.5 || mouseAngle <= -157.5) {leftMouse = TRUE;}
	if (mouseAngle > -157.5 && mouseAngle < -112.5) {leftMouse = TRUE;downMouse = TRUE;}
	if (mouseAngle >= -112.5 && mouseAngle <= -67.5) {downMouse = TRUE;}
	if (mouseAngle > -67.5 && mouseAngle < -22.5) {downMouse = TRUE;rightMouse = TRUE;}
	
	if (!rightMouse && rightArrow) {
		rightArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowRight]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowRight]];
	}
	if (!leftMouse && leftArrow) {
		leftArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowLeft]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowLeft]];
	}
	if (!upMouse && upArrow) {
		upArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowUp]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowUp]];
	}
	if (!downMouse && downArrow) {
		downArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowDown]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowDown]];
	}
	
	if (rightMouse && !rightArrow) {
		rightArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowRight]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowRight]];
	}
	if (leftMouse && !leftArrow) {
		leftArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowLeft]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowLeft]];
	}
	if (upMouse && !upArrow) {
		upArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowUp]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowUp]];
	}
	if (downMouse && !downArrow) {
		downArrow = TRUE;
		[networkController sendUdpData:[self dataKeyPress:ServerActionArrowDown]];
		[networkController sendData:[self dataKeyPress:ServerActionArrowDown]];
	}
}
- (void)mouseUp:(CGPoint)pos {
	mousePressed = FALSE;
	
	if (rightArrow) {
		rightArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowRight]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowRight]];
	}
	if (leftArrow) {
		leftArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowLeft]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowLeft]];
	}
	if (upArrow) {
		upArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowUp]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowUp]];
	}
	if (downArrow) {
		downArrow = FALSE;
		[networkController sendUdpData:[self dataKeyDepress:ServerActionArrowDown]];
		[networkController sendData:[self dataKeyDepress:ServerActionArrowDown]];
	}
}
- (IBAction)sendMessage:(id)sender {
	if ([[textField stringValue] length] > 0) {
		[networkController sendData:[self dataMessage:[NSString stringWithFormat:@"%@: \"%@\"",[username stringValue],[textField stringValue]]]];
		[textField setStringValue:@""];
		[[self mainWindow] makeFirstResponder:worldView];
	}
}
- (IBAction)updateName:(id)sender {
	[networkController sendData:[self dataNameChange:[username stringValue]]];
	[[self mainWindow] makeFirstResponder:worldView];
}

- (void)logMessage:(NSString*)message {
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", message];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	
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

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

@end