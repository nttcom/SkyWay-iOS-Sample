//
// DataConnectionViewController.h
// SkyWay-iOS-Sample
//

#import <UIKit/UIKit.h>

@interface DataConnectionViewController : UIViewController

@property (nonatomic) NSUInteger peerType;
@property (nonatomic) NSString* serverIP;

- (void)callingTo:(NSString *)strDestId;

@end
