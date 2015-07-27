//
//  LGDataFeedRefreshViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGAppDeclarations.h"
#import "LGAppIntegratorAddressBook.h"
#import "LGAppIntegratorFacebook.h"
#import "LGAppIntegratorLinkedIn.h"

@interface LGDataFeedRefreshViewController : UIViewController <LGAppDataFeedDelegate>

@property (nonatomic, retain, readonly) LGAppIntegratorAddressBook *integratorAddressBook;
@property (nonatomic, retain, readonly) LGAppIntegratorFacebook *integratorFacebook;
@property (nonatomic, retain, readonly) LGAppIntegratorLinkedIn *integratorLinkedIn;


@property (nonatomic) LGDataFeedType dataFeedType;
@property (nonatomic, retain) IBOutlet UIImageView *dataFeedImageView;
@property (nonatomic, retain) IBOutlet UILabel *purchaseDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *systemMsgLabel;
@property (nonatomic, retain) IBOutlet UILabel *dataFeedStateLabel;
@property (nonatomic, retain) IBOutlet UIButton *refreshButton;
@property (nonatomic, retain) IBOutlet UIButton *scanButton;
@property (nonatomic, retain) IBOutlet UIButton *disconnectButton;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;

@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

- (id)initWithDataFeedType:(LGDataFeedType)dataFeedType;
- (IBAction)doRefresh:(id)sender;
- (IBAction)doDisconnect:(id)sender;
- (IBAction)doConnect:(id)sender;
- (IBAction)doScan:(id)sender;

@end
