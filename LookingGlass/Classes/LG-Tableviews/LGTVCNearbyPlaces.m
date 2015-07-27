//
//  LGTVCNearbyPlaces.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGTVCNearbyPlaces.h"
#import "LGDetailViewController_AddressBook.h"
#import "LGDetailViewController_FacebookFriend.h"
#import "LGDetailViewController_FacebookPlace.h"
#import "LGDetailViewController_LinkedIn.h"


@interface LGTVCNearbyPlaces()
{
    NSInteger distanceForQuery;
}


@end

@implementation LGTVCNearbyPlaces

@synthesize queryType;
@synthesize location;


#pragma mark - Setters and Getters
- (CLLocation *)location
{
    if (!location) {
        if (!location) location = [[self.appDelegate.locationManager location] retain];
        NSLog(@"using default location (user location): lat %f, lon %f", location.coordinate.latitude, location.coordinate.longitude);
    }
    return location;
}

- (void)setQueryType:(LGQueryType)newQueryType
{
    queryType = newQueryType;
    
    switch (queryType) {
        case LGQueryTypePlace: 
        {
            self.title = NSLocalizedString(@"LGTVCNearbyPlaces_TitlePlaces", @"Places");
            break;
        }
        case LGQueryTypePeople: 
        {
            self.title = NSLocalizedString(@"LGTVCNearbyPlaces_TitlePeople", @"People");
            break;
        }
        case LGQueryTypePeopleAndPlaces: 
        {
            self.title = NSLocalizedString(@"LGTVCNearbyPlaces_TitleEither", @"");
            break;
        }
    }
    
}


#pragma mark - MKMapViewDelegate
/*=====================================================================================================================================================
 *
 * MKMapViewDelegate
 *
 *=====================================================================================================================================================*/
/*
-(void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"mapView:annotationView:calloutAccessoryControlTapped()"];
    
    MapItem *mapItem = (MapItem *)aView.annotation;
    [self doPushNextView:mapItem];
}
*/


#pragma mark - Managed Object
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:cellForRowAtIndexPath()"];

	LGTableViewCell *cell   = [self tableView:tableView cellForManagedObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
    cell.rowNumber          = [indexPath indexAtPosition:1] + 1;
    cell.mapItem            = (MapItem *)[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    [cell.mapItem handleTableCellText];
    
    return cell; 
}

/*
- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    
}
*/

-(void)toggleMapViewTableView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"toggleMapViewTableView()"];
    
    if (self.mapView.hidden) {
        [self.appDelegate.managedObjectContext lock];
        if (self.mapView.annotations.count == 0) {
            
            NSArray <MKAnnotation> *arr = [[self.fetchedResultsController.fetchedObjects copy] retain];
            [self.mapView addMapAnnotationsWithArrayContents:arr];
            [arr release];
            
            NSInteger i = 0;
            for (MapItem *mapitem in self.mapView.annotations) {
                if ([mapitem isKindOfClass:[MapItem class]]) mapitem.rowNumber = i++;
            }
            
        }
        [self.appDelegate.managedObjectContext unlock];
    }
    
    
    [super toggleMapViewTableView];
    
}


#pragma mark - View lifecycle

- (void)doPushNextView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doPushNextView()"];

    if (!self.mapItem) return;
    [super doPushNextView];
    
    switch (self.mapItem.dataFeedType) {
        case LGDataFeedTypeAddressBook:
        {
            ABAddressBookRef addressBook = ABAddressBookCreate();
            ABPersonViewController *picker = [[ABPersonViewController alloc] init];
            picker.displayedPerson = ABAddressBookGetPersonWithRecordID(addressBook, self.ABRecordRefID);
            picker.personViewDelegate = self;
            picker.allowsEditing = YES;
            
            [self.navigationController pushViewController:picker animated:YES];
            [picker release];
            
            CFRelease(addressBook);
            
            break;
        }
            
        case LGDataFeedTypeFaceBookFriend:
        {
            LGDetailViewController_FacebookFriend *vc = [[LGDetailViewController_FacebookFriend alloc] initWithMapItem:self.mapItem];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
        case LGDataFeedTypeFaceBookCheckin:
        {
            NSLog(@"not sure what to do here!");
            break;
        }
        case LGDataFeedTypeFaceBookPlace:
        {
            LGDetailViewController_FacebookPlace *vc = [[LGDetailViewController_FacebookPlace alloc] initWithMapItem:self.mapItem];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
        case LGDataFeedTypeLinkedIn:
        {
            LGDetailViewController_LinkedIn *vc = [[LGDetailViewController_LinkedIn alloc] initWithMapItem:self.mapItem];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
            
        default:
            NSLog(@"orphaned logic");
            break;
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidLoad()"];

    self.isBusy = YES;
    
    self.titleKey                   = @"title";
    self.subtitleKey                = @"tableCellSubTitle";
    self.searchKey                  = @"title";
    
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
    self.fetchedResultsController   = nil;
    
    if (distanceForQuery == 0) distanceForQuery = kLGNEARBYPLACES_QUERY_RANGE;
    
    
    [MapItem updateDistanceFromLastLocation:self.location 
                                   ForRange:distanceForQuery 
                                  ForPerson:NO 
                     InManagedObjectContext:self.appDelegate.managedObjectContext];
    
    
    //NSLog(@"distance: %d. Latitude: %f. Longitude: %f / queryType: %d", distanceForQuery, self.location.coordinate.latitude, self.location.coordinate.longitude, self.queryType);
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:[MapItem requestMapItemsWithin:distanceForQuery QueryType:self.queryType InManagedObjectContext:self.appDelegate.managedObjectContext]
                                     managedObjectContext:self.context
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
    
    
    self.isBusy = NO;

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    location = nil;    
}

- (id)initWithLocation:(CLLocation *)myLocation DistanceFromLocation:(NSInteger)distance QueryType:(LGQueryType)thisQueryType
{
    if (self = [self init]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithLocation()"];
        
        self.location = myLocation;
        distanceForQuery = distance;
        self.queryType = thisQueryType;
        
        NSLog(@"location: %f, %f / distanceForQuery = %d, querytype = %d", self.location.coordinate.latitude, self.location.coordinate.longitude, distanceForQuery, self.queryType);

    }
    return self;
}

- (id)init
{
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
        if (OBJECT_DEBUG) [self logObjectVariables:@"init()"];

	}
	return self;
}

- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];

    [location release];
    [super dealloc];
}


- (IBAction)doRefresh:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doRefresh:sender()"];
    
    BOOL cycleTest= NO;
    
    //self.fetchedResultsController.delegate = nil;   // to prevent real-time row-level updates as queries run.
    
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFaceBookFriend]) {
        [self.integratorFacebook getPlacesWithinDistance:kLGNEARBYPLACES_QUERY_RANGE fromLocation:self.location withCycleTest:cycleTest];
    }
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeAddressBook]) {
        [self.integratorAddressBook getPlacesWithinDistance:kLGNEARBYPLACES_QUERY_RANGE fromLocation:self.location withCycleTest:cycleTest];
    }
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeLinkedIn]) {
        [self.integratorLinkedIn getPlacesWithinDistance:kLGNEARBYPLACES_QUERY_RANGE fromLocation:self.location withCycleTest:cycleTest];
    }
    
}

- (void)didGetPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location
{
    NSLog(@"didGetPlacesWithinDistance - done.");

}


@end