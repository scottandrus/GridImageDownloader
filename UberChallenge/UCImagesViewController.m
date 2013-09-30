//
//  UCImagesViewController.m
//  UberChallenge
//
//  Created by Scott Andrus on 8/30/13.
//

#import "UCImagesViewController.h"
#import "UCSearchesViewController.h"
#import "UCImageViewerViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFJSONRequestOperation.h>

#import <SVProgressHUD/SVProgressHUD.h>

static const CGFloat kCollectionViewInset = 2.0;
static const CGFloat kCollectionViewNumOfCols = 3.0;
static const CGFloat kBarHeight = 44.0;
static NSString *kCollectionViewCellReuseIdentifier = @"REUSABLE_CELL";

@interface UCImagesViewController ()

@property (nonatomic, assign) NSInteger requestPageLimit;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) NSDictionary *currentCursor;

@end

@implementation UCImagesViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Arbitrary
        _requestPageLimit = 4;
    }
    return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.searchBar
                                                                          action:@selector(resignFirstResponder)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Instantiation

- (NSMutableArray *)images
{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableArray *)previousSearches
{
    if (!_previousSearches) {
        _previousSearches = [NSMutableArray array];
    }
    return _previousSearches;
}

#pragma mark - Interface

- (void)setupCollectionView
{
    PSUICollectionViewFlowLayout *layout = [[PSUICollectionViewFlowLayout alloc] init];
    CGRect collectionViewFrame = CGRectMake(0,
                                            kBarHeight,
                                            self.view.frame.size.width,
                                            self.view.frame.size.height - 2.0*kBarHeight);
    self.collectionView = [[PSUICollectionView alloc] initWithFrame:collectionViewFrame
                                               collectionViewLayout:layout];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[UCImageCell class]
            forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = collectionViewFrame;
}

#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(PSUICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView
                    cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UCImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier
                                                                  forIndexPath:indexPath];
    cell.delegate = self;
    __block UCImageCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.images objectAtIndex:indexPath.row]]]
                          placeholderImage:[UIImage imageNamed:@"loading"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [weakCell.imageView setImage:image];
                                       weakCell.button.enabled = YES;
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       [weakCell.imageView setImage:[UIImage imageNamed:@"failedtoload"]];
                                   }];
    return cell;
}

#pragma mark - PSTCollectionViewDelegateFlowLayout

- (CGSize)collectionView:(PSTCollectionView *)collectionView
                  layout:(PSTCollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.view.frame.size.width / kCollectionViewNumOfCols - kCollectionViewInset * 2.0;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView
                        layout:(PSTCollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kCollectionViewInset,
                            kCollectionViewInset,
                            kCollectionViewInset,
                            kCollectionViewInset);
}

- (CGFloat)collectionView:(PSTCollectionView *)collectionView
                   layout:(PSTCollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kCollectionViewInset;
}

- (CGFloat)collectionView:(PSTCollectionView *)collectionView
                   layout:(PSTCollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCollectionViewInset;
}

#pragma mark - Actions

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Perform the image request with the search query
    [searchBar resignFirstResponder];
    [self searchWithQuery:searchBar.text];
}

#pragma mark - UCImagesViewControllerProtocol

- (void)searchWithQuery:(NSString *)query
{
    [SVProgressHUD show];
    self.searchBar.text = query;
    [self.previousSearches insertObject:query atIndex:0];
    [self.images removeAllObjects];
    [self.collectionView reloadData];
    
    NSString *requestString = [self formRequestStringFromQuery:query forStart:0];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    [self requestImagesFromRequest:request];
}

- (NSString *)formRequestStringFromQuery:(NSString *)query forStart:(NSInteger)start
{
    NSString *newQuery = [query stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
    return [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%d&rsz=8", newQuery, start];
}

- (void)requestImagesFromRequest:(NSURLRequest *)request
{
    self.isLoading = YES;
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                     NSLog(@"%@", JSON);
                                                                                     if ([[JSON objectForKey:@"responseData"] isEqual:[NSNull null]]) {
                                                                                         [[[UIAlertView alloc] initWithTitle:@"No results found." message:@"Try a different search phrase." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
                                                                                     } else {
                                                                                         [self processResponse:JSON];
                                                                                     }
                                                                                 }
                                                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                     NSLog(@"%@", JSON);
                                                                                     [[[UIAlertView alloc] initWithTitle:@"Failed to search." message:@"Check your internet settings, or perhaps try a different search phrase." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
                                                                                     [SVProgressHUD dismiss];
                                                                                 }];
    [op start];
}

- (void)processResponse:(id)JSON
{    
    NSArray *results = [[JSON objectForKey:@"responseData"] objectForKey:@"results"];
    for (id result in results) {
        [self.images addObject:[result objectForKey:@"url"]];
    }
    
    self.currentCursor = [[JSON objectForKey:@"responseData"] objectForKey:@"cursor"];
    NSInteger currentPage = [[self.currentCursor objectForKey:@"currentPageIndex"] integerValue];
    NSArray *pages = [self.currentCursor objectForKey:@"pages"];
    
    if (currentPage < self.requestPageLimit) {
        NSString *query = self.searchBar.text;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self formRequestStringFromQuery:query
                                                                                                          forStart:[[[pages objectAtIndex:currentPage+1] objectForKey:@"start"] integerValue]]]];

        [self requestImagesFromRequest:request];
    } else {
        self.isLoading = NO;
        [self.collectionView reloadData];
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UCImageCellDelegate

- (void)didTapButtonForCell:(UCImageCell *)cell
{
    [self performSegueWithIdentifier:@"image_segue" sender:cell.imageView.image];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Google search API specifies that only 8*8=64 results can be requested.
    // See https://developers.google.com/image-search/v1/jsondevguide
    if ([self scrollViewIsAtBottom:scrollView] && !self.isLoading && self.requestPageLimit < 7) {
        self.requestPageLimit++;
        NSInteger currentPage = [[self.currentCursor objectForKey:@"currentPageIndex"] integerValue];
        NSArray *pages = [self.currentCursor objectForKey:@"pages"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self formRequestStringFromQuery:self.searchBar.text
                                                                                                          forStart:[[[pages objectAtIndex:currentPage+1] objectForKey:@"start"] integerValue]]]];
        [self requestImagesFromRequest:request];
    }
}

- (BOOL)scrollViewIsAtBottom:(UIScrollView *)scrollView
{
    return (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height;
}

#pragma mark - Storyboard Control

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"searches_segue"]) {
        UCSearchesViewController *searchVC = (UCSearchesViewController *)segue.destinationViewController;
        searchVC.searches = [self.previousSearches copy];
        searchVC.ivc = self;
    } else if ([segue.identifier isEqualToString:@"image_segue"]) {
        
        UCImageViewerViewController *imageViewerVC = (UCImageViewerViewController *)segue.destinationViewController;
        imageViewerVC.image = sender;
    }
}

@end
