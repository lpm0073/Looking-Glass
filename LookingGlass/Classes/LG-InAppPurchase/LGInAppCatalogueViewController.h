//
//  LGInAppCatalogueViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGInAppCatalogueViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIScrollView *scrollview;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goToCheckoutButton;

@property (nonatomic, retain) IBOutlet UILabel *forBusinessLabel;
@property (nonatomic, retain) IBOutlet UILabel *forSocialLabel;
@property (nonatomic, retain) IBOutlet UILabel *forShoppingLabel;


@property (nonatomic, retain) IBOutlet UIButton *buyAddressBook;
@property (nonatomic, retain) IBOutlet UIButton *buyBeacon;
@property (nonatomic, retain) IBOutlet UIButton *buyCalendar;
@property (nonatomic, retain) IBOutlet UIButton *buyFacebook;
@property (nonatomic, retain) IBOutlet UIButton *buyFourSquare;
@property (nonatomic, retain) IBOutlet UIButton *buyGooglePlus;
@property (nonatomic, retain) IBOutlet UIButton *buyGowalla;
@property (nonatomic, retain) IBOutlet UIButton *buyGroupon;
@property (nonatomic, retain) IBOutlet UIButton *buyJive;
@property (nonatomic, retain) IBOutlet UIButton *buyLinkedIn;
@property (nonatomic, retain) IBOutlet UIButton *buyLOCKERZ;
@property (nonatomic, retain) IBOutlet UIButton *buyMySpace;
@property (nonatomic, retain) IBOutlet UIButton *buyOutlook;
@property (nonatomic, retain) IBOutlet UIButton *buySkype;
@property (nonatomic, retain) IBOutlet UIButton *buyTwitter;

@property (nonatomic, retain) IBOutlet UILabel *priceLableAddressBook;
@property (nonatomic, retain) IBOutlet UILabel *priceLableBeacon;
@property (nonatomic, retain) IBOutlet UILabel *priceLableCalendar;
@property (nonatomic, retain) IBOutlet UILabel *priceLableFacebook;
@property (nonatomic, retain) IBOutlet UILabel *priceLableFourSquare;
@property (nonatomic, retain) IBOutlet UILabel *priceLableGooglePlus;
@property (nonatomic, retain) IBOutlet UILabel *priceLableGowalla;
@property (nonatomic, retain) IBOutlet UILabel *priceLableGroupon;
@property (nonatomic, retain) IBOutlet UILabel *priceLableJive;
@property (nonatomic, retain) IBOutlet UILabel *priceLableLinkedIn;
@property (nonatomic, retain) IBOutlet UILabel *priceLableLOCKERZ;
@property (nonatomic, retain) IBOutlet UILabel *priceLableMySpace;
@property (nonatomic, retain) IBOutlet UILabel *priceLableOutlook;
@property (nonatomic, retain) IBOutlet UILabel *priceLableSkype;
@property (nonatomic, retain) IBOutlet UILabel *priceLableTwitter;


- (IBAction) doBuyAddressBook:(id)sender;
- (IBAction) doBuyBeacon:(id)sender;
- (IBAction) doBuyCalendar:(id)sender;
- (IBAction) doBuyFacebook:(id)sender;
- (IBAction) doBuyFourSquare:(id)sender;
- (IBAction) doBuyGooglePlus:(id)sender;
- (IBAction) doBuyGowalla:(id)sender;
- (IBAction) doBuyGroupon:(id)sender;
- (IBAction) doBuyJive:(id)sender;
- (IBAction) doBuyLinkedIn:(id)sender;
- (IBAction) doBuyLOCKERZ:(id)sender;
- (IBAction) doBuyMySpace:(id)sender;
- (IBAction) doBuyOutlook:(id)sender;
- (IBAction) doBuySkype:(id)sender;
- (IBAction) doBuyTwitter:(id)sender;

@end
