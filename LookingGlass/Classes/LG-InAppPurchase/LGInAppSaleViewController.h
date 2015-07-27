//
//  LGInAppSaleViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGAppDeclarations.h"
#import "LGReflectedImageView.h"
#import <AVFoundation/AVFoundation.h>

@interface LGInAppSaleViewController : UIViewController <AVAudioPlayerDelegate>
{
    
	LGReflectedImageView *iconImageView;
	UIImageView *reflectionView;
    LGDataFeedType dataFeedType;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *goToCheckoutButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addToCartButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *removeFromCartButton;


@property (nonatomic, retain) IBOutlet UILabel *priceLable;
@property (nonatomic, retain) IBOutlet UILabel *advertLabel;

@property (nonatomic, retain) UIImageView *shoppingCartImageView;

@property (nonatomic,retain) LGReflectedImageView *iconImageView;
@property (nonatomic,retain) UIImageView *reflectionView;
@property LGDataFeedType dataFeedType;

@end
