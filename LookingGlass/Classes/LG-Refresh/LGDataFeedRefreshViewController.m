//
//  LGDataFeedRefreshViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGDataFeedRefreshViewController.h"
#import "LGDataFeedRefreshTableViewController.h"
#import "LGAppIntegratorFacebook.h"
#import "LGAppIntegratorLinkedIn.h"
#import "LGAppIntegratorAddressBook.h"

#import "Attendee.h"
#import "Checkin.h"
#import "MapItem.h"
#import "Person.h"

@interface LGDataFeedRefreshViewController()

@property (nonatomic, retain, readonly) LGAppDelegate *appDelegate;

- (BOOL)cancelAllRequests;
- (void)resetIntegrators;

- (void)initSystemStartupMessage;
- (void)initDataFeedStateMessage;
- (void)doConnectionButtonsVisibility;
- (void)logObjectVariables:(NSString *)suffix;

@end

@implementation LGDataFeedRefreshViewController

@synthesize appDelegate;
@synthesize integratorAddressBook;
@synthesize integratorFacebook;
@synthesize integratorLinkedIn;

@synthesize dataFeedType;
@synthesize dataFeedImageView;
@synthesize purchaseDateLabel;
@synthesize systemMsgLabel;
@synthesize dataFeedStateLabel;
@synthesize refreshButton;
@synthesize scanButton;
@synthesize disconnectButton;
@synthesize connectButton;

@synthesize progressView;

#pragma mark - Setters and Getters
- (LGAppDelegate *)appDelegate
{
    if (!appDelegate) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"appDelegate ()"];

        appDelegate = [(LGAppDelegate *)[UIApplication sharedApplication].delegate retain];
    }
    return appDelegate;
    
}

- (LGAppIntegratorAddressBook *)integratorAddressBook
{
    if (!integratorAddressBook) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"integratorAddressBook ()"];
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeAddressBook]) return nil;
        
        integratorAddressBook = [[[LGAppIntegratorAddressBook alloc] init] retain];
        integratorAddressBook.progressView = self.progressView;

    }
    return integratorAddressBook;
}

- (LGAppIntegratorFacebook *)integratorFacebook
{
    if (!integratorFacebook) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"LGAppIntegratorFacebook ()"];
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFaceBookFriend]) return nil;
        
        integratorFacebook = [[[LGAppIntegratorFacebook alloc] init] retain];
        integratorFacebook.progressView = self.progressView;
    }
    return integratorFacebook;
}
- (LGAppIntegratorLinkedIn *)integratorLinkedIn
{
    if (!integratorLinkedIn) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"integratorLinkedIn ()"];

        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeLinkedIn]) return nil;
        
        integratorLinkedIn = [[[LGAppIntegratorLinkedIn alloc] init] retain];
        integratorLinkedIn.progressView = self.progressView;
    }
    return integratorLinkedIn;
}

#pragma mark - Actions
- (IBAction)doBackButton:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBackButton:"];
    
    [self cancelAllRequests];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doRefresh:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doRefresh:sender()"];

    switch (self.dataFeedType) {
        case LGDataFeedTypeAddressBook:
            if (self.integratorAddressBook) [self.integratorAddressBook getPeoplewithCycleTest:NO];
            break;
        case LGDataFeedTypeBeacon:
        case LGDataFeedTypeCalendar:
        case LGDataFeedTypeFaceBookFriend:
            if (self.integratorFacebook) [self.integratorFacebook getPeoplewithCycleTest:NO];
            break;
        case LGDataFeedTypeFaceBookCheckin: break;
        case LGDataFeedTypeFaceBookPlace: break;
        case LGDataFeedTypeFourSquare: break;
        case LGDataFeedTypeGooglePlaces: break;
        case LGDataFeedTypeGooglePlus: break;
        case LGDataFeedTypeGowalla: break;
        case LGDataFeedTypeGroupon: break;
        case LGDataFeedTypeJive: break;
        case LGDataFeedTypeLinkedIn:
            if (self.integratorLinkedIn) [self.integratorLinkedIn getPeoplewithCycleTest:NO];
            break;
        case LGDataFeedTypeLOCKERZ: break;
        case LGDataFeedTypeMySpace: break;
        case LGDataFeedTypeOutlook: break;
        case LGDataFeedTypeSkype: break;
        case LGDataFeedTypeTwitter: break;
            break;
    }

}
- (IBAction)doScan:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doScan:sender()"];

    [MapItem scanMapItemsForCoordinatesForDataFeedType:self.dataFeedType 
                                InManagedObjectContext:self.appDelegate.managedObjectContext];
    
    [self initDataFeedStateMessage];
}

- (IBAction)doDisconnect:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doDisconnect:sender()"];

    if (![LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType]) return;
    
    if ([LGAppDataFeed isEnabledDataFeedType:self.dataFeedType]) {
        switch (self.dataFeedType) {
            case LGDataFeedTypeAddressBook:
                if (self.integratorAddressBook) [self.integratorAddressBook DisableDataFeed];
                break;
            case LGDataFeedTypeBeacon:
            case LGDataFeedTypeCalendar:
            case LGDataFeedTypeFaceBookFriend:
                if (self.integratorFacebook) [self.integratorFacebook DisableDataFeed];
                break;
            case LGDataFeedTypeFaceBookCheckin: break;
            case LGDataFeedTypeFaceBookPlace: break;
            case LGDataFeedTypeFourSquare: break;
            case LGDataFeedTypeGooglePlaces: break;
            case LGDataFeedTypeGooglePlus: break;
            case LGDataFeedTypeGowalla: break;
            case LGDataFeedTypeGroupon: break;
            case LGDataFeedTypeJive: break;
            case LGDataFeedTypeLinkedIn: 
                if (self.integratorLinkedIn) [self.integratorLinkedIn DisableDataFeed];
                break;
            case LGDataFeedTypeLOCKERZ: break;
            case LGDataFeedTypeMySpace: break;
            case LGDataFeedTypeOutlook: break;
            case LGDataFeedTypeSkype: break;
            case LGDataFeedTypeTwitter: 
                break;
        }
        [self doConnectionButtonsVisibility];
    }

}
- (IBAction)doConnect:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doConnect:sender()"];

    if ([LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType]) {
        switch (self.dataFeedType) {
            case LGDataFeedTypeAddressBook:
                if (self.integratorAddressBook) [self.integratorAddressBook EnableDataFeed];
                break;
            case LGDataFeedTypeBeacon:
            case LGDataFeedTypeCalendar:
            case LGDataFeedTypeFaceBookFriend:
                if (self.integratorFacebook) [self.integratorFacebook EnableDataFeed];
                break;
            case LGDataFeedTypeFaceBookCheckin: break;
            case LGDataFeedTypeFaceBookPlace: break;
            case LGDataFeedTypeFourSquare: break;
            case LGDataFeedTypeGooglePlaces: break;
            case LGDataFeedTypeGooglePlus: break;
            case LGDataFeedTypeGowalla: break;
            case LGDataFeedTypeGroupon: break;
            case LGDataFeedTypeJive: break;
            case LGDataFeedTypeLinkedIn:
                if (self.integratorLinkedIn) [self.integratorLinkedIn EnableDataFeed];
                break;
            case LGDataFeedTypeLOCKERZ: break;
            case LGDataFeedTypeMySpace: break;
            case LGDataFeedTypeOutlook: break;
            case LGDataFeedTypeSkype: break;
            case LGDataFeedTypeTwitter:
                break;
        }
        [self doRefresh:sender];
        [self doConnectionButtonsVisibility];
    }
}


- (void)doConnectionButtonsVisibility
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doConnectionButtonsVisibility()"];

    if ([LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType]) {
        if ([LGAppDataFeed isEnabledDataFeedType:self.dataFeedType]) {
            self.connectButton.hidden = YES; 
            self.disconnectButton.hidden = NO;
        } else {
            self.connectButton.hidden = NO; 
            self.disconnectButton.hidden = YES;
        }
    } else {
        self.connectButton.hidden = YES; 
        self.disconnectButton.hidden = YES;
    }
}

#pragma mark - LGAppDataFeedDelegate
- (void)didGetPeople
{
    self.progressView.hidden = YES;
}
- (void)didGetPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location
{
    self.progressView.hidden = YES;
}

#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithNibName:bundle()"];

        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"didReceiveMemoryWarning()"];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithDataFeedType:(LGDataFeedType)thisDataFeedType
{
    if (self = [self initWithNibName:@"LGDataFeedRefreshViewController" bundle:nil]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithDataFeedType()"];
        self.dataFeedType = thisDataFeedType;
    }
    return self;
}
- (void)loadView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"loadView()"];
    [super loadView];
    
    UIBarButtonItem *barbutton              = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LGCoreDataTVC_BackButton", @"Back")
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self 
                                                                              action:@selector(doBackButton:)];
    
    self.navigationItem.leftBarButtonItem   = barbutton;
    [barbutton release];

    
    
    self.title = [LGAppDataFeed nameForDataFeedType:self.dataFeedType];
    self.dataFeedImageView.image = [LGAppDataFeed imageForDataFeedTypeLarge:self.dataFeedType];
    self.purchaseDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LGDFR_purchaseDate", @"Purchased %1$@"), 
                                   [LGAppDataFeed purchaseDateForDataFeedTypeAsLocalizedString:self.dataFeedType]];
    
    [self initSystemStartupMessage];
    self.systemMsgLabel.font        = [UIFont systemFontOfSize:13];
    self.systemMsgLabel.textColor   = [UIColor redColor];
    
    [self initDataFeedStateMessage];
    self.dataFeedStateLabel.font    = [UIFont systemFontOfSize:13];
    self.dataFeedStateLabel.textColor = [UIColor blueColor];
    
    [self.refreshButton setTitle:NSLocalizedString(@"LGDFR_refreshButton", @"") forState:UIControlStateNormal];
    [self.scanButton setTitle:NSLocalizedString(@"LGDFR_scanButton", @"") forState:UIControlStateNormal];
    [self.connectButton setTitle:NSLocalizedString(@"LGDFR_connectButton", @"") forState:UIControlStateNormal];
    [self.disconnectButton setTitle:NSLocalizedString(@"LGDFR_disconnectButton", @"") forState:UIControlStateNormal];
    
    [self doConnectionButtonsVisibility];

    //progressview intialization
    [self.navigationController setToolbarHidden:NO animated:NO];
    self.progressView                   = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 
                                                                                           0, 
                                                                                           self.view.frame.size.width - 20, 
                                                                                           self.navigationController.toolbar.frame.size.height
                                                                                           )
                                           ];
    
    self.progressView.trackTintColor    = [LGAppDeclarations colorForToolbar];
    self.progressView.progressTintColor = [UIColor lightGrayColor];
    
    self.progressView.progressViewStyle = UIProgressViewStyleBar;
    [self.progressView setHidden:YES];
    [self.progressView setProgress:0];
    
    UIBarButtonItem *progressItem = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
    
    [self setToolbarItems:[NSMutableArray arrayWithObjects:progressItem, nil]];
    [progressItem release];
}


- (void)viewDidUnload
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload()"];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    appDelegate = nil;
    integratorAddressBook = nil;
    integratorFacebook = nil;
    integratorLinkedIn = nil;
    
    progressView = nil;
    dataFeedImageView = nil;
    purchaseDateLabel = nil;
    systemMsgLabel = nil;
    dataFeedStateLabel = nil;
    
    refreshButton = nil;
    scanButton = nil;
    disconnectButton = nil;
    connectButton = nil;

}

- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    [self resetIntegrators];
    
    [appDelegate release];
    
    [progressView release];
    [dataFeedImageView release];
    [purchaseDateLabel release];
    [systemMsgLabel release];
    [dataFeedStateLabel release];
    
    [refreshButton release];
    [refreshButton release];
    [disconnectButton release];
    [connectButton release];
    
    [super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)cancelAllRequests
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"cancelAllRequests"];
    [self resetIntegrators];
    
    return YES;
}

- (void)resetIntegrators
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"resetIntegrators()"];
    
    if (integratorFacebook) {
        [integratorFacebook cancelRequest];
        integratorFacebook.delegate = nil;
        [integratorFacebook release];
        integratorFacebook = nil;
    }
    if (integratorAddressBook) {
        [integratorAddressBook cancelRequest];
        integratorAddressBook.delegate = nil;
        [integratorAddressBook release];
        integratorAddressBook = nil;
    }
    if (integratorLinkedIn) {
        [integratorLinkedIn cancelRequest];
        integratorLinkedIn.delegate = nil;
        [integratorLinkedIn release];
        integratorLinkedIn = nil;
    }
    
}



- (void)initSystemStartupMessage
{
    NSString *s = nil;
    
    s = [NSString stringWithFormat:@"People = %d", [Person recordsForDataFeedType:self.dataFeedType InManagedObjectContext:self.appDelegate.managedObjectContext]];
    s = [s stringByAppendingFormat:@"\nPlaces = %d", [MapItem recordsForDataFeedType:self.dataFeedType InManagedObjectContext:self.appDelegate.managedObjectContext]];

    s = [s stringByAppendingString:@"\nWIFI Connection = "];

    
    if (self.appDelegate.isDeviceConnectedToWifi) s = [s stringByAppendingFormat:@"YES"];
    else s = [s stringByAppendingFormat:@"NO"];
    
    s = [s stringByAppendingString:@"\nIs Charging = "];
    
    if (self.appDelegate.isDeviceCharging) s = [s stringByAppendingFormat:@"YES"];
    else s = [s stringByAppendingFormat:@"NO"];

    self.systemMsgLabel.text = s;
}

- (void)initDataFeedStateMessage
{
    NSString *s = nil;

    NSInteger fully_geocoded = [MapItem recordsForDataFeedType:self.dataFeedType
                                               GeocodeAccuracy:LGMapItemGeocodeAccuracy_Street
                                        InManagedObjectContext:self.appDelegate.managedObjectContext
                                ];
    
    NSInteger no_geocode = [MapItem recordsForDataFeedType:self.dataFeedType
                                           GeocodeAccuracy:LGMapItemGeocodeAccuracy_None
                                    InManagedObjectContext:self.appDelegate.managedObjectContext
                            ];
    
    NSInteger bad_address = [MapItem recordsForDataFeedType:self.dataFeedType
                                            GeocodeAccuracy:LGMapItemGeocodeAccuracy_BadAddress
                                     InManagedObjectContext:self.appDelegate.managedObjectContext
                             ];
    
    NSInteger partially_geocoded = [MapItem recordsForDataFeedType:self.dataFeedType InManagedObjectContext:self.appDelegate.managedObjectContext] - fully_geocoded - no_geocode - bad_address;
    
    s = [NSString stringWithFormat:@"Fully Geocoded: %d", fully_geocoded];
    s = [s stringByAppendingFormat:@"\nPartially geocoded: %d", partially_geocoded];
    s = [s stringByAppendingFormat:@"\nNo geocode: %d", no_geocode];
    s = [s stringByAppendingFormat:@"\nBad Address: %d", bad_address];
    
    self.dataFeedStateLabel.text = s;
    [self.dataFeedStateLabel setNeedsDisplay];
}

- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) {
        NSLog(@"%@.%@",[[self class] description], suffix);
    }
}


@end
