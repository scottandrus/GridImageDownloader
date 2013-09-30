//
//  UCImageCell.m
//  UberChallenge
//
//  Created by Scott Andrus on 8/30/13.
//

#import "UCImageCell.h"

@implementation UCImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self imageView];
        [self button];
    }
    return self;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.frame.size.width,
                                                                   self.frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return _imageView;
}


- (UIButton *)button
{
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             self.frame.size.width,
                                                             self.frame.size.height)];
        [self addSubview:_button];
        _button.enabled = NO;
        [_button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

#pragma mark - Actions

- (void)buttonTapped
{
    [self.delegate didTapButtonForCell:self];
}

@end
