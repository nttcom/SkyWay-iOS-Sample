//
// MenuViewController.m
// SkyWay-iOS-Sample
//

#import "MenuViewController.h"

#import "AppDelegate.h"
#import "MediaConnectionViewController.h"
#import "DataConnectionViewController.h"


typedef NS_ENUM(NSUInteger, ViewTag)
{
	BTN_VIDEOCHAT,
	BTN_CHAT,
};


@implementation MenuViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
	[self setTitle:@"Menu"];
	
	//
	CGRect rcClient = self.view.bounds;
	
	if (nil != self.navigationController.navigationBar)
	{
		CGRect rcTitle = self.navigationController.navigationBar.frame;
		rcClient.origin.y = rcTitle.origin.y + rcTitle.size.height;
		rcClient.size.height -= rcClient.origin.y;
	}
	
	CGFloat fButtonHeight = rcClient.size.height / 7.0f;
	CGRect rcDesign = rcClient;
	
	// Video chat
	rcDesign = CGRectZero;
	rcDesign.origin.y = fButtonHeight * 1.0f;
	rcDesign.size.width = rcClient.size.width;
	rcDesign.size.height = fButtonHeight;
	
	CGRect rcVideoChat = CGRectInset(rcDesign, 8.0f, 4.0f);
	
	UIButton* btnVideoChat = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnVideoChat setTag:BTN_VIDEOCHAT];
	[btnVideoChat setTitle:@"Media connection" forState:UIControlStateNormal];
	[btnVideoChat setBackgroundColor:[UIColor lightGrayColor]];
	[btnVideoChat setFrame:rcVideoChat];
	[btnVideoChat addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btnVideoChat];
	
	// Chat
	rcDesign = CGRectZero;
	rcDesign.origin.y = fButtonHeight * 2.0f;
	rcDesign.size.width = rcClient.size.width;
	rcDesign.size.height = fButtonHeight;

	CGRect rcChat = CGRectInset(rcDesign, 8.0f, 4.0f);
	
	UIButton* btnChat = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnChat setTag:BTN_CHAT];
	[btnChat setTitle:@"Data connection" forState:UIControlStateNormal];
	[btnChat setBackgroundColor:[UIColor lightGrayColor]];
	[btnChat setFrame:rcChat];
	[btnChat addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btnChat];
	

}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark -

- (void)touchUpInside:(NSObject *)sender
{
	if (YES == [sender isKindOfClass:[UIButton class]])
	{
		//
		UIButton* btn = (UIButton *)sender;
		
		UIViewController* vc = nil;
		
		if (BTN_VIDEOCHAT == btn.tag)
		{
			// Video chat
			MediaConnectionViewController* vcVideoChat = [[MediaConnectionViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
            NSString* strTitle = @"MediaConnection";
            [vcVideoChat.navigationItem setTitle:strTitle];
			
			vc = vcVideoChat;
		}
		else if (BTN_CHAT == btn.tag)
		{
			// Chat
			DataConnectionViewController* vcChat = [[DataConnectionViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
            NSString* strTitle = @"DataConnection";
            [vcChat.navigationItem setTitle:strTitle];
			
			vc = vcChat;
		}

		if (nil != vc)
		{
			[self.navigationController pushViewController:vc animated:YES];
		}
	}
}

@end
