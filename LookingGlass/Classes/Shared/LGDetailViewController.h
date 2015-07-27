//
//  LGDetailViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MapItem.h"
#import "Checkin.h"
#import "Person.h"
#import "LGMapView.h"

@interface LGDetailViewController : UIViewController  <NSFetchedResultsControllerDelegate, 
                                                        ABPersonViewControllerDelegate,
                                                        MKMapViewDelegate, 
                                                        UIScrollViewDelegate, 
                                                        LGAppDataFeedDelegate>

@property (nonatomic, retain) MapItem *mapItem;
@property (nonatomic, retain) Checkin *checkin;
@property (nonatomic, retain) Person *person;

@property (nonatomic, readonly) BOOL isDetailViewShowing;
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
@property (nonatomic, retain) UIView *detailView;
@property (nonatomic) BOOL isBusy;
@property (nonatomic) BOOL isCancelled;

//API methods
- (IBAction)doBackButton:(id)sender;
- (IBAction)doRefresh:(id)sender;
- (void)toggleMapViewTableView;

//lifecycle methods
- (void)logObjectVariables:(NSString *)suffix;
- (BOOL)cancelAllRequests;
- (void)showDetailView;
- (void)showMapView;
- (void)toggleMapViewTableView;

//convenience methods
- (NSString *)arrayOfDictionariesToString:(NSArray *)arr KeyValue:(NSString *)key;
- (NSString *)dictWithFlagsToString:(NSDictionary *)dict;
- (NSString *)hoursDictionaryToString:(NSDictionary *)dict;
- (BOOL)isValidDictionary:(NSDictionary *)dict;

@end
