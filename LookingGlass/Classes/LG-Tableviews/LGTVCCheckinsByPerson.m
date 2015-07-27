//
//  LGTVCCheckinsByPerson.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGTVCCheckinsByPerson.h"
#import "LGTableViewCell.h"
#import "LGAppDeclarations.h"
#import "LGDetailViewController_AddressBook.h"
#import "LGDetailViewController_FacebookFriend.h"
#import "LGDetailViewController_FacebookPlace.h"
#import "LGDetailViewController_LinkedIn.h"


@implementation LGTVCCheckinsByPerson


@synthesize person;


-(void) toggleMapViewTableView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"toggleMapViewTableView()"];
    
    if (self.mapView.annotations.count != self.fetchedResultsController.fetchedObjects.count) {
        
        if (self.mapView.annotations.count > 0) [self.mapView removeAllMapAnnotations];
        
        NSArray *checkins = [[self.fetchedResultsController.fetchedObjects copy] retain];
        
        for (Checkin *checkin in checkins) {
            [self.mapView addAnnotation:checkin.checkin_Mapitem];
        }
        
        [checkins release];
        
    }
    
    [super toggleMapViewTableView];
    
}


/*=====================================================================================================================================================
 *
 * MKMapViewDelegate
 *
 *=====================================================================================================================================================*/
/*
 #pragma mark - MKMapViewDelegate
-(void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"mapView:annotationView:calloutAccessoryControlTapped(entering)"];
    
    //setup the next screen: CheckinsByMapItemTableViewController......
    MapItem *thisMapItem = (MapItem *)aView.annotation;
    
    LGTVCCheckinsByMapItem *cbmtvc = [[LGTVCCheckinsByMapItem alloc] initWithMapItem:thisMapItem];
    cbmtvc.title = [thisMapItem.title copy];
    [self.navigationController pushViewController:cbmtvc animated:YES];
    [cbmtvc release];
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"mapView:annotationView:calloutAccessoryControlTapped(exiting)"];
}
*/


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:cellForRowAtIndexPath()"];
    
	LGTableViewCell *cell   = [self tableView:tableView cellForManagedObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
    cell.rowNumber          = [indexPath indexAtPosition:1] + 1;
    cell.checkin            = (Checkin *)[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    return cell; 
}

/*
- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"managedObjectSelected()"];
    [super managedObjectSelected:managedObject];
    
    
}
*/

- (void)doRefresh:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doRefresh:sender()"];
    
    //NSLog(@"ready to get some checkins! - %@", self.person.unique_id);
    //NSLog(@"person: %@", [self.person description]);
    //NSLog(@"person: %@ %@", self.person.name, self.person.unique_id);

    if (self.person.dataFeedType == LGDataFeedTypeFaceBookFriend) {
        [self.integratorFacebook getCheckinsForPersonId:self.person.unique_id withCycleTest:NO];
    }
    
}

- (void)doPushNextView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doPushNextView()"];
    [super doPushNextView];

    if (!self.checkin) return;
    
    
    switch (self.dataModelObject.dataFeedType) {
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
            LGDetailViewController_FacebookFriend *vc = [[LGDetailViewController_FacebookFriend alloc] initWithCheckin:self.checkin];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
        case LGDataFeedTypeFaceBookCheckin:
        {
            LGDetailViewController_FacebookPlace *vc = [[LGDetailViewController_FacebookPlace alloc] initWithMapItem:self.checkin.checkin_Mapitem];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
        case LGDataFeedTypeFaceBookPlace:
        {
            LGDetailViewController_FacebookPlace *vc = [[LGDetailViewController_FacebookPlace alloc] initWithCheckin:self.checkin];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
        case LGDataFeedTypeLinkedIn:
        {
            LGDetailViewController_LinkedIn *vc = [[LGDetailViewController_LinkedIn alloc] initWithCheckin:self.checkin];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
            
        default:
            NSLog(@"orphaned logic");
            break;
    }
    

}
 

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidLoad()"];
    [super viewDidLoad];
    
    self.titleKey = @"tableCellTitle";
    self.subtitleKey = @"tableCellSubTitle";
    self.searchKey = nil;
    

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LGTVC_ButtonTitle_Map",  @"Map") 
                                                                               style:UIBarButtonItemStyleBordered 
                                                                              target:self 
                                                                              action:@selector(toggleMapViewTableView)
                                               ] autorelease];
    
    

    self.fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    
    NSFetchRequest *request     = [[NSFetchRequest alloc] init];
    request.entity              = [NSEntityDescription entityForName:@"Checkin" inManagedObjectContext:self.context];
    request.sortDescriptors     = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"create_date" ascending:NO]];
    request.predicate           = [NSPredicate predicateWithFormat:@"checkin_Person = %@", self.person];
    request.fetchBatchSize      = 100;
    
    [NSFetchedResultsController deleteCacheWithName:@"MyCheckinCache"];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request
                                       managedObjectContext:self.context
                                       sectionNameKeyPath:nil
                                       cacheName:nil];
    
    self.fetchedResultsController = frc;
    [request release];
    [frc release];

}

- (void)viewDidUnload
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload(entering)"];
    
    person = nil;
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload(exiting)"];
    [super viewDidUnload];
}


-(void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    if (person) [person release];
    [super dealloc];
}


- (LGTVCCheckinsByPerson *)initWithPerson:(Person *)thisPerson;
{
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithPerson()"];
        
        self.person = thisPerson;
        
	}
	return self;
}


@end
