//
//  LGInAppSaleViewController_Authorize.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGAppDeclarations.h"


@interface LGInAppSaleViewController_Authorize : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *successLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@property (nonatomic, retain) IBOutlet UIButton *authorizeDataSourceButton;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

@property LGDataFeedType dataFeedType;



- (IBAction)authorizeDataSourceButtonClicked: (id) sender;


@end
