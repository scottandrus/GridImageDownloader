//
//  UCImagesViewController.h
//  UberChallenge
//
//  Created by Scott Andrus on 8/30/13.
//

#import <UIKit/UIKit.h>
#import <PSTCollectionView/PSTCollectionView.h>

#import "UCImageCell.h"

@protocol UCImagesViewControllerProtocol <NSObject>

- (void)searchWithQuery:(NSString *)query;

@end

@interface UCImagesViewController : UIViewController <UCImagesViewControllerProtocol, UCImageCellDelegate, UISearchBarDelegate, PSUICollectionViewDataSource, PSUICollectionViewDelegate, PSUICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) PSUICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *previousSearches;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
