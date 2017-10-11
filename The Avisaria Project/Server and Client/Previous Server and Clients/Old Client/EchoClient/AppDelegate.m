#import "AppDelegate.h"
#import "AsyncSocket.h"


@implementation AppDelegate
@synthesize logView;

- (id)init
{
	if(self = [super init])
	{
		networkController = [[NetworkingController alloc] init];
	}
	return self;
}

- (void)awakeFromNib
{
	[logView setString:@""];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[networkController setUp];
}

- (IBAction)startStop:(id)sender
{
	if(!networkController.isRunning)
	{
		int port = [portField intValue];
		
		if(port < 0 || port > 65535)
		{
			port = 0;
		}
		
		BOOL connected = [networkController connectIP:@"127.0.0.1" port:port];
		if (connected) {
			[portField setEnabled:NO];
			[startStopButton setTitle:@"Stop"];
		}
	}
	else
	{
		// Stop accepting connections
		[networkController disconnect];
		[portField setEnabled:YES];
		[startStopButton setTitle:@"Start"];
	}
}

- (IBAction)sendMessage:(id)sender {
	[networkController sendString:[textField stringValue]];
	[textField setStringValue:@""];
}

- (void)scrollToBottom
{
	NSScrollView *scrollView = [logView enclosingScrollView];
	NSPoint newScrollOrigin;
	
	if ([[scrollView documentView] isFlipped])
		newScrollOrigin = NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]));
	else
		newScrollOrigin = NSMakePoint(0.0, 0.0);
	
	[[scrollView documentView] scrollPoint:newScrollOrigin];
}
@end
