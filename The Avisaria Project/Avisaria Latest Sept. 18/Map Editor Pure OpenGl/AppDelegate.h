#import <Cocoa/Cocoa.h>
#import "ObjectPlatform.h"
#import "ObjectData.h"
#import "TileView.h"
#import "WorldView.h"
#import "MapData.h"
#import "Texture.h"
#import "MiniMap.h"

#define xtiles 22 //1 tile buffers on side
#define ytiles 22
#define tileSize 73
#define screenWidth 365
#define screenHeight 328
#define yOffset 10

#define layers 4

#define animSpeed 30

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	NSString* applicationDirectory;
	NSMutableArray* tileImages;
	NSMutableArray* tileTextures;
	NSImage* playerImage;
	Texture* playerTexture;
	
	//Object Editor
	NSMutableArray* objects;
	CALayer* objectLayer;
	CALayer* anchorLayer;
	NSImage* anchorImage;
	
	//Map Editor
	CGPoint gridStart, gridEnd;
	float moveSpeed;
	int moveCount;
	BOOL leftArrow,rightArrow,upArrow,downArrow;
	CALayer* player;
	CGPoint playerPosition;
	NSTimer* timer;
	int selectedLayer,selectedTool;
	
	NSMutableArray* maps;
	
	CGPoint animDir;
	
	IBOutlet NSPanel* miniMap;
	IBOutlet MiniMap* miniMapView;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic,assign) IBOutlet WorldView* worldView;
@property (nonatomic,assign) IBOutlet ObjectPlatform* objectPlatform;
@property (nonatomic,assign) IBOutlet TileView* tileView;
@property (nonatomic,assign) IBOutlet NSTableView *objectTableView, *objectAttributeTableView,*objectTableView2,*mapTableView;
@property (nonatomic,assign) IBOutlet NSComboBox *attributesComboBox;
@property (nonatomic,assign) NSMutableArray* tileImages, *objects;
@property (nonatomic,assign) NSImage* playerImage;
@property (nonatomic,assign) IBOutlet NSMatrix *layerMatrix,*drawMatrix;
@property (nonatomic,assign) IBOutlet NSTextField *widthTxt,*heightTxt;
@property (nonatomic,assign) NSMutableArray* maps;
@property (nonatomic) CGPoint playerPosition;


//Object Editor
- (IBAction) addObject:(id)sender;
- (IBAction) addObjectAttribute:(id)sender;
- (IBAction) deleteObjectAttribute:(id)sender;
- (IBAction) setObjectTile:(id)sender;
- (IBAction) tableViewSelected:(id)sender;
- (void) updateObjectPlayerform;
- (void)  setAnchorPoint:(CGPoint)pos;
- (void) resetAnchorPoint;

//Map Editor
- (void) prepareMapEditor;
- (void)keydown:(UniChar)key;
- (void)keyup:(UniChar)key;
- (void)mouseDown:(CGPoint)point;
- (void)mouseDragged:(CGPoint)point;
- (void)mouseUp:(CGPoint)point;
- (void)timerTick;
- (IBAction)newMap:(id)sender;
- (IBAction)deleteMap:(id)sender;
- (IBAction)saveWorld:(id)sender;
- (IBAction)openMiniMap:(id)sender;
- (IBAction)mapTableViewSelected:(id)sender;
- (void)drawTileAt:(CGPoint)point;
//- (void)updateAllTiles:(CGPoint)layerGridMove;
//- (void) updateTileX:(int)x Y:(int)y Z:(int)z;
- (IBAction)layerMatrixClick:(NSMatrix*)sender;
- (void)drawMap;
- (void)setUpOpenGl:(CGPoint)size;
- (BOOL) saveFileAtApp:(NSString*)name object:(NSObject*)object;
- (NSObject*) openFileAtApp:(NSString*)name;
- (IBAction)drawMatrixClick:(NSMatrix*)sender;

@end
