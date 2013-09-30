//
//  UCImageCell.h
//  UberChallenge
//
//  Created by Scott Andrus on 8/30/13.
//

#import "PSTCollectionView.h"

@class UCImageCell;

@protocol UCImageCellDelegate <NSObject>

- (void)didTapButtonForCell:(UCImageCell *)cell;

@end

@interface UCImageCell : PSUICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) id<UCImageCellDelegate> delegate;

@end
