//
//  MapItem.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGDataModelObject.h"
#import <MapKit/MapKit.h>

@class Checkin, Person;

@interface MapItem : LGDataModelObject <MKAnnotation, LGDataModelObject>  
{
    CLLocation *location;
}

@property (nonatomic, readonly) BOOL needsReverseGeoCode;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;    //for MKAnnotation protocol
@property (nonatomic, retain) CLLocation *userLocation;
@property (retain, readonly) CLLocation *location;
@property (nonatomic, readonly) NSInteger distanceFromCurrentLocation;

// dynamic properties
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * distancefromlastlocation;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * title_description;
@property (nonatomic, retain) NSNumber * reversegeocoded;
@property (nonatomic, retain) NSNumber * geocodeaccuracy;
@property (nonatomic, retain) NSDate * timestamp;

@property (nonatomic, retain) NSNumber * checkincount;          //facebook places only

@property (nonatomic, copy) NSString * country;                 //google reverse geo coding     Address Book    //LinkedIn
@property (nonatomic, copy) NSString * state;                   //google reverse geo coding     Address Book 
@property (nonatomic, copy) NSString * city;                    //google reverse geo coding     Address Book    //LinkedIn
@property (nonatomic, copy) NSString * postalcode;              //google reverse geo coding     Address Book
@property (nonatomic, copy) NSString * street;                  //google reverse geo coding     Address Book

@property (nonatomic, retain) NSSet *mapitem_Checkin;

+ (MapItem *)initWithMapItemId:(NSString *)mapItem_id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)removeForMapItemId:(NSString *)mapItem_id inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)updateDistanceFromLastLocation:(CLLocation *)location 
                              ForRange:(NSInteger)range 
                             ForPerson:(BOOL)forPerson 
                InManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)scanMapItemsForCoordinatesForDataFeedType:(LGDataFeedType)dataFeedType
                           InManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)refreshAllMapitemsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSInteger)mapItemRecordsInManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSInteger)recordsForDataFeedType:(LGDataFeedType)dataFeedType
                    InManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSInteger)recordsForDataFeedType:(LGDataFeedType)dataFeedType
                    GeocodeAccuracy:(LGMapItemGeocodeAccuracy)geocodeAccuracy
             InManagedObjectContext:(NSManagedObjectContext *)context;


+ (NSFetchRequest *)requestMapItemsWithin:(NSInteger)meters QueryType:(LGQueryType)queryType InManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSInteger)distanceFromLastLocationForMapItem:(NSString *)unique_id InManagedObjectContext:(NSManagedObjectContext *)context;

- (void)reverseGeocode;
- (void)handleTableCellText;
- (void)updateDistanceFromLastLocation;
- (void)geoCode;
- (void)geoCodeLikeCities;
- (void)geoCodeLikeStates;
- (void)geoCodeLikePostalCodes;

@end

@interface MapItem (CoreDataGeneratedAccessors)

- (void)addMapitem_CheckinObject:(Checkin *)value;
- (void)removeMapitem_CheckinObject:(Checkin *)value;
- (void)addMapitem_Checkin:(NSSet *)values;
- (void)removeMapitem_Checkin:(NSSet *)values;

@end
