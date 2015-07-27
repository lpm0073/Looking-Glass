//
//  LGDataFeedRefreshTableViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "LGDataFeedRefreshTableViewController.h"
#import "LGDataFeedRefreshViewController.h"

@interface LGDataFeedRefreshTableViewController()

@property (nonatomic, retain, readonly) NSMutableArray *unlockedDataFeeds;

@end

@implementation LGDataFeedRefreshTableViewController

@synthesize tableview;
@synthesize unlockedDataFeeds;

- (NSMutableArray *)unlockedDataFeeds
{
    if (!unlockedDataFeeds) {
        unlockedDataFeeds = [[LGAppDataFeed getUnlockedDataFeedsMutableArray] retain];
    }
    return unlockedDataFeeds;
}

#pragma mark - UITableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""] autorelease];
    NSInteger dataFeedType = [[self.unlockedDataFeeds objectAtIndex:[indexPath indexAtPosition:1]] integerValue];

    
    cell.textLabel.text = [LGAppDataFeed nameForDataFeedType:dataFeedType];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LGDFR_purchaseDate", @"Purchased %1$@"), 
                                   [LGAppDataFeed purchaseDateForDataFeedTypeAsLocalizedString:dataFeedType]];
    cell.imageView.image = [LGAppDataFeed imageForDataFeedTypeLarge:dataFeedType];
    
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.detailTextLabel.textColor = [UIColor darkTextColor];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.imageView.backgroundColor = [UIColor clearColor];

    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    
    cell.imageView.alpha = .5;
    //cell.alpha = .5;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unlockedDataFeeds.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"LGDFRTVC_titleForHeaderInSection", @"Unlocked Data Feeds");
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"LGDFRTVC_titleForFooterInSection", @"");
}


#pragma mark - UITableViewDelegate Protocol
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataFeedType = [[self.unlockedDataFeeds objectAtIndex:[indexPath indexAtPosition:1]] integerValue];
    
    LGDataFeedRefreshViewController *vc = [[LGDataFeedRefreshViewController alloc] initWithDataFeedType:dataFeedType];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}
- (UIView *)tableView:(UITableView *)thisTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.searchDisplayController.searchBar isFirstResponder]) return nil;
    
    UILabel *l          = [[[UILabel alloc] initWithFrame:[self.tableview rectForHeaderInSection:section]] autorelease];
    l.backgroundColor   = [UIColor clearColor];
    l.font              = [UIFont boldSystemFontOfSize:20];
    l.textColor         = [UIColor lightGrayColor];
    l.text              = [self tableView:thisTableView titleForHeaderInSection:section];
    [l sizeToFit];
    
    return l;
    
}
- (UIView *)tableView:(UITableView *)thisTableView viewForFooterInSection:(NSInteger)section
{
    UILabel *l          = [[[UILabel alloc] initWithFrame:[self.tableview rectForHeaderInSection:section]] autorelease];
    l.backgroundColor   = [UIColor clearColor];
    l.font              = [UIFont boldSystemFontOfSize:15];
    l.textColor         = [UIColor lightGrayColor];
    l.text              = [self tableView:thisTableView titleForFooterInSection:section];
    l.textAlignment     = UITextAlignmentRight;
    
    return l;
}


#pragma mark - Object lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.tableview reloadData];
    
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.opaque = NO;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    tableview = nil;
    unlockedDataFeeds = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [tableview release];
    [unlockedDataFeeds release];
    
    [super dealloc];
}
@end
