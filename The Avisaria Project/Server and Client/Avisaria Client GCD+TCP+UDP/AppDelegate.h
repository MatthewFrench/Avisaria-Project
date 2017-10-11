#import <Cocoa/Cocoa.h>
#import "NetworkingController.h"
#import "Player.h"
#import "WorldView.h"
#import <Quartz/Quartz.h>
#import "Texture.h"
#import "MapData.h"
#import "ObjectData.h"
#import "GLString.h"

#define xtiles 22 //1 tile buffers on side
#define ytiles 22
#define tileSize 73
#define screenWidth 365
#define screenHeight 330
#define yOffset 10

#define layers 4

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow* mainWindow, *loginWindow;
	NetworkingController* networkController;
	NSMutableArray* players;
	
	int isPlayer;
	
	IBOutlet NSTextView* logView;
    IBOutlet id portField;
	IBOutlet NSTextField* ipField,*username;
    //IBOutlet id startStopButton;
	IBOutlet id sendMessageButton;
	IBOutlet id textField;
	
	NSImage* playerImage;
	Texture* playerTexture;
	NSTimer* timer;
	
	IBOutlet WorldView* worldView;
	
	NSMutableArray* objects;
	NSMutableArray* maps;
	
	NSMutableArray* tileImages;
	NSMutableArray* tileTextures;
	
	BOOL leftArrow,rightArrow,upArrow,downArrow;
	BOOL mousePressed;
	
	CGPoint gridStart, gridEnd;
	
	NSMutableDictionary* stanStringAttrib;
	
	BOOL updateMap;
	
}
@property (assign) IBOutlet NSWindow *mainWindow,*loginWindow;
@property(nonatomic) int isPlayer;

- (IBAction)startStop:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)updateName:(id)sender;
- (void)scrollToBottom;
- (void)logMessage:(NSString *)message;
- (void)connectedToServer;
- (void)recievedMessage:(NSData*)data;
- (void)recievedUdpMessage:(NSData*)data;
- (void)disconnectedFromServer;
- (void)setUpOpenGl:(CGPoint)size;
- (void)drawMap;

- (void)keyDown:(int)key;
- (void)keyUp:(int)key;

- (void)mouseDown:(CGPoint)pos;
- (void)mouseMove:(CGPoint)pos;
- (void)mouseUp:(CGPoint)pos;

- (void)activateNewPlayer;
- (void)activateUpdatePlayer:(NSData*)data dataPos:(int)dataPos;
- (void)activateDeletePlayer:(int)num;
- (void)activateRecieveMessage:(NSData*)data dataPos:(int)dataPos;
- (NSData*)dataUdpInfo;
- (NSData*)dataKeyPress:(int)num;
- (NSData*)dataKeyDepress:(int)num;
- (NSData*)dataMessage:(NSString*)msg;
- (NSData*)dataNameChange:(NSString*)msg;
- (unsigned char)getUnsignedCharFrom:(NSData*)data byteStart:(int*)byteStart;
- (unsigned int)getUnsignedIntFrom:(NSData*)data byteStart:(int*)byteStart;
- (signed short int)getSignedShortIntFrom:(NSData*)data byteStart:(int*)byteStart;
- (NSString*)getNSStringFrom:(NSData*)data byteStart:(int*)byteStart length:(int)length;
- (float)getFloatFrom:(NSData*)data byteStart:(int*)byteStart;

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font;

- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r;
@end