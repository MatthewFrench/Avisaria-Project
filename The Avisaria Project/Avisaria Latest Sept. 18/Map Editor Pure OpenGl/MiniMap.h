#import <Cocoa/Cocoa.h>
#import <AppKit/Appkit.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "ObjectData.h"
#import "MapData.h"

@interface MiniMap : NSView {
	NSTimer *gameTimer;
	CGPoint screenDimensions;
	BOOL updateScreen,updateWorld, teleport;
	
	NSMutableArray* tiles, *objects;
	NSMutableArray* maps;
	int selectedMap;
	
	CGPoint selectedTile;
	
	float xresize;
	float yresize;
	
	NSImage* worldImage;
	
	IBOutlet NSButton* updateScreenBtn,*saveImageBtn;
	IBOutlet NSProgressIndicator* mapProgress;
}
@property(nonatomic) int selectedMap;
@property(nonatomic) BOOL updateScreen,updateWorld, teleport;
@property(nonatomic, assign) NSMutableArray* tiles, *objects;
@property(nonatomic, assign) NSMutableArray* maps;
@property(nonatomic, assign) NSButton* updateScreenBtn,*saveImageBtn;
@property(nonatomic) CGPoint selectedTile;
@property(nonatomic, assign) NSProgressIndicator* mapProgress;

- (void)updateWorldImage;
- (NSImage*) loadImage:(NSString*)name type:(NSString*)imageType;
- (NSImage*) loadImageAtApp:(NSString*)name type:(NSString*)imageType;
- (NSString*) loadText:(NSString*)name type:(NSString*)fileType;
- (void) drawLine:(CGPoint)point topoint:(CGPoint)topoint linesize:(float)linesize color:(float[])color;
- (void) drawImage:(NSImage*)sprite point:(CGPoint)point rotation:(float)rotation;
- (void) drawOval:(float[])color point:(CGPoint)point dimensions:(CGPoint)dimensions filled:(BOOL)filled linesize:(float)linesize;
- (void) drawString:(NSString*)text point:(CGPoint)point font:(NSString*)font color:(float[])color size:(int)textSize;
- (void) drawRectangle:(CGPoint)point widthheight:(CGPoint)widthheight color:(float[])color filled:(BOOL)filled linesize:(float)linesize;
- (BOOL) saveFileAtApp:(NSString*)name object:(NSMutableArray*)object;
- (NSMutableArray*) openFileAtApp:(NSString*)name;

@end
