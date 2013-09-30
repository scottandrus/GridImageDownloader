//
//  UCImageViewerViewController.h
//  UberChallenge
//
//  Created by Scott Andrus on 8/31/13.
//

#import <UIKit/UIKit.h>

@interface UCImageViewerViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end
