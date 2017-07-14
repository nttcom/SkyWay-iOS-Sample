//
// MediaConnectionViewController.m
// SkyWay-iOS-Sample
//

#import "MediaConnectionViewController.h"

#import <AVFoundation/AVFoundation.h>

#import <SkyWay/SKWPeer.h>

#import "AppDelegate.h"
#import "PeersListViewController.h"


// Enter your APIkey and Domain
// Please check this page. >> https://skyway.io/ds/
static NSString *const kAPIkey = @"yourAPIKEY";
static NSString *const kDomain = @"yourDomain";


typedef NS_ENUM(NSUInteger, ViewTag)
{
	TAG_ID = 1000,
	TAG_WEBRTC_ACTION,
	TAG_REMOTE_VIDEO,
	TAG_LOCAL_VIDEO,
};

typedef NS_ENUM(NSUInteger, AlertType)
{
	ALERT_ERROR,
	ALERT_CALLING,
};

@interface MediaConnectionViewController ()
< UINavigationControllerDelegate, UIAlertViewDelegate>
{
	SKWPeer*			_peer;
	SKWMediaStream*		_msLocal;
	SKWMediaStream*		_msRemote;
	SKWMediaConnection*	_mediaConnection;
	
	NSString*			_strOwnId;
	BOOL				_bConnected;
	
}

@end

@implementation MediaConnectionViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	//
	// Initialize
	//
	_strOwnId = nil;
	_bConnected = NO;
	
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	if (nil != self.navigationController)
	{
		[self.navigationController setDelegate:self];
	}
    
    //////////////////////////////////////////////////////////////////////
    //////////////////  START: Initialize SkyWay Peer ////////////////////
    //////////////////////////////////////////////////////////////////////
    
    SKWPeerOption* option = [[SKWPeerOption alloc] init];
    
    option.key = kAPIkey;
    option.domain = kDomain;
    
    // SKWPeer has many options. Please check the document. >> http://nttcom.github.io/skyway/docs/
    
    
    _peer	= [[SKWPeer alloc] initWithId:nil options:option];
    [self setCallbacks:_peer];
    
    //////////////////////////////////////////////////////////////////////
    ////////////////// END: Initialize SkyWay Peer ///////////////////////
    //////////////////////////////////////////////////////////////////////
	
    
    
    
    //////////////////////////////////////////////////////////////////////
    ////////////////// START: Get Local Stream   /////////////////////////
    //////////////////////////////////////////////////////////////////////

	[SKWNavigator initialize:_peer];
    
	SKWMediaConstraints* constraints = [[SKWMediaConstraints alloc] init];
	constraints.maxWidth = 960;
	constraints.maxHeight = 540;
    //	constraints.cameraPosition = SKW_CAMERA_POSITION_BACK;
    constraints.cameraPosition = SKW_CAMERA_POSITION_FRONT;
    
	_msLocal = [SKWNavigator getUserMedia:constraints];
    
    //////////////////////////////////////////////////////////////////////
    //////////////////// END: Get Local Stream   /////////////////////////
    //////////////////////////////////////////////////////////////////////
	
	//
	// Initialize views
	//
	if ((nil != self.navigationItem) && (nil == self.navigationItem.title))
	{
		NSString* strTitle = @"MediaConnection";
		[self.navigationItem setTitle:strTitle];
	}
	
	CGRect rcScreen = self.view.bounds;
	if (NSFoundationVersionNumber_iOS_6_1 < NSFoundationVersionNumber)
	{
		CGFloat fValue = [UIApplication sharedApplication].statusBarFrame.size.height;
		rcScreen.origin.y = fValue;
		if (nil != self.navigationController)
		{
			if (NO == self.navigationController.navigationBarHidden)
			{
				fValue = self.navigationController.navigationBar.frame.size.height;
				rcScreen.origin.y += fValue;
			}
		}
	}

	// Initialize Remote video view
    CGRect rcRemote = CGRectZero;
    if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom)
    {
        // iPad
        rcRemote.size.width = 480.0f;
        rcRemote.size.height = 480.0f;
    }
    else
    {
        // iPhone / iPod touch
        rcRemote.size.width = rcScreen.size.width;
        rcRemote.size.height = rcRemote.size.width;
    }
    rcRemote.origin.x = (rcScreen.size.width - rcRemote.size.width) / 2.0f;
    rcRemote.origin.y = (rcScreen.size.height - rcRemote.size.height) / 2.0f;
    rcRemote.origin.y -= 8.0f;
    
    
    // Initialize Local video view
    CGRect rcLocal = CGRectZero;
    if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom)
    {
        rcLocal.size.width = rcScreen.size.width / 5.0f;
        rcLocal.size.height = rcScreen.size.height / 5.0f;
    }
    else
    {
        rcLocal.size.width = rcScreen.size.height / 5.0f;
        rcLocal.size.height = rcLocal.size.width;
    }
    rcLocal.origin.x = rcScreen.size.width - rcLocal.size.width - 8.0f;
    rcLocal.origin.y = rcScreen.size.height - rcLocal.size.height - 8.0f;
    rcLocal.origin.y -= self.navigationController.toolbar.frame.size.height;
    
    
    
    //////////////////////////////////////////////////////////////////////
    ////////////  START: Add Remote & Local SKWVideo to View   ///////////
    //////////////////////////////////////////////////////////////////////
	
	SKWVideo* vwRemote = [[SKWVideo alloc] initWithFrame:rcRemote];
	[vwRemote setTag:TAG_REMOTE_VIDEO];
	[vwRemote setUserInteractionEnabled:NO];
	[vwRemote setHidden:YES];
	[self.view addSubview:vwRemote];
	
    
	SKWVideo* vwLocal = [[SKWVideo alloc] initWithFrame:rcLocal];
	[vwLocal setTag:TAG_LOCAL_VIDEO];
	[self.view addSubview:vwLocal];

	// Add local stream to local video view
	[vwLocal addSrc:_msLocal track:0];
    
    //////////////////////////////////////////////////////////////////////
    ////////////  END: Add Remote & Local SKWVideo to View   /////////////
    //////////////////////////////////////////////////////////////////////
	
	// Peer ID View
	UIFont* fnt = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    
	CGRect rcId = rcScreen;
	rcId.size.width = (rcScreen.size.width / 3.0f) * 2.0f;
	rcId.size.height = fnt.lineHeight * 2.0f;

    UILabel* lblId = [[UILabel alloc] initWithFrame:rcId];
    [lblId setTag:TAG_ID];
    [lblId setFont:fnt];
    [lblId setTextAlignment:NSTextAlignmentCenter];
    lblId.numberOfLines = 2;
    [lblId setText:@"your ID:\n ---"];
    [lblId setBackgroundColor:[UIColor whiteColor]];
	
	[self.view addSubview:lblId];
	
	// Call View
	CGRect rcCall = rcId;
	rcCall.origin.x	= rcId.origin.x + rcId.size.width;
	rcCall.size.width = (rcScreen.size.width / 3.0f) * 1.0f;
	rcCall.size.height = fnt.lineHeight * 2.0f;
	UIButton* btnCall = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnCall setTag:TAG_WEBRTC_ACTION];
	[btnCall setFrame:rcCall];
	[btnCall setTitle:@"Call to" forState:UIControlStateNormal];
	[btnCall setBackgroundColor:[UIColor lightGrayColor]];
	[btnCall addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

	[self.view addSubview:btnCall];
    
    // Change Camera
    CGRect rcChange = rcScreen;
    rcChange.size.width = rcScreen.size.width;
    rcChange.size.height = fnt.lineHeight * 2.0f;
    rcChange.origin.y = rcScreen.size.height - rcChange.size.height;
    
    UIButton* btnChange = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnChange setFrame:rcChange];
    [btnChange setTitle:@"Change Camera" forState:UIControlStateNormal];
    [btnChange setBackgroundColor:[UIColor whiteColor]];
    [btnChange addTarget:self action:@selector(cycleLocalCamera) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnChange];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	[self updateActionButtonTitle];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
	[super viewDidDisappear:animated];
}

- (void)dealloc
{
    _msLocal = nil;
	_msRemote = nil;
	
	_strOwnId = nil;
	
	_mediaConnection = nil;
	_peer = nil;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark - Public method

- (void)callingTo:(NSString *)strDestId
{
    //////////////////////////////////////////////////////////////////////
    ////////////////// START: Call SkyWay Peer   /////////////////////////
    //////////////////////////////////////////////////////////////////////

	_mediaConnection = [_peer callWithId:strDestId stream:_msLocal];
	
	[self setMediaCallbacks:_mediaConnection];
    
    //////////////////////////////////////////////////////////////////////
    /////////////////// END: Call SkyWay Peer   //////////////////////////
    //////////////////////////////////////////////////////////////////////
}


- (void)closeChat
{
	if (nil != _mediaConnection)
	{
		if (nil != _msRemote)
		{
			SKWVideo* video = (SKWVideo *)[self.view viewWithTag:TAG_REMOTE_VIDEO];
			if (nil != video)
			{
				[video removeSrc:_msRemote track:0];
			}
			
			[_msRemote close];
			
			_msRemote = nil;
		}
		
		[_mediaConnection close];
	}
}

- (void)closedMedia
{
	[self unsetRemoteView];
	
	[self clearMediaCallbacks:_mediaConnection];
	
	_mediaConnection = nil;
}

#pragma mark -

- (void)setCallbacks:(SKWPeer *)peer
{
	if (nil == peer)
	{
		return;
	}
	
    //////////////////////////////////////////////////////////////////////////////////
    ///////////////////// START: Set SkyWay peer callback   //////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
    
	// !!!: Event/Open
	[peer on:SKW_PEER_EVENT_OPEN callback:^(NSObject* obj)
	 {
		 dispatch_async(dispatch_get_main_queue(), ^
						{
							if (YES == [obj isKindOfClass:[NSString class]])
							{
                                _strOwnId = (NSString *)obj;
                                
                                UILabel* lbl = (UILabel*)[self.view viewWithTag:TAG_ID];
                                if (nil != lbl)
                                {
                                    [lbl setText:[NSString stringWithFormat:@"your ID: \n%@", _strOwnId]];
                                    [lbl setNeedsDisplay];
								}
							}
							
							UIButton* btn = (UIButton*)[self.view viewWithTag:TAG_WEBRTC_ACTION];
							if (nil != btn)
							{
								[btn setEnabled:YES];
							}
						});
	 }];
	
	// !!!: Event/Call
	[peer on:SKW_PEER_EVENT_CALL callback:^(NSObject* obj)
	 {
		 if (YES == [obj isKindOfClass:[SKWMediaConnection class]])
		 {
			 _mediaConnection = (SKWMediaConnection *)obj;
			 
			 [self setMediaCallbacks:_mediaConnection];
             [_mediaConnection answer:_msLocal];
		 }
	 }];
	
	// !!!: Event/Close
	[peer on:SKW_PEER_EVENT_CLOSE callback:^(NSObject* obj)
	 {
	 }];
	
	// !!!: Event/Disconnected
	[peer on:SKW_PEER_EVENT_DISCONNECTED callback:^(NSObject* obj)
	 {
	 }];
	
	// !!!: Event/Error
	[peer on:SKW_PEER_EVENT_ERROR callback:^(NSObject* obj)
	 { 
	 }];
    
    //////////////////////////////////////////////////////////////////////////////////
    /////////////////////// END: Set SkyWay peer callback   //////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
}

- (void)clearCallbacks:(SKWPeer *)peer
{
	if (nil == peer)
	{
		return;
	}
	
	[peer on:SKW_PEER_EVENT_OPEN callback:nil];
	[peer on:SKW_PEER_EVENT_CONNECTION callback:nil];
	[peer on:SKW_PEER_EVENT_CALL callback:nil];
	[peer on:SKW_PEER_EVENT_CLOSE callback:nil];
	[peer on:SKW_PEER_EVENT_DISCONNECTED callback:nil];
	[peer on:SKW_PEER_EVENT_ERROR callback:nil];
}

- (void)setMediaCallbacks:(SKWMediaConnection *)media
{
	if (nil == media)
	{
		return;
	}
	
    //////////////////////////////////////////////////////////////////////////////////
    ////////////////  START: Set SkyWay Media connection callback   //////////////////
    //////////////////////////////////////////////////////////////////////////////////
    
	// !!!: MediaEvent/Stream
	[media on:SKW_MEDIACONNECTION_EVENT_STREAM callback:^(NSObject* obj)
	 {
		 // Add Stream;
		 if (YES == [obj isKindOfClass:[SKWMediaStream class]])
		 {
			 SKWMediaStream* stream = (SKWMediaStream *)obj;
			 [self setRemoteView:stream];
		 }
		 
	 }];
	
	// !!!: MediaEvent/Close
	[media on:SKW_MEDIACONNECTION_EVENT_CLOSE callback:^(NSObject* obj)
	 {
		 [self closedMedia];
	 }];
	
	// !!!: MediaEvent/Error
	[media on:SKW_MEDIACONNECTION_EVENT_ERROR callback:^(NSObject* obj)
	 {
	 }];
    
    //////////////////////////////////////////////////////////////////////////////////
    /////////////////  END: Set SkyWay Media connection callback   ///////////////////
    //////////////////////////////////////////////////////////////////////////////////
}

- (void)clearMediaCallbacks:(SKWMediaConnection *)media
{
	if (nil == media)
	{
		return;
	}
	
	[media on:SKW_MEDIACONNECTION_EVENT_STREAM callback:nil];
	[media on:SKW_MEDIACONNECTION_EVENT_CLOSE callback:nil];
	[media on:SKW_MEDIACONNECTION_EVENT_ERROR callback:nil];
}

- (void)cycleLocalCamera
{
    if (nil == _msLocal)
    {
        return;
    }
    
    SKWCameraPositionEnum pos = [_msLocal getCameraPosition];
    if (SKW_CAMERA_POSITION_BACK == pos)
    {
        pos = SKW_CAMERA_POSITION_FRONT;
    }
    else if (SKW_CAMERA_POSITION_FRONT == pos)
    {
        pos = SKW_CAMERA_POSITION_BACK;
    }
    else
    {
        return;
    }
    
    [_msLocal setCameraPosition:pos];
}


#pragma mark - Utility

- (void)clearViewController
{
	if (nil != _mediaConnection)
	{
		[self clearMediaCallbacks:_mediaConnection];
	}
	
	[self closeChat];
	
	if (nil != _msLocal)
	{
		[_msLocal close];
		_msLocal = nil;
	}
	
	if (nil != _peer)
	{
		[self clearCallbacks:_peer];
	}
	
	for (UIView* vw in self.view.subviews)
	{
		if (YES == [vw isKindOfClass:[UIButton class]])
		{
			UIButton* btn = (UIButton *)vw;
			[btn removeTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		}

		[vw removeFromSuperview];
	}
	
	self.navigationItem.rightBarButtonItem = nil;

	[SKWNavigator terminate];
	
	if (nil != _peer)
	{
		[_peer destroy];
	}
}

- (void)setRemoteView:(SKWMediaStream *)stream
{
	
	if (YES == _bConnected)
	{
		return;
	}
	
	_bConnected = YES;
	
	_msRemote = stream;
	
	[self updateActionButtonTitle];
	
	dispatch_async(dispatch_get_main_queue(), ^
				   {
					   SKWVideo* vwRemote = (SKWVideo *)[self.view viewWithTag:TAG_REMOTE_VIDEO];
					   if (nil != vwRemote)
					   {
						   [vwRemote setHidden:NO];
						   [vwRemote setUserInteractionEnabled:YES];
						   
						   [vwRemote addSrc:_msRemote track:0];
					   }
				   });
}

- (void)unsetRemoteView
{
	if (NO == _bConnected)
	{
		return;
	}
	
	_bConnected = NO;
	
	SKWVideo* vwRemote = (SKWVideo *)[self.view viewWithTag:TAG_REMOTE_VIDEO];
	
	if (nil != _msRemote)
	{
		if (nil != vwRemote)
		{
			[vwRemote removeSrc:_msRemote track:0];
		}
		
		[_msRemote close];
		
		_msRemote = nil;
	}
	
	if (nil != vwRemote)
	{
		dispatch_async(dispatch_get_main_queue(), ^
					   {
						   [vwRemote setUserInteractionEnabled:NO];
						   [vwRemote setHidden:YES];
					   });
	}
	
	[self updateActionButtonTitle];
}

- (void)updateActionButtonTitle
{
	dispatch_async(dispatch_get_main_queue(), ^
		{
		   UIButton* btn = (UIButton *)[self.view viewWithTag:TAG_WEBRTC_ACTION];
		   
		   NSString* strTitle = @"---";
		   
		   if (NO == _bConnected)
		   {
			   strTitle = @"Call to";
		   }
		   else
		   {
			   strTitle = @"End call";
		   }
		   
		   [btn setTitle:strTitle forState:UIControlStateNormal];
		});
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
	if (UINavigationControllerOperationPop == operation)
	{
		if (YES == [fromVC isKindOfClass:[MediaConnectionViewController class]])
		{
			[self performSelectorOnMainThread:@selector(clearViewController) withObject:nil waitUntilDone:NO];
			
			[navigationController setDelegate:nil];
		}
	}
	
	return nil;
}


#pragma mark - UIButtonActionDelegate

- (void)onTouchUpInside:(NSObject *)sender
{
	UIButton* btn = (UIButton *)sender;
	
	if (TAG_WEBRTC_ACTION == btn.tag)
	{
		if (nil == _mediaConnection)
		{
			// Listing all peers
			[_peer listAllPeers:^(NSArray* aryPeers)
			 {
				 NSMutableArray* maItems = [[NSMutableArray alloc] init];
				 if (nil == _strOwnId)
				 {
					 [maItems addObjectsFromArray:aryPeers];
				 }
				 else
				 {
					 for (NSString* strValue in aryPeers)
					 {
						 if (NSOrderedSame == [_strOwnId caseInsensitiveCompare:strValue])
						 {
							 continue;
						 }
						 
						 [maItems addObject:strValue];
					 }
					 
				 }
				 
				 PeersListViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeersList"];
				 vc.items = [NSArray arrayWithArray:maItems];
				 vc.callback = self;
				 
				 UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
				 
                 dispatch_async(dispatch_get_main_queue(), ^
                 {
                    [self presentViewController:nc animated:YES completion:nil];
                 });
				 
				 [maItems removeAllObjects];
			 }];
		}
		else
		{
			// Closing chat
			[self performSelectorInBackground:@selector(closeChat) withObject:nil];
		}
	}
	
}


@end
