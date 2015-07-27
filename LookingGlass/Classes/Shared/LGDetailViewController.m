//
//  LGDetailViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGDetailViewController.h"

@interface LGDetailViewController()
{
    BOOL _isBusy;
    
}

- (void)logObjectVariables:(NSString *)suffix;
- (void)resetIntegrators;

@end


@implementation LGDetailViewController

@synthesize mapItem;
@synthesize checkin;
@synthesize person;

@synthesize isMapViewShowing;
@synthesize isCancelled;

@synthesize buttonRefresh;
@synthesize progressView;

@synthesize detailView;
@synthesize mapView;
@synthesize appDelegate;
@synthesize context;

@synthesize integratorFacebook;
@synthesize integratorAddressBook;
@synthesize integratorLinkedIn;

#pragma mark - Setters and Getters
- (BOOL)isDetailViewShowing
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
        
        //mapFrame.origin = self.view.bounds.origin;
        mapFrame.origin = self.detailView.bounds.origin;
        
        mapFrame.size   = CGSizeMake(self.view.bounds.size.width, 
                                     self.view.bounds.size.height + self.navigationController.navigationBar.bounds.size.height + self.navigationController.toolbar.bounds.size.height);
        mapView.frame   = mapFrame;
        mapView.delegate = self;
        mapView.hidden = YES;
        [self.view addSubview:mapView];
        
        if (self.mapItem) [self.mapView addAnnotation:self.mapItem];
        else if (self.checkin) [self.mapView addAnnotation:self.checkin.checkin_Mapitem];
        else if (self.person) {
            Checkin *ci = [self.person.person_Checkin anyObject];
            [self.mapView addAnnotation:ci.checkin_Mapitem];
            [ci release];
        }
        
    }
    return mapView;
}

- (NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"context()"];
    
    if (!context) context = [self.appDelegate.managedObjectContext retain];
    return context;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

- (BOOL)cancelAllRequests
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"cancelAllRequests"];
    isCancelled = YES;
    
    [self resetIntegrators];
    
    return YES;
}

- (void)resetIntegrators
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"resetIntegrators()"];
    
    if (integratorFacebook) {
        [integratorFacebook cancelRequest];
        //integratorFacebook.delegate = nil;
        [integratorFacebook release];
        integratorFacebook = nil;
    }
    if (integratorAddressBook) {
        [integratorAddressBook cancelRequest];
        //integratorAddressBook.delegate = nil;
        [integratorAddressBook release];
        integratorAddressBook = nil;
    }
    if (integratorLinkedIn) {
        [integratorLinkedIn cancelRequest];
        //integratorLinkedIn.delegate = nil;
        [integratorLinkedIn release];
        integratorLinkedIn = nil;
    }
    
}

#pragma mark - ABPersonViewControllerDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController 
shouldPerformDefaultActionForPerson:(ABRecordRef)person 
                    property:(ABPropertyID)property 
                  identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}


#pragma mark - API Methods
- (IBAction)doBackButton:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBackButton:"];
    [self cancelAllRequests];
    
    if (self.isMapViewShowing) [self showDetailView];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doRefresh:(id)sender
{
    NSLog(@"doRefresh -- Parent object.");
}

- (void)showDetailView
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"showTableView()"];
    
    isMapViewShowing                                    = NO;
    self.mapView.hidden                                 = YES;
    self.detailView.hidden                               = NO;
    self.navigationItem.rightBarButtonItem.title        = NSLocalizedString(@"LGDetailViewController_Map",  @"Map");
    
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
    self.detailView.hidden                              = YES;
    self.navigationItem.rightBarButtonItem.title        = NSLocalizedString(@"LGDetailViewController_Info",  @"Info");
    
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
    
    if (self.navigationItem.rightBarButtonItem.title == NSLocalizedString(@"LGDetailViewController_Map",  @"Map")) {
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            [self showMapView];
        } completion:nil];
    } else {
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            [self showDetailView];
        } completion:nil];
    }
    
}

- (NSString *)hoursDictionaryToString:(NSDictionary *)dict
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"hoursDictionaryToString()"];
    
    NSMutableArray *hoursArray = [[NSMutableArray alloc] init];
    
    NSArray *keysArray = [dict allKeys];
    NSString *key = nil;
    
    for (NSInteger i = 0; i < keysArray.count; i++) {
        
        key = [keysArray objectAtIndex:i];
        
        CGFloat seconds = [[dict objectForKey:key] integerValue];
        if (seconds > 0) {
            [hoursArray addObject:[NSNumber numberWithInt:seconds]];
        }
    }
    
    //put the time elements into ascending orders
    [hoursArray sortUsingSelector:@selector(compare:)];
    
    NSString *s = nil;
    NSInteger currWeekday = 0;
    
    for (NSInteger i = 0; i < hoursArray.count; i++) {
        
        CGFloat seconds = [[hoursArray objectAtIndex:i] integerValue];
        
        NSString *minute = nil;
        NSString *hour = nil;
        NSString *WeekdayString = nil;
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setMinute:(NSInteger)seconds/60.0f];
        [comps setDay:1];
        [comps setMonth:1];
        [comps setYear:1970];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDate *date = [gregorian dateFromComponents:comps];
        [comps release];
        
        NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
        NSInteger weekdayInt = [weekdayComponents weekday];
        
        NSDateComponents *hourComponents = [gregorian components:NSHourCalendarUnit fromDate:date];
        hour = [[NSNumber numberWithInt:[hourComponents hour]] stringValue];
        
        NSDateComponents *minuteComponents = [gregorian components:NSMinuteCalendarUnit fromDate:date];
        
        
        minute = [[NSNumber numberWithInt:[minuteComponents minute]] stringValue];
        if ([minuteComponents minute] < 10) minute = [NSString stringWithFormat:@"0%@", minute];
        
        switch (weekdayInt) {
            case 1:
                WeekdayString = @"Sunday";
                break;
                
            case 2:
                WeekdayString = @"Monday";
                break;
                
            case 3:
                WeekdayString = @"Tuesday";
                break;
                
            case 4:
                WeekdayString = @"Wedneday";
                break;
                
            case 5:
                WeekdayString = @"Thursday";
                break;
                
            case 6:
                WeekdayString = @"Friday";
                break;
                
            case 7:
                WeekdayString = @"Saturday";
                break;
                
        }
        
        if (weekdayInt == currWeekday) {
            if (s.length > 0) s = [s stringByAppendingString:@" - "];
            
        } else {
            currWeekday = weekdayInt;
            if (s.length > 0) s = [s stringByAppendingString:@"\n"];
            else s = @"";
            
            s = [s stringByAppendingFormat:@"%@: ", WeekdayString];
        }
        
        NSString *schedule = [NSString stringWithFormat:@"%@:%@", hour, minute];
        
        if (s.length == 0) s = schedule;
        else s = [s stringByAppendingString:schedule];
        
        [gregorian release];
        
    }
    
    return s;
}
- (NSString *)dictWithFlagsToString:(NSDictionary *)dict
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dictWithFlagsToString()"];
    
    NSArray *arr = [dict allKeys];
    NSString *key = nil;
    NSString *s = nil;
    
    for (NSInteger i = 0; i < arr.count; i++) {
        
        key = [arr objectAtIndex:i];
        
        if ([[dict objectForKey:key] integerValue] == 1) {
            if (s.length == 0) s = [[arr objectAtIndex:i] capitalizedString];
            else s = [NSString stringWithFormat:@"%@, %@", s, [[arr objectAtIndex:i] capitalizedString]];
        }
        
    }
    return s;
}
- (NSString *)arrayOfDictionariesToString:(NSArray *)arr KeyValue:(NSString *)key
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"arrayOfDictionariesToString()"];
    
    NSDictionary *dict = nil;
    NSString *s = nil;
    
    for (NSInteger i = 0; i < arr.count; i++) {
        dict = [arr objectAtIndex:i];
        
        if ([[dict objectForKey:key] isKindOfClass:[NSString class]]) {
            if (s.length == 0) s = [[dict objectForKey:key] capitalizedString];
            else s = [NSString stringWithFormat:@"%@, %@", s, [[dict objectForKey:key] capitalizedString]];
        }
    }
    return s;
}

- (BOOL)isValidDictionary:(NSDictionary *)dict
{
    if (dict == nil) return NO;
    if (![dict isKindOfClass:[NSDictionary class]]) return NO;
    if (dict.count < 1) return NO;
    if (![dict respondsToSelector:@selector(objectForKey:)]) return NO;
    
    return YES;
    
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    isCancelled = NO;
    _isBusy = NO;
    
    
    UIBarButtonItem *barbutton              = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LGDetailViewController_BackButton", @"Back")
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self 
                                                                              action:@selector(doBackButton:)];
    
    self.navigationItem.leftBarButtonItem   = barbutton;
    [barbutton release];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LGDetailViewController_Map",  @"Map") 
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
    
    
    self.detailView         = self.view;
    
    self.view               = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.detailView.frame   = self.view.bounds;
    [self.view addSubview:self.detailView];
    
    isMapViewShowing = NO;
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewDidDisappear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    mapItem = nil;
    checkin = nil;
    person = nil;
    buttonRefresh = nil;
    progressView = nil;
    detailView = nil;
    mapView = nil;
    appDelegate = nil;
    context = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc
{
    [self resetIntegrators];
    
    if (mapItem) {
        [mapItem cancelAllRequests];
        [mapItem release];
        mapItem = nil;
    }
    if (checkin) {
        [checkin cancelAllRequests];
        [checkin release];
        checkin = nil;
    }
    if (person) {
        [person cancelAllRequests];
        [person release];
        person = nil;
    }
        
    [buttonRefresh release];
    [progressView release];
    
    if (detailView) {
        [detailView removeFromSuperview];
        [detailView release];
        detailView = nil;
    }

    if (mapView) {
        [mapView removeFromSuperview];
        mapView.delegate = nil;
        [mapView release];
        mapView = nil;
    }

    [appDelegate release];
    [context release];
    
    [super dealloc];
}
@end
