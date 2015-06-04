//
// TableViewController.h
// SkyWay-iOS-Sample
//

#import <UIKit/UIKit.h>

@interface PeersListViewController : UITableViewController

@property (strong, nonatomic) NSArray* items;
@property (weak, nonatomic) UIViewController* callback;

@end
