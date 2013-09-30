//
//  UCSearchesViewController.h
//  UberChallenge
//
//  Created by Scott Andrus on 8/30/13.
//

#import <UIKit/UIKit.h>
#import "UCImagesViewController.h"

@interface UCSearchesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *searches;
@property (nonatomic, assign) id<UCImagesViewControllerProtocol> ivc;

@end
