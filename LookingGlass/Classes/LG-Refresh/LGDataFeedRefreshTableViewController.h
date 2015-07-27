//
//  LGDataFeedRefreshTableViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGCoreDataTVC.h"

@interface LGDataFeedRefreshTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableview;


@end
