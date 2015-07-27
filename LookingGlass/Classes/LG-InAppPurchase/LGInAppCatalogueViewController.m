//
//  LGInAppCatalogueViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGInAppCatalogueViewController.h"
#import "LGInAppSaleViewController.h"
#import "LGInAppCheckoutViewController.h"

#import "LGAppDeclarations.h"
#import "LGAppDataFeed.h"

@interface LGInAppCatalogueViewController()

- (void)doInAppSalePromotionForDataFeed:(LGDataFeedType)dataFeedType;
- (void)addFreeBadgeToCatalogueButton:(UIButton *)button;

@end

@implementation LGInAppCatalogueViewController

@synthesize scrollview;

@synthesize goToCheckoutButton;

@synthesize forBusinessLabel;
@synthesize forShoppingLabel;
@synthesize forSocialLabel;

@synthesize buyAddressBook;
@synthesize buyBeacon;
@synthesize buyCalendar;
@synthesize buyFacebook;
@synthesize buyFourSquare;
@synthesize buyGooglePlus;
@synthesize buyGowalla;
@synthesize buyGroupon;
@synthesize buyJive;
@synthesize buyLinkedIn;
@synthesize buyLOCKERZ;
@synthesize buyMySpace;
@synthesize buyOutlook;
@synthesize buySkype;
@synthesize buyTwitter;

@synthesize priceLableAddressBook;
@synthesize priceLableBeacon;
@synthesize priceLableCalendar;
@synthesize priceLableFacebook;
@synthesize priceLableFourSquare;
@synthesize priceLableGooglePlus;
@synthesize priceLableGowalla;
@synthesize priceLableGroupon;
@synthesize priceLableJive;
@synthesize priceLableLinkedIn;
@synthesize priceLableLOCKERZ;
@synthesize priceLableMySpace;
@synthesize priceLableOutlook;
@synthesize priceLableSkype;
@synthesize priceLableTwitter;


- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
        //
        // object instance variables go here
        //
    }
    if (OBJECT_DEBUG) {
        NSLog(@"%@.%@",[[self class] description], suffix);
    }
}

#pragma mark - UI Responders
- (IBAction) doBuyAddressBook:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyAddressBook:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeAddressBook];
}


- (IBAction) doBuyBeacon:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyBeacon:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeBeacon];
}
- (IBAction) doBuyCalendar:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyCalendar:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeCalendar];
}
- (IBAction) doBuyFacebook:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyFacebook:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeFaceBookFriend];
}
- (IBAction) doBuyFourSquare:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyFourSquare:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeFourSquare];
}
- (IBAction) doBuyGooglePlus:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyGooglePlus:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeGooglePlus];
}
- (IBAction) doBuyGowalla:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyGowalla:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeGowalla];
}
- (IBAction) doBuyGroupon:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyGroupon:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeGroupon];
}
- (IBAction) doBuyJive:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyJive:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeJive];
}
- (IBAction) doBuyLinkedIn:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyLinkedIn:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeLinkedIn];
}
- (IBAction) doBuyLOCKERZ:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyLOCKERZ:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeLOCKERZ];
}
- (IBAction) doBuyMySpace:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyMySpace:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeMySpace];
}
- (IBAction) doBuyOutlook:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyOutlook:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeOutlook];
}
- (IBAction) doBuySkype:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuySkype:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeSkype];
}
- (IBAction) doBuyTwitter:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBuyTwitter:sender()"];
    [self doInAppSalePromotionForDataFeed:LGDataFeedTypeTwitter];
}

- (void) doGoToCheckout
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doGoToCheckout:sender()"];
    
    LGInAppCheckoutViewController *vc = [[LGInAppCheckoutViewController alloc] initWithNibName:@"LGInAppCheckoutViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    

}

- (void)doInAppSalePromotionForDataFeed:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doInAppSalePromotion()"];
    
    LGInAppSaleViewController *tvc  = [[LGInAppSaleViewController alloc] initWithNibName:@"LGInAppSaleViewController" bundle:nil];
    tvc.dataFeedType                = dataFeedType;
    
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
}

- (void)addFreeBadgeToCatalogueButton:(UIButton *)button
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"addFreeBadgeToCatalogueImageView()"];

    [button addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LGTableViewCell_geocodeStatusImage_OK"]]];

}


#pragma mark - object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithNibName()"];
        
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidLoad()"];
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"LGInAppCatalogueViewController_Title", @"Data Sources");
    
    NSLog(@"FIX NOTE: FIX ME!!");
    [self addFreeBadgeToCatalogueButton:self.buyCalendar];

    
    self.priceLableAddressBook.text     = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeAddressBook];
    self.priceLableBeacon.text          = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeBeacon];
    self.priceLableCalendar.text        = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeCalendar];
    self.priceLableFacebook.text        = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeFaceBookFriend];
    self.priceLableFourSquare.text      = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeFourSquare];
    self.priceLableGooglePlus.text      = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeGooglePlus];
    self.priceLableGowalla.text         = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeGowalla];
    self.priceLableGroupon.text         = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeGroupon];
    self.priceLableJive.text            = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeJive];
    self.priceLableLinkedIn.text        = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeLinkedIn];
    self.priceLableLOCKERZ.text         = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeLOCKERZ];
    self.priceLableMySpace.text         = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeMySpace];
    self.priceLableOutlook.text         = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeOutlook];
    self.priceLableSkype.text           = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeSkype];
    self.priceLableTwitter.text         = [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:LGDataFeedTypeTwitter];

    
    self.forBusinessLabel.text          = [NSString stringWithFormat:NSLocalizedString(@"LGInAppCatalogueVC_forBusiness", @"%1$@ For Business"), NSLocalizedString(@"AppTitle", @"Looking Glass")];
    self.forSocialLabel.text            = [NSString stringWithFormat:NSLocalizedString(@"LGInAppCatalogueVC_forSocial", @"%1$@ For Your Friends"), NSLocalizedString(@"AppTitle", @"Looking Glass")];
    self.forShoppingLabel.text          = [NSString stringWithFormat:NSLocalizedString(@"LGInAppCatalogueVC_forShopping", @"%1$@ For Shopping and Dining"), NSLocalizedString(@"AppTitle", @"Looking Glass")];
    
    [self.forBusinessLabel sizeToFit];
    [self.forSocialLabel sizeToFit];
    [self.forShoppingLabel sizeToFit];

    self.scrollview.contentSize=CGSizeMake(320,900);

    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
    
    [LGAppDataFeed initShoppingCart];

    self.goToCheckoutButton        = [[UIBarButtonItem alloc] 
                                      initWithTitle:NSLocalizedString(@"goToCheckoutButton", @"Go To Checkout") 
                                      style:UIBarButtonItemStyleBordered 
                                      target:self 
                                      action:@selector(doGoToCheckout)
                                      ];
    
    [toolbarButtons addObject:self.goToCheckoutButton];
    
    [self setToolbarItems:toolbarButtons];
    [toolbarButtons release];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    if (OBJECT_DEBUG) [self logObjectVariables:@"didReceiveMemoryWarning()"];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([LGAppDataFeed getCartQtyTotal] > 0) [self.navigationController setToolbarHidden:NO animated:NO];
    else [self.navigationController setToolbarHidden:YES animated:NO];
    
    
}

- (void)viewDidUnload
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload()"];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    scrollview = nil;
    goToCheckoutButton = nil;
    
    forBusinessLabel = nil;
    forSocialLabel = nil;
    forShoppingLabel = nil;
    
    buyAddressBook = nil;
    buyBeacon = nil;
    buyCalendar = nil;
    buyFacebook = nil;
    buyFourSquare = nil;
    buyGooglePlus = nil;
    buyGowalla = nil;
    buyGroupon = nil;
    buyJive = nil;
    buyLinkedIn = nil;
    buyLOCKERZ = nil;
    buyMySpace = nil;
    buyOutlook = nil;
    buySkype = nil;
    buyTwitter = nil;
    
    priceLableAddressBook = nil;
    priceLableBeacon = nil;
    priceLableCalendar = nil;
    priceLableFacebook = nil;
    priceLableFourSquare = nil;
    priceLableGooglePlus = nil;
    priceLableGowalla = nil;
    priceLableGroupon = nil;
    priceLableJive = nil;
    priceLableLinkedIn = nil;
    priceLableLOCKERZ = nil;
    priceLableMySpace = nil;
    priceLableOutlook = nil;
    priceLableSkype = nil;
    priceLableTwitter = nil;

}

- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];

    [scrollview release];
    [goToCheckoutButton release];
    
    [forBusinessLabel release];
    [forSocialLabel release];
    [forShoppingLabel release];
    
    [buyAddressBook release];
    [buyBeacon release];
    [buyCalendar release];
    [buyFacebook release];
    [buyFourSquare release];
    [buyGooglePlus release];
    [buyGowalla release];
    [buyGroupon release];
    [buyJive release];
    [buyLinkedIn release];
    [buyLOCKERZ release];
    [buyMySpace release];
    [buyOutlook release];
    [buySkype release];
    [buyTwitter release];
    
    [priceLableAddressBook release];
    [priceLableBeacon release];
    [priceLableCalendar release];
    [priceLableFacebook release];
    [priceLableFourSquare release];
    [priceLableGooglePlus release];
    [priceLableGowalla release];
    [priceLableGroupon release];
    [priceLableJive release];
    [priceLableLinkedIn release];
    [priceLableLOCKERZ release];
    [priceLableMySpace release];
    [priceLableOutlook release];
    [priceLableSkype release];
    [priceLableTwitter release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"shouldAutorotateToInterfaceOrientation()"];

    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
