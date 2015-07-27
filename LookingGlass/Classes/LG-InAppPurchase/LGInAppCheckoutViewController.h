//
//  LGInAppCheckoutViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>


@interface LGInAppCheckoutViewController : UITableViewController <SKProductsRequestDelegate>

@property (nonatomic, retain) IBOutlet UIBarButtonItem *buyButton;

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UILabel *saleTotalLabel;
@property (nonatomic, retain) NSMutableArray *shoppingCartContents;


@end
