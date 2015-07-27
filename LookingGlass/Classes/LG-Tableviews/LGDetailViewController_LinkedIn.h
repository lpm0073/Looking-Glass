//
//  LGDetailViewController_LinkedIn.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGDetailViewController.h"

@interface LGDetailViewController_LinkedIn : LGDetailViewController <UITableViewDataSource, UITableViewDelegate, LGDataModelManagedObjectDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableview;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *headlineLabel;

@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;


- (id)initwithPerson:(Person *)person;
- (id)initWithCheckin:(Checkin *)checkin;
- (id)initWithMapItem:(MapItem *)mapItem;

@end
