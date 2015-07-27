//
//  LGRootViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGMainMenuViewController.h"
#import <GLKit/GLKMathUtils.h>

#import "LGInAppCatalogueViewController.h"
#import "LGDataFeedRefreshTableViewController.h"
#import "LGTVCPeople.h"
#import "LGTVCNearbyPlaces.h"
#import "LGAddressViewController.h"

@interface LGMainMenuViewController()

@property (nonatomic, retain, readonly) LGAppDelegate *appDelegate;

@end


@implementation LGMainMenuViewController

@synthesize appDelegate;

//Toolbar buttons
@synthesize refreshButton;
@synthesize catalogueButton;

//Main menu buttons
@synthesize nearbyAnythingButton;

@synthesize nearbyPeopleButton;

@synthesize peopleNearButton;

@synthesize nearbyPlacesButton;

@synthesize placesNearButton;


//orphaned
@synthesize peopleButton;

- (LGAppDelegate *)appDelegate
{
    if (!appDelegate) {
        appDelegate = (LGAppDelegate *) [[[UIApplication sharedApplication] delegate] retain];
    }
    return appDelegate;
}

- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) NSLog(@"%@().%@",[[self class] description], suffix);

}

#pragma mark - Launchpoints for Data Sources
- (IBAction)doRefresh:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doRefresh:sender()"];
    
    LGDataFeedRefreshTableViewController *tvc = [[LGDataFeedRefreshTableViewController alloc] initWithNibName:@"LGDataFeedRefreshTableViewController" bundle:nil];
    
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
    
}

- (IBAction)doCatalogue:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doCatalogue:sender()"];
    
    LGInAppCatalogueViewController *tvc = [[LGInAppCatalogueViewController alloc] initWithNibName:@"LGInAppCatalogueViewController" bundle:nil];
    
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
    
}



- (IBAction)doPeopleNear:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doPeopleNear()"];

    LGAddressViewController *avc = [[LGAddressViewController alloc] initWithQueryTuype:LGQueryTypePeople];
    [self.navigationController pushViewController:avc animated:YES];
    [avc release];

}


- (IBAction)doNearbyAnything:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doNearbyAnything()"];

    LGTVCNearbyPlaces *tvc  = [[LGTVCNearbyPlaces alloc] init];
    tvc.queryType = LGQueryTypePeopleAndPlaces;
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
    
}

- (IBAction)doNearbyPlaces:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doNearbyPlaces()"];

    LGTVCNearbyPlaces *tvc  = [[LGTVCNearbyPlaces alloc] init];
    tvc.queryType = LGQueryTypePlace;
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
    
}

- (IBAction)doNearbyPeople:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doNearbyPeople()"];
    
    LGTVCNearbyPlaces *tvc  = [[LGTVCNearbyPlaces alloc] init];
    tvc.queryType = LGQueryTypePeople;
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
    
    
}


- (IBAction)doPlacesNear:(id)sender
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"doPlacesNear()"];
    
    LGAddressViewController *avc = [[LGAddressViewController alloc] initWithQueryTuype:LGQueryTypePlace];
    [self.navigationController pushViewController:avc animated:YES];
    [avc release];
    
}


- (IBAction)doPeople:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doPeople()"];
    
    LGTVCPeople *tvc = [[LGTVCPeople alloc] init];
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
    
}

#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithNibName()"];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    if (OBJECT_DEBUG) [self logObjectVariables:@"didReceiveMemoryWarning()"];
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)makeLabelWithText:(NSString *)text ForView:(UIImageView *)view Rotated:(CGFloat)rotation
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 20)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    label.center = CGPointMake(view.center.x, view.center.y);
    label.transform = CGAffineTransformMakeRotation(rotation);
    
    [view addSubview:label];
    [label release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidLoad()"];
   
    self.title = NSLocalizedString(@"AppTitle", @"localized name of the application - aka Looking Glass");

    [self makeLabelWithText:NSLocalizedString(@"nearbyPeopleLabel", @"") ForView:self.nearbyPeopleButton.imageView Rotated:(1.75f * M_PI)];
    [self makeLabelWithText:NSLocalizedString(@"peopleNearLabel", @"") ForView:self.peopleNearButton.imageView Rotated:(M_PI / 4.0f)];
    [self makeLabelWithText:NSLocalizedString(@"nearbyAnythingLabel", @"") ForView:self.nearbyAnythingButton.imageView Rotated:0.0f];
    [self makeLabelWithText:NSLocalizedString(@"nearbyPlacesLabel", @"") ForView:self.nearbyPlacesButton.imageView Rotated:(M_PI / 4.0f)];
    [self makeLabelWithText:NSLocalizedString(@"placesNearLabel", @"") ForView:self.placesNearButton.imageView Rotated:(1.75f * M_PI)];
    
    //orphan
    [peopleButton setTitle:NSLocalizedString(@"peopleButton", @"") forState:UIControlStateNormal];
    [peopleButton setTitle:NSLocalizedString(@"peopleButton", @"") forState:UIControlStateHighlighted];
    
    self.navigationController.navigationBar.translucent      = NO;
    self.navigationController.navigationBar.tintColor        = [LGAppDeclarations colorForNavigationBar];
    self.navigationController.navigationBar.alpha            = 1;
    

    self.refreshButton        = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                              target:self 
                                                                              action:@selector(doRefresh:)
                                 ];
    
    self.catalogueButton      = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                              target:self 
                                                                              action:@selector(doCatalogue:)
                                 ];
    
    
    self.refreshButton.style  = UIBarButtonItemStyleBordered;

    [self setToolbarItems:[NSMutableArray arrayWithObjects:
                           self.refreshButton, 
                           self.catalogueButton,
                           nil
                           ]
     ];

    self.navigationController.toolbar.translucent = NO;
    self.navigationController.toolbar.tintColor   = [LGAppDeclarations colorForToolbar];
    self.navigationController.toolbar.alpha       = 1;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewWillAppear()"];
    
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    //we're arriving to the main menu view controller because we've either just launched the app, or
    //because the view controller popped a view. either way, whatever might have been in managedobject context is no longer relevent.
    //so, ....
    //release (eg "forget") any managed objects that are currently in the context.
    [self.appDelegate.managedObjectContext reset];  

}
- (void)viewDidUnload
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload()"];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    refreshButton = nil;
    nearbyAnythingButton = nil;
    nearbyPeopleButton = nil;
    peopleNearButton = nil;
    nearbyPlacesButton = nil;
    placesNearButton = nil;
    peopleButton = nil;
}


- (void)dealloc
{
    [refreshButton release];
    [nearbyAnythingButton release];
    [nearbyPeopleButton release];
    [peopleNearButton release];
    [nearbyPlacesButton release];
    [placesNearButton release];
    [peopleButton release];
    
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
