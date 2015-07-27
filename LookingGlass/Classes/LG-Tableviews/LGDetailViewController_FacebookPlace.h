//
//  LGDetailViewController_FacebookPlace.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGDetailViewController.h"
#import "FBConnect.h"


@interface LGDetailViewController_FacebookPlace : LGDetailViewController <FBRequestDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableview;

//query #1
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *phoneLabel;
@property (nonatomic, retain) IBOutlet UILabel *websiteLabel;
@property (nonatomic, retain) IBOutlet UILabel *type;
// TYPE ???

//query #2: description, categories, fan_count, general_info, checkins, founded, company_overview, mission, products, location

//query #3: parking, hours, public_transit, attire, payment_options, culinary_team, general_manager, price_range, restaurant_services, restaurant_specialties


//query #4
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) IBOutlet UIImageView *picImageView;

//orphans


- (id)initwithPerson:(Person *)person;
- (id)initWithCheckin:(Checkin *)checkin;
- (id)initWithMapItem:(MapItem *)mapItem;

@end
