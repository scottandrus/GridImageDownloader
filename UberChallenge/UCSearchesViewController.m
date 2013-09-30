//
//  UCSearchesViewController.m
//  UberChallenge
//
//  Created by Scott Andrus on 8/30/13.
//

#import "UCSearchesViewController.h"

static NSString *kTableViewCellReuseIdentifier = @"TABLEVIEW_CELL";

@implementation UCSearchesViewController

#pragma mark - Instantiation

- (NSArray *)searches
{
    if (!_searches) {
        _searches = [NSArray array];
    }
    return _searches;
}

#pragma mark - Actions

- (IBAction)imagesButtonPressed:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kTableViewCellReuseIdentifier];
    }
    cell.textLabel.text = [self.searches objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.ivc searchWithQuery:[self.searches objectAtIndex:indexPath.row]];
}

@end
