//
//  CoreDataTVC.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LGAppDelegate.h"
#import "LGMapView.h"
#import "LGTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>


#import "LGAppIntegratorFacebook.h"
#import "LGAppIntegratorAddressBook.h"
#import "LGAppIntegratorLinkedIn.h"


@interface LGCoreDataTVC : UITableViewController 
                                               <NSFetchedResultsControllerDelegate, 
                                                UISearchDisplayDelegate, 
                                                ABPersonViewControllerDelegate,
                                                MKMapViewDelegate, 
                                                UIScrollViewDelegate, 
                                                LGAppDataFeedDelegate,
                                                CLLocationManagerDelegate>
{
	NSPredicate *normalPredicate;
	NSString *currentSearchText;
	NSString *titleKey;
	NSString *subtitleKey;
	NSString *searchKey;
	NSFetchedResultsController *fetchedResultsController;
    
}

//Looking Glass Properties
@property (nonatomic, retain) LGDataModelObject *dataModelObject;

@property (nonatomic, readonly) NSInteger ABRecordRefID;
@property (nonatomic, retain, readonly) Person *person;
@property (nonatomic, retain, readonly) Checkin *checkin;
@property (nonatomic, retain, readonly) MapItem *mapItem;


@property (nonatomic, readonly) BOOL isTableViewShowing;
@property (nonatomic, readonly) BOOL isMapViewShowing;


@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonRefresh;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

// Data Integrators
@property (nonatomic, retain, readonly) LGAppIntegratorFacebook *integratorFacebook;
@property (nonatomic, retain, readonly) LGAppIntegratorAddressBook *integratorAddressBook;
@property (nonatomic, retain, readonly) LGAppIntegratorLinkedIn *integratorLinkedIn;

@property (nonatomic, retain, readonly) LGAppDelegate *appDelegate;
@property (nonatomic, retain, readonly) NSManagedObjectContext *context;
@property (nonatomic, retain, readonly) LGMapView *mapView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, readonly) BOOL isDeviceMultitaskingSupported;
@property (nonatomic) BOOL isBusy;
@property (nonatomic) BOOL isCancelled;



@property (nonatomic, retain) UISearchBar *searchBar;

// the controller (this class does nothing if this is not set)
@property (retain) NSFetchedResultsController *fetchedResultsController;

// key to use when displaying items in the table; defaults to the first sortDescriptor's key
@property (copy) NSString *titleKey;
// key to use when displaying items in the table for the subtitle; defaults to nil
@property (copy) NSString *subtitleKey;
// key to use when searching the table (should usually be the same as displayKey); if nil, no searching allowed
@property (copy) NSString *searchKey;


//Looking Glass Method API
- (void)showTableView;
- (void)showMapView;

- (void)logObjectVariables:(NSString *)suffix;
- (void)housekeepingForVisibleRows;
- (BOOL)cancelAllRequests;
- (void)resetIntegrators;
- (IBAction)doRefresh:(id)sender;
- (IBAction)doBackButton:(id)sender;
- (void)doPushNextView;


- (LGTableViewCell *)LGTableViewCellForReuseIdentifier:(NSString *)reuseIdentifier;
- (void)toggleMapViewTableView;



//=====================================================================================================================================================================
//
// CORE DATA CODE-GENERATED PROPERTIES AND METHODS
//=====================================================================================================================================================================
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)thisTableView;

// gets accessory type (e.g. disclosure indicator) for the given managedObject (default DisclosureIndicator)
//- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject;

// returns an image (small size) to display in the cell (default is nil)
//- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject;

// this is the CoreDataTableViewController's version of tableView:cellForRowAtIndexPath:
- (LGTableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject;

// called when a cell representing the specified managedObject is selected (does nothing by default)
- (void)managedObjectSelected:(NSManagedObject *)managedObject;

// called to see if the specified managed object is allowed to be deleted (default is NO)
- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject;

// called when the user commits a delete by hitting a Delete button in the user-interface (default is to do nothing)
// this method does not necessarily have to delete the object from the database
// (e.g. it might just change the object so that it does not match the fetched results controller's predicate anymore)
- (void)deleteManagedObject:(NSManagedObject *)managedObject;

@end
