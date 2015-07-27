//
//  CoreDataTVC.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGCoreDataTVC.h"
#import "LGMapItemAnnotationView.h"
#import "LGDataModelObject.h"
#import "LGDetailViewController_AddressBook.h"
#import "LGDetailViewController_LinkedIn.h"
#import "LGDetailViewController_FacebookFriend.h"
#import "LGDetailViewController_FacebookPlace.h"


@interface LGCoreDataTVC()
{
    BOOL _isBusy;
}


- (void)createSearchBar;
- (void)performFetchForTableView:(UITableView *)thisTableView;

@end

@implementation LGCoreDataTVC

@synthesize dataModelObject;

@synthesize isMapViewShowing;

@synthesize isCancelled;
@synthesize buttonRefresh;
@synthesize progressView;

@synthesize tableView;
@synthesize mapView;
@synthesize appDelegate;
@synthesize context;

@synthesize integratorFacebook;
@synthesize integratorAddressBook;
@synthesize integratorLinkedIn;

@synthesize searchBar;
@synthesize subtitleKey;


#pragma mark Looking Glass Setters and Getters
- (Person *)person
{
    if ([self.dataModelObject isKindOfClass:[Person class]]) {
        return (Person *)self.dataModelObject;
    }
    return nil;
}
- (Checkin *)checkin
{
    if ([self.dataModelObject isKindOfClass:[Checkin class]]) {
        return (Checkin *)self.dataModelObject;
    }
    return nil;
}
- (MapItem *)mapItem
{
    if ([self.dataModelObject isKindOfClass:[MapItem class]]) {
        return (MapItem *)self.dataModelObject;
    } else {
        if (self.checkin) {
            return self.checkin.checkin_Mapitem;
        }
    }
    return nil;
}

- (NSInteger)ABRecordRefID
{
    NSString *str = nil;
    
    if (self.person) str = self.person.unique_id;
    else {
        if (self.mapItem) str = [self.mapItem.unique_id substringToIndex:(self.mapItem.unique_id.length - 1)];
        else if (self.checkin) {
            str = [self.checkin.unique_id substringToIndex:(self.checkin.unique_id.length - 1)];
        } 
    }
    if (str.length > 0) {
        return [str integerValue];
    }
    
    return 0;
}

- (BOOL)isTableViewShowing
{
    return !self.isMapViewShowing;
}

- (BOOL)isBusy
{
    if (integratorFacebook) {
        if (integratorFacebook.isBusy) return YES;
    }
    if (integratorAddressBook) {
        if (integratorAddressBook.isBusy) return YES;
    }
    if (integratorLinkedIn) {
        if (integratorLinkedIn.isBusy) return YES;
    }
    return _isBusy;
}
- (void)setIsBusy:(BOOL)newIsBusy
{
    _isBusy = newIsBusy;
}

- (BOOL)isDeviceMultitaskingSupported
{
    BOOL retVal = NO;
    UIDevice *device            = [[UIDevice currentDevice] retain];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]) retVal = device.multitaskingSupported;
    [device release];
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isDeviceMultitaskingSupported() = %d", retVal]];
    return retVal;
}

- (LGAppIntegratorFacebook *)integratorFacebook
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"integratorFacebook()"];
    
    if (!integratorFacebook) {
        
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFaceBookFriend]) return nil;
        if (![LGAppDataFeed isEnabledDataFeedType:LGDataFeedTypeFaceBookFriend]) return nil;

        integratorFacebook = [[[LGAppIntegratorFacebook alloc] init] retain];
        integratorFacebook.delegate     = self;
        integratorFacebook.progressView = self.progressView;
    }
    return integratorFacebook;
}
- (LGAppIntegratorAddressBook *)integratorAddressBook
{
    if (!integratorAddressBook) {
        
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeAddressBook]) return nil;
        if (![LGAppDataFeed isEnabledDataFeedType:LGDataFeedTypeAddressBook]) return nil;

        integratorAddressBook = [[[LGAppIntegratorAddressBook alloc] init] retain];
        integratorAddressBook.delegate      = self;
        integratorAddressBook.progressView  = self.progressView;
    } 
    return integratorAddressBook;
}
- (LGAppIntegratorLinkedIn *)integratorLinkedIn
{
    if (!integratorLinkedIn) {
        
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeLinkedIn]) return nil;
        if (![LGAppDataFeed isEnabledDataFeedType:LGDataFeedTypeLinkedIn]) return nil;

        integratorLinkedIn = [[[LGAppIntegratorLinkedIn alloc] init] retain];
        integratorLinkedIn.delegate     = self;
        integratorLinkedIn.progressView = self.progressView;
    }
    return integratorLinkedIn;
}

- (LGAppDelegate *)appDelegate
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"appDelegate()"];

    if (!appDelegate) appDelegate = (LGAppDelegate *) [[[UIApplication sharedApplication] delegate] retain];
    return appDelegate;
}

- (LGMapView *)mapView
{
    if (!mapView) {
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"mapView(instanitating)"];
        if (self.isCancelled) return nil;
        
        mapView = [[[LGMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] retain];
        CGRect mapFrame;
        
        mapFrame.origin = self.view.bounds.origin;
        mapFrame.size   = CGSizeMake(self.view.bounds.size.width, 
                                     self.view.bounds.size.height + self.navigationController.navigationBar.bounds.size.height + self.navigationController.toolbar.bounds.size.height);
        mapView.frame   = mapFrame;
        mapView.delegate = self;
        mapView.hidden = YES;
        [self.view addSubview:mapView];
    }
    return mapView;
}

- (NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"context()"];
    
    if (!context) context = [self.appDelegate.managedObjectContext retain];
    return context;
}

#pragma mark Looking Glass Methods
- (IBAction)doBackButton:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBackButton:"];
    [self cancelAllRequests];
    
    if (self.tableView.decelerating || self.tableView.isDragging) {
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    }

    if (self.isMapViewShowing) [self showTableView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doRefresh:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doRefresh:sender() - super class"];
    if (self.isCancelled) return;
    
    [self housekeepingForVisibleRows];
    [MapItem refreshAllMapitemsInManagedObjectContext:self.appDelegate.managedObjectContext];
    
}

- (void)doPushNextView
{
    //misc mapView screen settings which need to be restored to standard values before we push the next view onto the stack.
    self.navigationController.navigationBar.alpha       = 1;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    
}



- (BOOL)cancelAllRequests
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"cancelAllRequests"];
    isCancelled = YES;

    [self.fetchedResultsController.fetchedObjects makeObjectsPerformSelector:@selector(cancelAllRequests)];
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


- (void)showTableView
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"showTableView()"];

    isMapViewShowing                                    = NO;
    self.mapView.hidden                                 = YES;
    self.tableView.hidden                               = NO;
    self.navigationItem.rightBarButtonItem.title        = NSLocalizedString(@"LGTVC_ButtonTitle_Map",  @"Map");
    
    //[self.navigationItem setLeftBarButtonItem:nil animated:NO];
    //self.navigationItem.hidesBackButton                 = NO;
    
    self.navigationController.navigationBar.alpha       = 1;
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.navigationBar.tintColor   = [LGAppDeclarations colorForNavigationBar];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.navigationItem.titleView                       = nil;

}

- (void)showMapView
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"showMapView()"];

    isMapViewShowing                                    = YES;
    self.mapView.hidden                                 = NO;
    self.tableView.hidden                               = YES;
    self.navigationItem.rightBarButtonItem.title        = NSLocalizedString(@"LGTVC_ButtonTitle_List",  @"List");
    
    //[self.navigationItem setLeftBarButtonItem:nil animated:NO];
    //self.navigationItem.hidesBackButton                 = YES;
    
    self.navigationController.navigationBar.alpha       = [LGAppDeclarations alphaForNavigationBar];
    self.navigationController.navigationBar.translucent = YES;
    //self.navigationController.navigationBar.tintColor   = [UIColor clearColor];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    self.navigationItem.titleView                       = [self.mapView mapTypeSegmentedControl];
    [self.mapView zoomToFitMapAnnotations];
}


- (void)toggleMapViewTableView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"toggleMapViewTableView()"];
    if (self.isCancelled) return;

    if (self.navigationItem.rightBarButtonItem.title == NSLocalizedString(@"LGTVC_ButtonTitle_Map",  @"Map")) {
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            [self showMapView];
        } completion:nil];
    } else {
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            [self showTableView];
        } completion:nil];
    }
    
}

- (LGTableViewCell *)LGTableViewCellForReuseIdentifier:(NSString *)reuseIdentifier
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"LGTableViewCellForReuseIdentifier:()"];
    
    LGTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
		UITableViewCellStyle cellStyle = self.subtitleKey ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue1;
        cell = [[LGTableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
    } else {
        [cell reset];
    }
    
    return cell;
}

#pragma mark - ABPersonViewControllerDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController 
shouldPerformDefaultActionForPerson:(ABRecordRef)person 
                    property:(ABPropertyID)property 
                  identifier:(ABMultiValueIdentifier)identifier
{
    
    NSLog(@"personViewController");
    
    return NO;
}


#pragma mark - LGAppDataFeedDelegate methods
- (void)didGetPeople
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"didGetPeople()"];
    [self.appDelegate saveContext];
    self.progressView.hidden = YES;
    
}

- (void)didGetPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"didDownloadPlacesWithinDistance:fromLocation()"];
    [self.appDelegate saveContext];
    self.progressView.hidden = YES;
}

- (void)didGetCheckinsForPersonId:(NSString *)person_id
{
    self.progressView.hidden = YES;
}


#pragma mark - Utility Methods
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

-(void)housekeepingForVisibleRows
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"housekeepingForVisibleRows"];
    if (self.isCancelled) return;
    
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        if (self.isCancelled) return;
        LGTableViewCell *cell = (LGTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        [cell doHousekeeping];
        
        
    }
}

#pragma mark - MKMapViewDelegate
/*=====================================================================================================================================================
 *
 * MKMapViewDelegate
 *
 *=====================================================================================================================================================*/
- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"mapView:viewForAnnotation()"];
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    LGMapItemAnnotationView *annotationView = (LGMapItemAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) annotationView = [[LGMapItemAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    
    annotationView.annotation = annotation;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.canShowCallout = YES;
    
    return annotationView;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"mapView:calloutAccessoryControlTapped()"];

    self.dataModelObject = (MapItem *)view.annotation;

    if (self.isCancelled) return;
    [self doPushNextView];

}


#pragma mark - UIScrollViewDelegate
/*=====================================================================================================================================================
 *
 * UIScrollViewDelegate
 *
 *=====================================================================================================================================================*/
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"scrollViewDidEndDragging()"];
    if (self.isCancelled) return;
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    if (!decelerate)
	{
        [self housekeepingForVisibleRows];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"scrollViewDidEndDecelerating()"];
    if (self.isCancelled) return;
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self housekeepingForVisibleRows];
    
}

#pragma mark View Lifecycle
- (void)loadView
{
    [super loadView];
    isCancelled = NO;
    _isBusy = NO;
    
    
    UIBarButtonItem *barbutton              = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LGCoreDataTVC_BackButton", @"Back")
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self 
                                                                              action:@selector(doBackButton:)];
    
    self.navigationItem.leftBarButtonItem   = barbutton;
    [barbutton release];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LGTVC_ButtonTitle_Map",  @"Map") 
                                                                               style:UIBarButtonItemStyleBordered 
                                                                              target:self 
                                                                              action:@selector(toggleMapViewTableView)
                                               ] autorelease];


    

    self.buttonRefresh                  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(doRefresh:)];
    self.buttonRefresh.style            = UIBarButtonItemStyleBordered;
    
    self.progressView                   = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 
                                                                                           0, 
                                                                                           self.view.frame.size.width - self.buttonRefresh.width - 10, 
                                                                                           self.navigationController.toolbar.frame.size.height
                                                                                           )
                                           ];
    
    self.progressView.trackTintColor    = [LGAppDeclarations colorForToolbar];
    self.progressView.progressTintColor = [UIColor lightGrayColor];

    self.progressView.progressViewStyle = UIProgressViewStyleBar;
    [self.progressView setHidden:YES];
    [self.progressView setProgress:0];
    
    UIBarButtonItem *progressItem = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
    
    [self setToolbarItems:[NSMutableArray arrayWithObjects:self.buttonRefresh, progressItem, nil]];
    [progressItem release];
    
    
    //Looking Glass Initializations
    //
    //setup initial environment: table view is visible, it's associated toolbar buttons are also visible, and Checkins list is selected
    //tableView initialization...
    if (!tableView && ([self.view isKindOfClass:[UITableView class]])) {
        tableView = [(UITableView *)self.view retain];
    }
    self.view                       = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.tableView.frame            = self.view.bounds;
    
    [self.view addSubview:self.tableView];
    isMapViewShowing = NO;
    
    
    self.tableView.tableHeaderView.backgroundColor = [LGAppDeclarations LGTVC_backgroundColor];
    self.tableView.tableFooterView.backgroundColor = [LGAppDeclarations LGTVC_backgroundColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [LGAppDeclarations LGTVC_backgroundColor];


}
- (void)viewDidLoad
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidLoad()"];
    [super viewDidLoad];
	[self createSearchBar];
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewWillAppear()"];
    if (self.isCancelled) return;

    [self performFetchForTableView:self.tableView];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewWillDisappear()"];
    [super viewWillDisappear:animated];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidAppear()"];
    
    if (!self.isCancelled) {
        [self housekeepingForVisibleRows];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidDisappear()"];
    
    [super viewDidDisappear:animated];
    [self.appDelegate saveContext];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload()"];
    
    fetchedResultsController.delegate = nil;
    fetchedResultsController = nil;
    
    mapView = nil;
    tableView = nil;
    appDelegate = nil;
    context = nil;
    
    integratorFacebook = nil;
    integratorAddressBook = nil;
    integratorLinkedIn = nil;
    
}



- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    //pre-lock dealloc calls
    
    [self resetIntegrators];

    //locked dealloc calls
    [self.appDelegate.managedObjectContext lock];
    
    [buttonRefresh release];
    buttonRefresh = nil;
    
    [progressView release];

    if (tableView) {
        [tableView removeFromSuperview];
        tableView.delegate = nil;
        tableView.dataSource = nil;
        [tableView release];
        tableView = nil;
    }
    
    if (mapView) {
        [mapView removeFromSuperview];
        mapView.delegate = nil;
        [mapView release];
        mapView = nil;
    }
    
    
    //Core Data code-generated
    if (fetchedResultsController) {
        fetchedResultsController.delegate = nil;
        [fetchedResultsController release];
        fetchedResultsController = nil;
    }
    
	[searchKey release];
	[titleKey release];
	[currentSearchText release];
	[normalPredicate release];
    
    if (searchBar) {
        [searchBar release];
        searchBar = nil;
    }
    
    [self.appDelegate.managedObjectContext unlock];
    
    if (appDelegate) {
        [appDelegate release];
        appDelegate = nil;
    }
    if (context) {
        [context release];
        context = nil;
    }

    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"shouldAutorotateToInterfaceOrientation()"];
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [self logObjectVariables:@"didReceiveMemoryWarning()"];
    [self cancelAllRequests];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


//=====================================================================================================================================================================
//
// CORE DATA CODE-GENERATED PROPERTIES AND METHODS
//=====================================================================================================================================================================
#pragma mark Core Data Tableview Controller

- (void)createSearchBar
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"createSearchBar()"];
    if (self.isCancelled) return;

	if (self.searchKey.length) {

		//if (self.tableView && !self.tableView.tableHeaderView) {              //mcdaniel: reconfigured to accomodate a dynamic tableview in the root table view controller
        if (self.tableView) {
            if (self.tableView.tableHeaderView) self.tableView.tableHeaderView = nil;       // mcdaniel: kill existing search bar in case one exists already.
            
			self.searchBar = [[UISearchBar alloc] init];

			[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
			self.searchDisplayController.searchResultsDelegate = self;
			self.searchDisplayController.searchResultsDataSource = self;
			self.searchDisplayController.delegate = self;
			self.searchBar.frame = CGRectMake(0, 0, 0, 38);
			self.tableView.tableHeaderView = self.searchBar;
            [self.searchBar setTintColor:[LGAppDeclarations LGTVC_SearchbarColor]];
		}
        
	} else {
		self.tableView.tableHeaderView = nil;
	}
}

- (NSString *)searchKey
{
    return searchKey;
}
- (void)setSearchKey:(NSString *)aKey
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"setSearchKey()"];
    @synchronized(self) {
        [searchKey release];
        searchKey = [aKey copy];
        [self createSearchBar];
    }
}

- (void)setTitleKey:(NSString *)newTitleKey
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"setTitleKey()"];
    @synchronized(self) {
        if (titleKey) {
            [titleKey release];
        }
        [newTitleKey retain];
        titleKey = newTitleKey;
    }
}
- (NSString *)titleKey
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"titleKey()"];
	if (!titleKey) {
		NSArray *sortDescriptors = [[self.fetchedResultsController.fetchRequest sortDescriptors] autorelease];
		if (sortDescriptors.count) return [[[sortDescriptors objectAtIndex:0] key] copy];
        return nil;
	} else return titleKey;
}

- (void)performFetchForTableView:(UITableView *)thisTableView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"performFetchForTableView()"];
    if (self.isCancelled) return;
    
	NSError *error = nil;
	[self.fetchedResultsController performFetch:&error];
	if (error) {
		NSLog(@"[CoreDataTableViewController performFetchForTableView:] %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
	}
	[thisTableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)thisTableView
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"fetchedResultsControllerForTableView()"];

	if (thisTableView == self.tableView) {
		if (self.fetchedResultsController.fetchRequest.predicate != normalPredicate) {
			[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
			self.fetchedResultsController.fetchRequest.predicate = normalPredicate;
			[self performFetchForTableView:thisTableView];
		}
		[currentSearchText release];
		currentSearchText = nil;
	} else if ((thisTableView == self.searchDisplayController.searchResultsTableView) && self.searchKey && ![currentSearchText isEqual:self.searchDisplayController.searchBar.text]) {
		[currentSearchText release];
		currentSearchText                                       = [self.searchDisplayController.searchBar.text copy];
		NSString *searchPredicateFormat                         = [NSString stringWithFormat:@"%@ contains[c] %@", self.searchKey, @"%@"];
		NSPredicate *searchPredicate                            = [NSPredicate predicateWithFormat:searchPredicateFormat, self.searchDisplayController.searchBar.text];
		[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
		self.fetchedResultsController.fetchRequest.predicate    = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:searchPredicate, normalPredicate , nil]];
		[self performFetchForTableView:thisTableView];
	}
	return self.fetchedResultsController;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"searchDisplayControllerWillEndSearch()"];
	// reset the fetch controller for the main (non-searching) table view
    if (self.isCancelled) return;
    
	[self fetchedResultsControllerForTableView:self.tableView];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    return fetchedResultsController;
}
- (void)setFetchedResultsController:(NSFetchedResultsController *)controller
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"setFetchedResultsController()"];
    
    @synchronized(self) {
        fetchedResultsController.delegate = nil;
        [fetchedResultsController release];
        fetchedResultsController = [controller retain];
        controller.delegate = self;
        normalPredicate = [self.fetchedResultsController.fetchRequest.predicate retain];
        if (!self.title) self.title = controller.fetchRequest.entity.name;
        if (self.view.window  && !self.isCancelled) {
            [self performFetchForTableView:self.tableView];   
        }
    }
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"accessoryTypeForManagedObject()"];
	return UITableViewCellAccessoryDisclosureIndicator;
}

/*
- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"thumbnailImageForManagedObject()"];
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell forManagedObject:(NSManagedObject *)managedObject
{
}
*/

- (LGTableViewCell *)tableView:(UITableView *)thisTableView cellForManagedObject:(NSManagedObject *)managedObject
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:cellForManagedObject()"];

    LGTableViewCell *cell = [self LGTableViewCellForReuseIdentifier:[[self class] description]];
    
    /*
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	UIImage *thumbnail = [self thumbnailImageForManagedObject:managedObject];
	if (thumbnail) cell.imageView.image = thumbnail;
    */
	
    LGDataModelObject *obj = (LGDataModelObject *)managedObject;
    
	if (self.titleKey) cell.lgTextLabel.text          = obj.tableCellTitle;
	if (self.subtitleKey) cell.lgDetailTextLable.text = obj.tableCellSubTitle;
    
    return cell;
    
}


- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
    
     //if ([mapitem isKindOfClass:[MapItem class]])

    self.dataModelObject = (LGDataModelObject *)managedObject;
    
    /*
    if ([managedObject isKindOfClass:[Person class]]) {
        self.person = (Person *)managedObject;
        [self.person doHousekeeping];        
    }
    if ([managedObject isKindOfClass:[Checkin class]]) {
        self.checkin = (Checkin *)managedObject;
        [self.checkin doHousekeeping];
    }
    if ([managedObject isKindOfClass:[MapItem class]]) {
        self.mapItem = (MapItem *)managedObject;
        [self.mapItem doHousekeeping];
    }
    */
    
    [self doPushNextView];
    
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
}


- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return NO;
}

- (BOOL)tableView:(UITableView *)thisTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:canEditRowAtIndexPath()"];
    return NO;
    /*
	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:thisTableView] objectAtIndexPath:indexPath];
	return [self canDeleteManagedObject:managedObject];
     */
}

- (void)tableView:(UITableView *)thisTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:canEditRowAtIndexPath()"];
    if (self.isCancelled) return;

	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:thisTableView] objectAtIndexPath:indexPath];
	[self deleteManagedObject:managedObject];
}


#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)thisTableView
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"numberOfSectionsInTableView()"];
    return [[[self fetchedResultsControllerForTableView:thisTableView] sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)thisTableView
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"sectionIndexTitlesForTableView()"];
	return [[self fetchedResultsControllerForTableView:thisTableView] sectionIndexTitles];
}

#pragma mark UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)thisTableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.searchDisplayController.searchBar isFirstResponder]) return nil;

    UILabel *l          = [[[UILabel alloc] initWithFrame:[self.tableView rectForHeaderInSection:section]] autorelease];
    l.backgroundColor   = [LGAppDeclarations LGTVC_Seperator_backgroundColor];
    l.font              = [UIFont boldSystemFontOfSize:15];
    l.textColor         = [UIColor lightGrayColor];
    l.text              = [self tableView:thisTableView titleForHeaderInSection:section];
    
    return l;

}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [LGAppDeclarations LGTableViewCell_backgroundColor];
}

- (NSInteger)tableView:(UITableView *)thisTableView numberOfRowsInSection:(NSInteger)section
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:numberOfRowsInSection()"];
    return [[[[self fetchedResultsControllerForTableView:thisTableView] sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:cellForRowAtIndexPath()"];
	return [self tableView:thisTableView cellForManagedObject:[[self fetchedResultsControllerForTableView:thisTableView] objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:didSelectRowAtIndexPath()"];
	[self managedObjectSelected:[[self fetchedResultsControllerForTableView:thisTableView] objectAtIndexPath:indexPath]];
}

- (NSString *)tableView:(UITableView *)thisTableView titleForHeaderInSection:(NSInteger)section
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:titleForHeaderInSection()"];
	return [[[[self fetchedResultsControllerForTableView:thisTableView] sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)thisTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:sectionForSectionIndexTitle()"];
	return [[self fetchedResultsControllerForTableView:thisTableView] sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"controllerWillChangeContent()"];
    
    [self.tableView beginUpdates];
    _isBusy = YES;
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{	
    if (OBJECT_DEBUG) [self logObjectVariables:@"controller:didChangeSection:atIndex:forChangeType()"];
    
    if (!self.tableView) return;
    if (!self.fetchedResultsController) return;
    
    [self.appDelegate.managedObjectContext lock];
    _isBusy = YES;
    
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    [self.appDelegate.managedObjectContext unlock];
    _isBusy = NO;
    
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{	
    if (OBJECT_DEBUG) [self logObjectVariables:@"controller:didChangeObject:atIndex:forChangeType:newIndexPath()"];

    if (!self.tableView) return;
    if (!self.fetchedResultsController) return;
    
    [self.appDelegate.managedObjectContext lock];
    _isBusy = YES;
    
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    [self.appDelegate.managedObjectContext unlock];
    _isBusy = NO;
    
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"controllerDidChangeContent()"];
    
    [self.tableView endUpdates];
    _isBusy = NO;
}




@end

