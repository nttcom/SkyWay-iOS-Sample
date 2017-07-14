//
// DataConnectionViewController.m
// SkyWay-iOS-Sample
//

#import "DataConnectionViewController.h"

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
    TAG_VIEW,
    TAG_LOG,
    TAG_DATA_TYPE,
    TAG_SEND_DATA,
    TAG_IMG_VIEW,
    AS_DATA_TYPE,
};

typedef NS_ENUM(NSUInteger, DataType)
{
    DT_STRING,
    DT_NUMBER,
    DT_ARRAY,
    DT_DICTIONARY,
    DT_DATA,
};

@interface DataConnectionViewController ()
< UINavigationControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate >
{
    SKWPeer*				_peer;
    SKWDataConnection*	_dataConnection;
    
    DataType				_dataType;
    
    NSString*			_strOwnId;
    BOOL				_bConnected;
    
    UIPopoverController*	_pc;
    
    NSArray*			_arySerializationTypes;
    NSArray*			_aryDataTypes;
    
    NSArray*			_aryDataIntTypes;
}

@end

@implementation DataConnectionViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    // Initialize
    //
    _strOwnId = nil;
    _bConnected = NO;
    _dataConnection = nil;
    
    _dataType = DT_STRING;
    
    _arySerializationTypes = @[
                               @"binary",
                               @"binary-utf8",
                               @"json",
                               @"none",
                               ];
    
    _aryDataTypes = @[
                      @"Hello SkyWay.        (String)",
                      @"3.14                    (Number)",
                      @"[1,2,3]                      (Array)",
                      @"{'one':1,'two':2}      (Hash)",
                      @"send Image           (Binary)"
                      ];
    
    _aryDataIntTypes = @[
                         @(DT_STRING),
                         @(DT_NUMBER),
                         @(DT_ARRAY),
                         @(DT_DICTIONARY),
                         @(DT_DATA),
                         ];
    
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
    
    //
    // Initialize views
    //
    if (nil != self.navigationItem)
    {
        NSString* strTitle = @"DataConnection";
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
    
    // Peer ID
    UIFont* fnt = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGRect rcDesign = rcScreen;
    rcDesign.size.width = (rcScreen.size.width / 3.0f) * 2.0f;
    rcDesign.size.height = fnt.lineHeight * 3.0f;
    
    CGRect rcId = CGRectInset(rcDesign, 2.0f, 2.0f);
    
    UILabel* lblId = [[UILabel alloc] initWithFrame:rcId];
    [lblId setTag:TAG_ID];
    [lblId setFont:fnt];
    [lblId setTextAlignment:NSTextAlignmentCenter];
    lblId.numberOfLines = 2;
    [lblId setText:@"your ID:\n ---"];
    [lblId setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:lblId];
    
    // Connect View
    rcDesign.origin.x	+= rcDesign.size.width;
    rcDesign.size.width = rcScreen.size.width - rcDesign.origin.x;
    
    CGRect rcCall = CGRectInset(rcDesign, 2.0f, 2.0f);
    
    UIButton* btnCall = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnCall setTag:TAG_WEBRTC_ACTION];
    [btnCall setFrame:rcCall];
    [btnCall setTitle:@"Connect to" forState:UIControlStateNormal];
    [btnCall setBackgroundColor:[UIColor lightGrayColor]];
    [btnCall addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [btnCall setEnabled:NO];
    
    [self.view addSubview:btnCall];
    
    // Data type View
    rcDesign.origin.x = 0.0f;
    rcDesign.size.width = (rcScreen.size.width / 3.0f) * 2.0f;
    rcDesign.origin.y = rcId.origin.y + rcId.size.height + 4.0f;
    
    CGRect rcDataType = CGRectInset(rcDesign, 2.0f, 2.0f);
    
    UIButton* btnDataType = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnDataType setTag:TAG_DATA_TYPE];
    [btnDataType setFrame:rcDataType];
    [btnDataType setTitle:@"Hello SkyWay.        (String)" forState:UIControlStateNormal];
    [btnDataType setBackgroundColor:[UIColor lightGrayColor]];
    [btnDataType addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [btnDataType setEnabled:NO];
    
    [self.view addSubview:btnDataType];
    
    // Send data View
    rcDesign.origin.x	+= rcDesign.size.width;
    rcDesign.size.width = rcScreen.size.width - rcDesign.origin.x;
    
    CGRect rcSendData = CGRectInset(rcDesign, 2.0f, 2.0f);
    
    UIButton* btnSendData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnSendData setTag:TAG_SEND_DATA];
    [btnSendData setFrame:rcSendData];
    [btnSendData setTitle:@"Send" forState:UIControlStateNormal];
    [btnSendData setBackgroundColor:[UIColor lightGrayColor]];
    [btnSendData addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [btnSendData setEnabled:NO];
    
    [self.view addSubview:btnSendData];
    
    // Log View
    CGRect rcLog = CGRectZero;
    rcLog.origin.y = rcDesign.origin.y + rcDesign.size.height + 4.0f;
    rcLog.size.width = rcScreen.size.width;
    rcLog.size.height = rcScreen.size.height - rcLog.origin.y - 100.0f;
    
    UITextView* tvLog = [[UITextView alloc] initWithFrame:rcLog];
    [tvLog setTag:TAG_LOG];
    [tvLog setFrame:rcLog];
    [tvLog setBackgroundColor:[UIColor whiteColor]];
    tvLog.layer.borderWidth = 1;
    tvLog.layer.borderColor = [[UIColor orangeColor] CGColor];
    [tvLog setEditable:NO];
    
    [self.view addSubview:tvLog];
    
    // Image View
    UIImageView* ivIMG = [[UIImageView alloc] init];
    ivIMG.contentMode = UIViewContentModeScaleAspectFill;
    ivIMG.frame = CGRectMake(0, 0, 100.0f, 100.0f);
    ivIMG.center = CGPointMake(rcScreen.size.width / 2, rcLog.origin.y + rcLog.size.height + 50.0f);
    [ivIMG setTag:TAG_IMG_VIEW];

    [self.view addSubview:ivIMG];
}

- (void)dealloc
{
    _strOwnId = nil;
    
    _dataConnection = nil;
    _peer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateUI];
}


#pragma mark - Public method

- (void)callingTo:(NSString *)strDestId
{
    //////////////////////////////////////////////////////////////////////
    //////////////////  START: Connect SkyWay Peer   /////////////////////
    //////////////////////////////////////////////////////////////////////
    
    // connect option
    SKWConnectOption* option = [[SKWConnectOption alloc] init];
    option.label = @"chat";
    option.metadata = @"{'message': 'hi'}";
    option.serialization = SKW_SERIALIZATION_BINARY;
    option.reliable = YES;
    
    // connect
    _dataConnection = [_peer connectWithId:strDestId options:option];
    [self setDataCallback:_dataConnection];
    
    //////////////////////////////////////////////////////////////////////
    ///////////////////  END: Connect SkyWay Peer   //////////////////////
    //////////////////////////////////////////////////////////////////////
}

- (void)closeChat
{
    if (nil == _dataConnection)
    {
        return;
    }
    
    [_dataConnection close];
}

- (void)closedData
{
    [self clearDataCallbacks:_dataConnection];
    
    _dataConnection = nil;
}


#pragma mark - Peer


- (void)setCallbacks:(SKWPeer *)peer
{
    //////////////////////////////////////////////////////////////////////////////////
    ////////////////////  START: Set SkyWay peer callback   //////////////////////////
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
    
    // !!!: Event/Connection
    [peer on:SKW_PEER_EVENT_CONNECTION callback:^(NSObject* obj)
     {
         if (YES == [obj isKindOfClass:[SKWDataConnection class]])
         {
             _dataConnection = (SKWDataConnection *)obj;
             [self setDataCallback:_dataConnection];
             
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
    /////////////////////  END: Set SkyWay peer callback   ///////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
}


// Clear peer callback block
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


- (void)setDataCallback:(SKWDataConnection *)data
{
    if (nil == data)
    {
        return;
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    /////////////////  START: Set SkyWay Data connection callback   //////////////////
    //////////////////////////////////////////////////////////////////////////////////
    
    // !!!: DataEvent/Open
    [data on:SKW_DATACONNECTION_EVENT_OPEN callback:^(NSObject* obj)
     {
         _bConnected = YES;
         
         [self updateUI];
         
         // Log serialization type
         NSString* serialization = [_arySerializationTypes objectAtIndex:data.serialization];
         NSString* str = [NSString stringWithFormat:@"Serialization: %@\n", serialization];
         
         [self performSelectorOnMainThread:@selector(appendLogWithMessage:) withObject:str waitUntilDone:YES];

     }];
    
    // !!!: DataEvent/Data
    [data on:SKW_DATACONNECTION_EVENT_DATA callback:^(NSObject* obj)
     {
         NSString* strData = nil;
         
         if ([obj isKindOfClass:[NSString class]])
         {
             strData = (NSString *)obj;
         }
         else if ([obj isKindOfClass:[NSArray class]])
         {
             NSArray* aryData = (NSArray *)obj;
             strData = [NSString stringWithFormat:@"%@", aryData];
         }
         else if ([obj isKindOfClass:[NSDictionary class]])
         {
             NSDictionary* dctData = (NSDictionary *)obj;
             strData = [NSString stringWithFormat:@"%@", dctData];
         }
         else if ([obj isKindOfClass:[NSData class]])
         {
             NSData* datData = (NSData *)obj;
             UIImage* image = [[UIImage alloc] initWithData:datData];
             
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                UIImageView* ivImg = (UIImageView *)[self.view viewWithTag:TAG_IMG_VIEW];
                                ivImg.image = image;
                            });
             
             strData = @"Received Image (displayed below)";
         }
         else if ([obj isKindOfClass:[NSNumber class]])
         {
             NSNumber* numData = (NSNumber *)obj;
             strData = [NSString stringWithFormat:@"[%s]%@", [numData objCType], numData];
         }
         
         [self appendLogWithHead:@"Partner" value:strData];
         
     }];
    
    // !!!: DataEvent/Close
    [data on:SKW_DATACONNECTION_EVENT_CLOSE callback:^(NSObject* obj)
     {
         _bConnected = NO;
         
         [self updateUI];
         
         [self performSelectorOnMainThread:@selector(closedData) withObject:nil waitUntilDone:NO];
     }];
    
    // !!!: DataEvent/Error
    [data on:SKW_DATACONNECTION_EVENT_ERROR callback:^(NSObject* obj)
     {
         SKWPeerError* err = (SKWPeerError *)obj;
         
         NSString* strMsg = err.message;
         if (nil == strMsg)
         {
             if (nil != err.error)
             {
                 strMsg = err.error.description;
             }
         }
         
         [self showError:strMsg];
     }];
    
    //////////////////////////////////////////////////////////////////////////////////
    /////////////////  END: Set SkyWay Data connection callback   ////////////////////
    //////////////////////////////////////////////////////////////////////////////////
}


- (void)clearDataCallbacks:(SKWDataConnection *)data
{
    if (nil == data)
    {
        return;
    }
    
    [data on:SKW_DATACONNECTION_EVENT_OPEN callback:nil];
    [data on:SKW_DATACONNECTION_EVENT_DATA callback:nil];
    [data on:SKW_DATACONNECTION_EVENT_CLOSE callback:nil];
    [data on:SKW_DATACONNECTION_EVENT_ERROR callback:nil];
}

#pragma mark - Send Data

- (void)updateDataType:(NSInteger)type
{
    UIButton* btn = (UIButton *)[self.view viewWithTag:TAG_DATA_TYPE];
    
    NSString* strTitle = [_aryDataTypes objectAtIndex:type];
    [btn setTitle:strTitle forState:UIControlStateNormal];
    
    NSNumber* numValue = [_aryDataIntTypes objectAtIndex:type];
    
    _dataType = [numValue unsignedIntegerValue];
}

- (void)executeDataSend:(SKWDataConnection *)data type:(DataType)type
{
    BOOL bResult = NO;
    NSString* strMsg = [NSString alloc];
    if (DT_STRING == type)
    {
        // NSString
        NSString* strData = @"Hello SkyWay.";
        
        bResult = [data send:strData];
        
        strMsg = [NSString stringWithFormat:@"%@", strData];
    }
    else if (DT_NUMBER == type)
    {
        // NSNumber
        NSNumber* numData = [NSNumber numberWithDouble:3.14];
        
        bResult = [data send:numData];
        
        strMsg = [NSString stringWithFormat:@"%@", numData];
    }
    else if (DT_ARRAY == type)
    {
        NSArray* aryData = @[@1,@2,@3,];
        
        bResult = [data send:aryData];
        
        strMsg = [NSString stringWithFormat:@"%@", aryData];
    }
    else if (DT_DICTIONARY == type)
    {
        NSDictionary* dctData = @{
                                  @"one": @1,
                                  @"two": @2,
                                  };
        
        bResult = [data send:dctData];
        
        strMsg = [NSString stringWithFormat:@"%@", dctData];
    }
    else if (DT_DATA == type)
    {
        UIImage *image = [UIImage imageNamed:@"image.png"];
        NSData* pngData = [[NSData alloc] initWithData: UIImagePNGRepresentation(image)];
        
        bResult = [data send:pngData];
        strMsg = @"Send Image";
    }
    
    // successfully send
    if (bResult) {
        [self appendLogWithHead:@"You" value:strMsg];
    }
}



#pragma mark - Utility
- (void)showError:(NSString *)strMsg
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
#ifdef __IPHONE_8_0
                       if (NSFoundationVersionNumber_iOS_7_1 >= NSFoundationVersionNumber)
                       {
                           // Use UIAlertView
                           UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:strMsg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                           
                           [av show];
                       }
                       else
                       {
                           // Use UIAlertController
                           UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Error" message:strMsg preferredStyle:UIAlertControllerStyleAlert];
                           
                           [ac addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                          {
                                              
                                          }]];
                           
                           [self presentViewController:ac animated:YES completion:^{
                               
                           }];
                       }
#else
                       // Use UIAlertView
                       UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:strMsg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                       
                       [av show];
#endif
                   });
    
}

- (void)clearViewController
{
    [self closeChat];
    
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
    
    if (nil != _peer)
    {
        [_peer destroy];
    }
}

- (void)updateUI
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       NSString* strTitle = @"---";
                       
                       UIButton* btn = (UIButton *)[self.view viewWithTag:TAG_WEBRTC_ACTION];
                       if (nil != btn)
                       {
                           if (NO == _bConnected)
                           {
                               strTitle = @"Connect to";
                           }
                           else
                           {
                               strTitle = @"Disconnect";
                           }
                           
                           [btn setTitle:strTitle forState:UIControlStateNormal];
                       }
                       
                       btn = (UIButton *)[self.view viewWithTag:TAG_DATA_TYPE];
                       if (nil != btn)
                       {
                           [btn setEnabled:_bConnected];
                       }
                       
                       btn = (UIButton *)[self.view viewWithTag:TAG_SEND_DATA];
                       if (nil != btn)
                       {
                           [btn setEnabled:_bConnected];
                       }
                   });
}

- (void)appendLogWithMessage:(NSString *)strMessage
{
    UITextView* tvLog = (UITextView *)[self.view viewWithTag:TAG_LOG];
    
    NSRange rng = NSMakeRange(tvLog.text.length + 1, 0);
    [tvLog setSelectedRange:rng];
    
    [tvLog replaceRange:tvLog.selectedTextRange withText:strMessage];
    
    rng = NSMakeRange(tvLog.text.length + 1, 0);
    [tvLog scrollRangeToVisible:rng];
}
- (void)appendLogWithHead:(NSString *)strHeader value:(NSString *)strValue
{
    if (0 == strValue.length)
    {
        return;
    }
    
    NSMutableString* mstrValue = [[NSMutableString alloc] init];
    
    if (nil != strHeader)
    {
        [mstrValue appendString:@"["];
        [mstrValue appendString:strHeader];
        [mstrValue appendString:@"] "];
    }
    
    if (32000 < strValue.length)
    {
        NSRange rng = NSMakeRange(0, 32);
        [mstrValue appendString:[strValue substringWithRange:rng]];
        [mstrValue appendString:@"..."];
        rng = NSMakeRange(strValue.length - 32, 32);
        [mstrValue appendString:[strValue substringWithRange:rng]];
    }
    else
    {
        [mstrValue appendString:strValue];
    }
    
    [mstrValue appendString:@"\n"];
    
    [self performSelectorOnMainThread:@selector(appendLogWithMessage:) withObject:mstrValue waitUntilDone:YES];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (UINavigationControllerOperationPop == operation)
    {
        if (YES == [fromVC isKindOfClass:[DataConnectionViewController class]])
        {
            // Back
            [self performSelectorOnMainThread:@selector(clearViewController) withObject:nil waitUntilDone:NO];
            
            [navigationController setDelegate:nil];
        }
    }
    
    return nil;
}

#pragma mark - UIButtonActionDelegate

- (void)onTouchUpInside:(NSObject *)sender
{
    if (NO == [sender isKindOfClass:[UIButton class]])
    {
        return;
    }
    
    UIButton* btn = (UIButton *)sender;
    
    if (TAG_WEBRTC_ACTION == btn.tag)
    {
        if (nil == _dataConnection)
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
            // Connected data
            [self performSelectorInBackground:@selector(closeChat) withObject:nil];
        }
    }
    else if (TAG_DATA_TYPE == btn.tag)
    {
        if (NSFoundationVersionNumber_iOS_7_1 < NSFoundationVersionNumber)
        {
            // 8.0 Later
            UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Sample Data          (Data types)"
                                                                        message:@""
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction* aaCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [ac addAction:aaCancel];
            
            NSInteger iIndex = 0;
            for (NSString* strType in _aryDataTypes)
            {
                UIAlertAction* aaTypes = [UIAlertAction actionWithTitle:strType
                                                                  style:UIAlertActionStyleDestructive
                                                                handler:^(UIAlertAction *action)
                                          {
                                              NSUInteger uiIndex = 0;
                                              for (NSString* strType in _aryDataTypes)
                                              {
                                                  if (NSOrderedSame == [action.title caseInsensitiveCompare:strType])
                                                  {
                                                      break;
                                                  }
                                                  
                                                  uiIndex++;
                                              }
                                              
                                              [self updateDataType:uiIndex];
                                          }];
                
                [ac addAction:aaTypes];
                
                iIndex++;
            }
            
            if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom)
            {
                UIView* vw = [self.view viewWithTag:TAG_DATA_TYPE];
                _pc = [[UIPopoverController alloc] initWithContentViewController:ac];
                [_pc setDelegate:self];
                
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   [_pc presentPopoverFromRect:vw.bounds inView:vw permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                               });
            }
            else
            {
                [self presentViewController:ac animated:YES completion:nil];
            }
        }
        else
        {
            // 7.1 Earlier
            UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"Sample Data          (Data types)"
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil];
            
            for (NSString* strTitle in _aryDataTypes)
            {
                [as addButtonWithTitle:strTitle];
            }
            
            as.cancelButtonIndex = [as addButtonWithTitle:@"Cancel"];
            
            as.tag = AS_DATA_TYPE;
            
            if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom)
            {
                [as showFromRect:btn.frame inView:self.view animated:YES];
            }
            else
            {
                [as showInView:self.view.window];
            }
        }
    }
    else if (TAG_SEND_DATA == btn.tag)
    {
        [self executeDataSend:_dataConnection type:_dataType];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex)
    {
        return;
    }
    
    NSNumber* numValue = [_aryDataIntTypes objectAtIndex:buttonIndex];
    
    _dataType = [numValue unsignedIntegerValue];
    
    [self updateDataType:buttonIndex];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

@end
