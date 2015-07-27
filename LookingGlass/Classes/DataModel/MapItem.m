//
//  MapItem.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapItem.h"
#import "Checkin.h"
#import "Person.h"


@interface MapItem()

@property (nonatomic, retain, readonly) CLGeocoder *geocoder;
@property (nonatomic, readonly) BOOL canReverseGeocode;
@property (readonly) NSInteger checkinCountINT;

- (BOOL)geoCodeFindLikeCity;
- (BOOL)geoCodeFindLikeState;
- (BOOL)geoCodeFindLikePostalCode;
- (void)fireCoordinatesDidChange;

@end

@implementation MapItem

@synthesize userLocation;
@synthesize coordinate;
@synthesize geocoder;
@synthesize checkinCountINT;


@dynamic mapitem_Checkin;

@dynamic datafeedtype_id;
@dynamic latitude;
@dynamic longitude;
@dynamic distancefromlastlocation;
@dynamic title;
@dynamic title_description;
@dynamic reversegeocoded;
@dynamic geocodeaccuracy;
@dynamic timestamp;

@dynamic checkincount;
@dynamic country;
@dynamic state;
@dynamic city;
@dynamic postalcode;
@dynamic street;

#pragma mark - Setters and Getters
- (BOOL)canReverseGeocode
{
    if (self.dataFeedType == LGDataFeedTypeAddressBook) return NO;
    if (self.dataFeedType == LGDataFeedTypeCalendar) return NO;
    if (self.dataFeedType == LGDataFeedTypeOutlook) return NO;
    
    return YES;
}

- (NSString *)tableCellTitle
{
    return self.title;
}

- (LGMapItemGeocodeAccuracy)geocodeAccuracy
{
    if (!self.geocodeaccuracy) return LGMapItemGeocodeAccuracy_None;
    if (self.geocodeaccuracy == nil) return LGMapItemGeocodeAccuracy_None;
    return [self.geocodeaccuracy integerValue];
}

- (BOOL)isBusy
{
    if ([super isBusy]) return YES;
    if (geocoder) {
        return self.geocoder.isGeocoding;
    }
    return NO;
}
- (CLGeocoder *)geocoder
{
    if (!geocoder) {
        geocoder = [[[CLGeocoder alloc] init] retain];
    }
    return geocoder;
}

- (NSInteger)checkinCountINT
{
    return [self.checkincount integerValue];
}

- (BOOL)needsReverseGeoCode
{
    if (!self.canReverseGeocode) return NO;
    if ([self.reversegeocoded intValue] == 1) return NO;
    if (!self.geocodeAccuracy == LGMapItemGeocodeAccuracy_Street) return NO;
    
    return YES;
}



-(CLLocation *)location
{
    if (!location) {
        @synchronized(self) {
            if (!self.latitude) return nil;
            if (!self.longitude) return nil;
            if (OBJECT_DEBUG) [self logObjectVariables:@"location()"];
            location = [[[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]] retain];
        }
        
    }
    return location;
}

-(CLLocationCoordinate2D)coordinate
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"coordinate()"];
    
    CLLocationCoordinate2D locationCoordinate2D;
    if (self.latitude) locationCoordinate2D.latitude = [self.latitude doubleValue];
    else locationCoordinate2D.latitude = 0;
    
    if (self.longitude) locationCoordinate2D.longitude = [self.longitude doubleValue];
    else locationCoordinate2D.longitude = 0;
    
    return locationCoordinate2D;    
}

-(NSInteger)distanceFromCurrentLocation
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"distanceFromCurrentLocation()"];
    if (!self.latitude || !self.longitude) return -1;
    
    if (self.userLocation) {
        return [self.location distanceFromLocation:self.userLocation];
    } else {
        return [self.location distanceFromLocation:[self.appDelegate.locationManager location]];
    }
}



#pragma mark - geo code Methods
- (void)fireCoordinatesDidChange;
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"fireCoordinatesDidChange()"];

    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(coordinatesDidChange:GeocodeAccuracy:)]) {
            [self.delegate coordinatesDidChange:self.location GeocodeAccuracy:self.geocodeAccuracy];
        }
    }
    

}
- (void)geoCodeLikePostalCodes
{
    if (self.geocodeAccuracy < LGMapItemGeocodeAccuracy_PostalCode) return;
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"geoCodeLikeStates()"];
    if (self.isCancelled) return;
    
    [self setBusy:YES];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
    NSError *error          = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    request.predicate       = [NSPredicate predicateWithFormat:@"postalcode != nil AND postalcode = %@ AND state = %@ AND (geocodeaccuracy < %@)", 
                               self.postalcode, 
                               self.state,
                               [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_PostalCode]
                               ];
    
    [self.appDelegate.managedObjectContext lock];
    NSArray *arr            = [[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] copy] retain];
    [self.appDelegate.managedObjectContext unlock];
    
    for (MapItem *mapitem in arr) {
        mapitem.longitude = self.longitude;
        mapitem.latitude  = self.latitude;
        mapitem.geocodeaccuracy  = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_PostalCode];
    }
    [request release];
    [arr release];
    
    [self.appDelegate saveContext];
    [self setBusy:NO];
}


- (void)geoCodeLikeStates
{
    if (self.geocodeAccuracy < LGMapItemGeocodeAccuracy_State) return;
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"geoCodeLikeStates()"];
    if (self.isCancelled) return;
    
    [self setBusy:YES];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
    NSError *error          = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    request.predicate       = [NSPredicate predicateWithFormat:@"state != nil AND state = %@ AND (geocodeaccuracy < %@)", self.state, [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_State]];
    
    [self.appDelegate.managedObjectContext lock];
    NSArray *arr            = [[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] copy] retain]; 
    [self.appDelegate.managedObjectContext unlock];
    
    for (MapItem *mapitem in arr) {
        mapitem.longitude = self.longitude;
        mapitem.latitude  = self.latitude;
        mapitem.geocodeaccuracy  = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_State];
    }
    [request release];
    [arr release];
    
    [self.appDelegate saveContext];
    [self setBusy:NO];
}


- (void)geoCodeLikeCities
{
    if (self.geocodeAccuracy < LGMapItemGeocodeAccuracy_City) return;
    if (OBJECT_DEBUG) [self logObjectVariables:@"geoCodeLikeCities()"];
    if (self.isCancelled) return;
    
    [self setBusy:YES];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
    NSError *error          = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    request.predicate       = [NSPredicate predicateWithFormat:@"city != nil AND city = %@ AND state != nil AND state = %@ AND (geocodeaccuracy < %@)", 
                               self.city, 
                               self.state, 
                               [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_City]
                               ];
    
    [self.appDelegate.managedObjectContext lock];
    NSArray *arr            = [[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] copy] retain]; 
    [self.appDelegate.managedObjectContext unlock];
    
    for (MapItem *mapitem in arr) {
        
        NSLog(@"geocoding like city. ");
        
        mapitem.longitude = self.longitude;
        mapitem.latitude  = self.latitude;
        mapitem.geocodeaccuracy  = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_City];
    }
    [request release];
    [arr release];
    
    [self.appDelegate saveContext];
    [self setBusy:NO];
}



- (BOOL)geoCodeFindLikeCity
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"geoCodeFindLikeCity()"];
    if (self.isCancelled) return NO;
    if (self.geocodeAccuracy >= LGMapItemGeocodeAccuracy_City) return YES;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
    NSError *error          = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    request.predicate       = [NSPredicate predicateWithFormat:@"city != nil AND city = %@ AND state = %@ AND (geocodeaccuracy >= %d)", 
                               self.city, 
                               self.state,
                               LGMapItemGeocodeAccuracy_City
                               ];
    request.fetchLimit      = 1;
    [self.appDelegate.managedObjectContext lock];
    MapItem *mapitem        = [[[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] copy] lastObject] retain]; 
    [self.appDelegate.managedObjectContext unlock];
    [request release];
    
    if (mapitem) {
        self.longitude = mapitem.longitude;
        self.latitude = mapitem.latitude;
        self.geocodeaccuracy  = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_City];
        [self.appDelegate saveContext];
        [mapitem release];
        
        [self fireCoordinatesDidChange];
        return YES;
    }
    return NO;    
}

- (BOOL)geoCodeFindLikeState
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"geoCodeFindLikeState()"];
    if (self.isCancelled) return NO;
    if (self.geocodeAccuracy >= LGMapItemGeocodeAccuracy_State) return YES;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
    NSError *error          = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    request.predicate       = [NSPredicate predicateWithFormat:@"state != nil AND state = %@ AND (geocodeaccuracy >= %d)", 
                               self.state, 
                               LGMapItemGeocodeAccuracy_State
                               ];
    request.fetchLimit      = 1;
    [self.appDelegate.managedObjectContext lock];
    MapItem *mapitem        = [[[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] copy] lastObject] retain]; 
    [self.appDelegate.managedObjectContext unlock];
    [request release];
    
    if (mapitem) {
        self.longitude = mapitem.longitude;
        self.latitude = mapitem.latitude;
        self.geocodeaccuracy  = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_State];
        [self.appDelegate saveContext];
        [mapitem release];
        
        [self fireCoordinatesDidChange];
        return YES;
    }
    return NO;    
}

- (BOOL)geoCodeFindLikePostalCode
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"geoCodeFindLikePostalCode()"];
    if (self.isCancelled) return NO;
    if (self.geocodeAccuracy >= LGMapItemGeocodeAccuracy_PostalCode) return YES;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
    NSError *error          = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:self.appDelegate.managedObjectContext];
    request.predicate       = [NSPredicate predicateWithFormat:@"postalcode != nil AND postalcode = %@ AND state = %@ AND (geocodeaccuracy >= %f)", 
                               self.postalcode, 
                               self.state, 
                               LGMapItemGeocodeAccuracy_PostalCode
                               ];
    request.fetchLimit      = 1;
    
    [self.appDelegate.managedObjectContext lock];
    MapItem *mapitem        = [[[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] copy] lastObject] retain]; 
    [self.appDelegate.managedObjectContext unlock];
    [request release];
    
    if (mapitem) {
        self.longitude = mapitem.longitude;
        self.latitude = mapitem.latitude;
        self.geocodeaccuracy  = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_PostalCode];
        [self.appDelegate saveContext];
        [mapitem release];
        
        [self fireCoordinatesDidChange];
        return YES;
    }
    return NO;    
}

- (void)geoCode
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"geoCode()"];
    if (self.geocodeAccuracy == LGMapItemGeocodeAccuracy_Street) return;
    if (self.dataFeedType == LGDataFeedTypeLinkedIn && self.geocodeAccuracy >= LGMapItemGeocodeAccuracy_City) return;
    if (self.isCancelled) return;
    if (self.geocodeAccuracy == LGMapItemGeocodeAccuracy_BadAddress) return;
    
    
    if (self.dataFeedType == LGDataFeedTypeAddressBook) {
        [self setBusy:YES];
        NSString *addressString = [NSString stringWithFormat:@"%@, %@, %@ %@, %@", self.street, self.city, self.state, self.postalcode, self.country];
        
        [self.geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (self.isCancelled) return;

            [geocoder release];
            geocoder = nil;
            [placemarks retain];
            
            if (error) {
                CLError coreLocationError = (CLError)error;
                if (coreLocationError != kCLErrorGeocodeFoundPartialResult) {
                    if (OBJECT_DEBUG) NSLog(@"setAddressDictionary() - bad address: %@", addressString);
                    if (self.geocodeAccuracy == LGMapItemGeocodeAccuracy_None) self.geocodeaccuracy = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_BadAddress];
                    [self setBusy:NO];
                    
                    [self fireCoordinatesDidChange];
                    [placemarks release];
                    return;
                }
            } 
            
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(location)]) {
                
                CGFloat latitude = [[placemarks objectAtIndex:0] location].coordinate.latitude;
                CGFloat longitude = [[placemarks objectAtIndex:0] location].coordinate.longitude;
                
                if (fabs(latitude) > 0.1 && fabs(longitude) > 0.1) {
                    self.latitude        = [NSNumber numberWithFloat:latitude];             
                    self.longitude       = [NSNumber numberWithFloat:longitude];  
                    self.geocodeaccuracy = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_Street];
                    [self.appDelegate saveContext];
                    
                    
                    [self fireCoordinatesDidChange];
                    
                    //[self geoCodeLikePostalCodes];
                    //[self geoCodeLikeCities];
                    //[self geoCodeLikeStates];
                    
                } else {
                    if (self.geocodeAccuracy == LGMapItemGeocodeAccuracy_None) self.geocodeaccuracy = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_BadAddress];
                    [self fireCoordinatesDidChange];
                    [self cancelAllRequests];
                }
            }

            [placemarks release];
            [self setBusy:NO];
        }];
        
        return;
    }
    if (self.dataFeedType == LGDataFeedTypeLinkedIn || self.dataFeedType == LGDataFeedTypeFaceBookFriend) {
        if (self.geocodeAccuracy >= LGMapItemGeocodeAccuracy_City) return;
        if (!self.city) return;
        
        [self setBusy:YES];
        NSString *address;
        if (self.dataFeedType == LGDataFeedTypeLinkedIn) address = self.city;
        else address = [NSString stringWithFormat:@"%@, %@", self.city, self.state];
        
        [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
            
            [placemarks retain];
            [geocoder release];
            geocoder = nil;

            if (error) {
                CLError coreLocationError = (CLError)error;
                
                if (coreLocationError != kCLErrorGeocodeFoundPartialResult) {
                    if (self.geocodeAccuracy == LGMapItemGeocodeAccuracy_None) self.geocodeaccuracy = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_BadAddress];
                    [self fireCoordinatesDidChange];
                    [self setBusy:NO];
                    [placemarks release];
                    return;
                }
            } 
            
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(location)]) {
                
                CGFloat latitude = [[placemarks objectAtIndex:0] location].coordinate.latitude;
                CGFloat longitude = [[placemarks objectAtIndex:0] location].coordinate.longitude;
                
                if (fabs(latitude) > 0.1 && fabs(longitude) > 0.1) {
                    self.latitude        = [NSNumber numberWithFloat:latitude];             
                    self.longitude       = [NSNumber numberWithFloat:longitude];  
                    self.geocodeaccuracy = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_City];
                    [self.appDelegate saveContext];
                    
                    //[self geoCodeLikeCities];
                    
                } else {
                    if (self.geocodeAccuracy == LGMapItemGeocodeAccuracy_None) self.geocodeaccuracy = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_BadAddress];
                    [self fireCoordinatesDidChange];
                    [self cancelAllRequests];
                }
            }
            
            [placemarks release];
            [self setBusy:NO];
        }];
    }
}


-(void)reverseGeocode
{
    if (self.isCancelled) return;
    if (self.dataFeedType != LGDataFeedTypeFaceBookPlace) return;
    if (!self.canReverseGeocode) return;
    if (!self.needsReverseGeoCode) return;
    
    if (fabs(self.location.coordinate.longitude) < 0.1 && fabs(self.location.coordinate.latitude) < 0.1) return;
    

    if (OBJECT_DEBUG) [self logObjectVariables:@"reverseGeocode()"];
    [self setBusy:YES];

    //step one: reset instance properties to reflect potentially new data.
    if (location) {
        [location release];
        location = nil;
    }

    self.tableCellSubTitle = NSLocalizedString(@"mapItem_Calculating", @"Calculating...");
    [self.geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (self.isCancelled) return;

        [placemarks retain];
        [geocoder release];
        geocoder = nil;
        
        /*
         placemark:
         Contains an array of CLPlacemark objects. For most geocoding requests, this array should contain only one entry. However, forward-geocoding requests may return multiple placemark objects in situations where the specified address could not be resolved to a single location.
         If the request was canceled or there was an error in obtaining the placemark information, this parameter is nil.        
         */
        if (error){
            CLError coreLocationError = (CLError)error;
            if (coreLocationError != kCLErrorGeocodeFoundPartialResult) {
               if (OBJECT_DEBUG) NSLog(@"mapItem.reverseGeocode() - bad results: %@  %@", [[placemarks objectAtIndex:0] description], (CLError)error);
                
                [placemarks release];
                return;
            }
        } else if (OBJECT_DEBUG) NSLog(@"mapItem.reverseGeocode completion handler: %@", [[placemarks objectAtIndex:0] description]);
        
        for (CLPlacemark *placemark in placemarks) {  //there should nearly always be only 1 placemark in the results
            
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(thoroughfare)]) {
                self.street = [[placemarks objectAtIndex:0] thoroughfare];
            }
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(locality)]) {
                self.city = [[placemarks objectAtIndex:0] locality];
            }
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(administrativeArea)]) {
                self.state = [[placemarks objectAtIndex:0] administrativeArea];
            }
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(country)]) {
                self.country = [[placemarks objectAtIndex:0] country];
            }

            break;
        }

        if (self.street || self.city || self.state) {
            self.reversegeocoded = [NSNumber numberWithInt:1];
            self.tableCellSubTitle = nil;
            [self handleTableCellText];
        }
        
        [placemarks release];
        [self setBusy:NO];
    }];
}


#pragma mark - Object Lifecycle
- (void)doHousekeeping
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doHousekeeping()"];
    if (!self.canProcessRequest) return;
    
    [self setBusy:YES];
    
    [super doHousekeeping];
    [self geoCode];
    [self handleTableCellText];
    [self setBusy:NO];
}

- (void)handleTableCellText
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"handleTableCellText()"];
    if (self.isCancelled)  return;
    if (self.tableCellSubTitle) return;
    
    if (self.dataFeedType == LGDataFeedTypeLinkedIn) {
        self.tableCellSubTitle = [self.city capitalizedString];
        return;
    }
    
    if (self.dataFeedType == LGDataFeedTypeAddressBook) {
        if (self.street) {
            self.tableCellSubTitle = [[NSString stringWithFormat:@"%@, %@, %@", [self.street capitalizedString], [self.city capitalizedString], [self.state uppercaseString]] autorelease];
        } else {
            self.tableCellSubTitle = [[NSString stringWithFormat:@"%@, %@", [self.city capitalizedString], [self.state uppercaseString]] autorelease];
        }
        return;
    }
    
    if (self.needsReverseGeoCode) {
        switch (self.dataFeedType)
        {
            case LGDataFeedTypeAddressBook:
            {
                if ([self.title_description length] == 0) break;
                self.tableCellSubTitle = [[NSString stringWithFormat:NSLocalizedString(@"mapItem_SubTitle_Near", @"Near %1$@"), self.title_description] autorelease];
                break;
            }
            case LGDataFeedTypeFaceBookFriend:
                if ([self.city length] == 0) break;
                self.tableCellSubTitle = [[NSString stringWithFormat:NSLocalizedString(@"mapItem_SubTitle_Near", @"Near %1$@"), self.city] autorelease];
                break;
            case LGDataFeedTypeFaceBookCheckin:
                self.tableCellSubTitle = [[NSString stringWithFormat:NSLocalizedString(@"mapItem_SubTitle_CheckinNear", @"%1$@ checkin near %2$@"), [LGAppDataFeed nameForDataFeedType:self.dataFeedType], self.title_description] autorelease];
                break;
            case LGDataFeedTypeFaceBookPlace:
                self.tableCellSubTitle = [self.title_description autorelease];
                break;
            case LGDataFeedTypeFourSquare:
            case LGDataFeedTypeGooglePlaces:
            case LGDataFeedTypeGooglePlus:
            case LGDataFeedTypeGowalla:
            case LGDataFeedTypeGroupon:
            case LGDataFeedTypeJive:
            case LGDataFeedTypeLinkedIn:
            case LGDataFeedTypeLOCKERZ:
            case LGDataFeedTypeSkype:
            case LGDataFeedTypeBeacon:
            default:
                break;
        }
    } else {
        if (self.street && self.city) self.tableCellSubTitle = [[NSString stringWithFormat:@"%@, %@", self.street, self.city] autorelease];
        else if (self.street) self.tableCellSubTitle = self.street;
        if (!self.tableCellSubTitle) {
            if (self.city) self.tableCellSubTitle = [self.city autorelease];
            else if (self.city && self.state) self.tableCellSubTitle = [[NSString stringWithFormat:@"%@, %@", self.city, self.state] autorelease];
            if (!self.tableCellSubTitle) {
                if (self.state) self.tableCellSubTitle = [self.state autorelease];
            }
        }
    }
    if (!self.tableCellSubTitle) self.tableCellSubTitle = [[NSString stringWithFormat:NSLocalizedString(@"mapItem_SubTitle_LocationFrom", @"Location From %1$@"), [LGAppDataFeed nameForDataFeedType:self.dataFeedType]] autorelease];
    [self.appDelegate saveContext];
    if ([self.reversegeocoded integerValue] == 0 && self.canReverseGeocode) [self reverseGeocode];
    
}

- (void)updateDistanceFromLastLocation
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"updateDistanceFromCurrentLocation()"];

    if (location) {
        [location release];
        location = nil;
    }
    if (self.distanceFromCurrentLocation >= 0) self.distancefromlastlocation = [NSNumber numberWithInt:self.distanceFromCurrentLocation];
    
}



-(void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc(¡)"];
    
    [self reset];
    [super dealloc];
}


-(BOOL)cancelAllRequests
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"cancelAllRequests()"];

    if ([super cancelAllRequests]) {
        [self reset];
    }
    return YES;
}

- (void) reset {
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"reset()"];

    if (userLocation) {
        [userLocation release];
        userLocation = nil;
    }
    
    if (location) {
        [location release];
        location = nil;
    }
    
    if (geocoder) {
        if (self.geocoder.isGeocoding) [self.geocoder cancelGeocode];
        [geocoder release];
        geocoder = nil;
    }

    [super reset];
}



#pragma mark - Class Methods
+ (MapItem *)initWithMapItemId:(NSString *)mapItem_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithMapItemId:inManagedObjectContext()"];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
    request.entity = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"unique_id == %@", [mapItem_id copy]];
    request.fetchLimit      = 1;
    
    NSError *error      = nil;
    
    [context lock];
    NSArray *arr        = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    
    MapItem *mapItem    = [arr lastObject];
    [request release];
    [arr release];
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithMapItemId()"];
    return mapItem;
}

+ (void)removeForMapItemId:(NSString *)mapItem_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"removeForMapItemId()"];
    MapItem *obj = [MapItem initWithMapItemId:mapItem_id inManagedObjectContext:context];
    if (obj) {
        [context deleteObject:obj];
    }
}

+ (void)removeAllObjectsForDataFeedType:(LGDataFeedType)dataFeedType 
                           ProgressView:(UIProgressView *)progressView 
               FromManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"removeAllObjectsForDataFeedType:FromManagedObjectContext()"];

    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
	NSError *error = nil;
    
	request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
    request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id == %d", dataFeedType];
    
    [context lock];
    NSArray *arr            = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    
    CGFloat i = arr.count;
    CGFloat results = i;
    
	for (MapItem *mapItem in arr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressView setProgress: i / results animated:YES];
        });
        i --;

        [MapItem removeForMapItemId:mapItem.unique_id inManagedObjectContext:context];
    }
	[request release];
    [arr release];
    [context save:&error];

}

+ (void)updateDistanceFromLastLocation:(CLLocation *)location 
                              ForRange:(NSInteger)range 
                             ForPerson:(BOOL)forPerson 
                InManagedObjectContext:(NSManagedObjectContext *)context
{
    //================================================================================================================================================
    //
    //  location:   usually the user's current location, but this is arbitrary
    //  range:      expressed in meters
    //
    //
    //  1° latitude = 111.12 kilometers
    //
    // Note: mapItem vis a vis localInit() automatically updates the value of distancefromlastlocation when objects are instantiated. therefore, to update
    //       this value we only need to instantiate the object. Also, we're not interested in minor updates to user location, so we'll work only with the 
    //       location object that was passed to us.
    //
    //       We have two objectives:
    //       a) update mapItems which are clearly not within range of the location
    //       b) update mapItems which might be in range of the location
    //
    //       To accomplish both we'll query for a square geographic grid using only map coordinates +/- x/y degrees from location. the mapItem object
    //       refers to libary functions in Core Location to calculate accurate distances from location. therefore, the persistant data store will contain
    //       accurate distance ranges for relevent mapItem objects PROVIDED that the rows returned by the query below represent a super set of the objects
    //       that would be returned in a location query searching for objects within range of location.
    //
    //================================================================================================================================================
    if (OBJECT_DEBUG) [MapItem logObjectVariables:[NSString stringWithFormat:@"updateDistanceFromLastLocation(%f, %f):ForRange(%d):inManagedObjectContext()", location.coordinate.latitude, location.coordinate.longitude, range]];
    
    NSUserDefaults *defaults = nil;
    BOOL canProcess = YES;
    
     //lookup coordinate from the most recent location update. if the user's current location has not yet changed enough then we'll not recalc our mapItems.
    defaults            = [[NSUserDefaults standardUserDefaults] retain];
    float longitude     = [defaults floatForKey:@"MapItemUpdateDistanceLongitude"];
    float latitude      = [defaults floatForKey:@"MapItemUpdateDistanceLatitude"];
    NSInteger lastRange = [defaults integerForKey:@"MapItemUpdateDistanceRange"];
    [defaults release];
    defaults = nil;
     
    if (latitude != 0 && longitude != 0) {
        CLLocation *lastLocationUpdate = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        if ([location distanceFromLocation:lastLocationUpdate] < kLGMAPITEM_DISTANCEUPDATE_MIN_LOCATION_CHANGE && (range == lastRange)) canProcess = NO;
        [lastLocationUpdate release];
        lastLocationUpdate = nil;
    }
    
    
    if (!canProcess) {
        NSLog(@"updateDistanceFromLastLocation not yet within min recalc range of %d meters. exiting", kLGMAPITEM_DISTANCEUPDATE_MIN_LOCATION_CHANGE);
        return;
    }
     
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (forPerson) {
        [Person initializeDistanceFromLastLocationInManagedObjectContext:context];
    }

    //define our square geographic region
    float deltaDegrees = (float)range / (111.12 * 1000);
    
    float latitudeHigh  = location.coordinate.latitude + deltaDegrees;
    float latitudeLow   = location.coordinate.latitude - deltaDegrees;
    float longitudeHigh = location.coordinate.longitude + deltaDegrees;
    float longitudeLow  = location.coordinate.longitude - deltaDegrees;
    
    //to update to the current location we only need to instantiate nearby mapItem objects. localInit() of each objects will automatically
    //update each objects distance from our current location.
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
	NSError *error = nil;

	request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
    request.predicate       = [NSPredicate predicateWithFormat:@"((latitude between {%f, %f}) AND (longitude between {%f, %f})) OR (distancefromlastlocation <= %d AND longitude != nil AND latitude != nil)", latitudeLow, latitudeHigh, longitudeLow, longitudeHigh, range];
    
    [context lock];
    NSArray *arr            = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    
    [arr makeObjectsPerformSelector:@selector(retain)];
    for (MapItem *mapitem in arr) {
        mapitem.userLocation = location;
        [mapitem updateDistanceFromLastLocation];
        if (forPerson && mapitem.dataFeedType != LGDataFeedTypeFaceBookPlace) {

            [Person updateDistanceFromLastLocationTo:mapitem.distanceFromCurrentLocation 
                                           ForPerson:mapitem.unique_id          // NOTE: 1:1 data mapping between mapItem and Personn for non-social network "checkin" mapitem locations.
                              InManagedObjectContext:context];
        }
    }
    [arr makeObjectsPerformSelector:@selector(release)];

	[request release];
    [arr release];
    [context save:&error];
    [context reset];
    
    //store our current location in Plist. we won't allow re-queries until current location has changed by at least LGFB_MIN_DISTANCE_CHANGE_TO_REQUERY
    // Save authorization information
    defaults = [[NSUserDefaults standardUserDefaults] retain];
    [defaults setObject:[NSNumber numberWithFloat: location.coordinate.longitude] forKey:@"MapItemUpdateDistanceLongitude"];
    [defaults setObject:[NSNumber numberWithFloat: location.coordinate.latitude] forKey:@"MapItemUpdateDistanceLatitude"];
    [defaults setObject:[NSNumber numberWithInteger: range] forKey:@"MapItemUpdateDistanceRange"];
    [defaults synchronize];
    [defaults release];
    defaults = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}

+ (void)scanMapItemsForCoordinatesForDataFeedType:(LGDataFeedType)dataFeedType
                           InManagedObjectContext:(NSManagedObjectContext *)context
{
    
    //look at other records to see if we find "nearby" coordinates based on city, state, or zip. this isn't perfect but will at least
    //get us in the ballpark of the correct location, which will allow broad-search queries in lieue of geocoding each record to street-level
    //accuracy.
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
	NSError *error = nil;
    
	request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
    request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id = %d AND geocodeaccuracy <= %d", dataFeedType, LGMapItemGeocodeAccuracy_None];
    
    [context lock];
    NSArray *arr            = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    
    for (MapItem *mapitem in arr) {
        if (![mapitem geoCodeFindLikePostalCode]) {
            if (![mapitem geoCodeFindLikeCity]) {
                if (![mapitem geoCodeFindLikeState]) {
                    [mapitem geoCode];
                }
            }
        }
        NSLog(@"processed: %@", mapitem.unique_id);
    }
    
	[request release];
    [arr release];
    [context save:&error];

}

+ (void)refreshAllMapitemsInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"refreshAllMapitemsInManagedObjectContext()"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSFetchRequest *request = nil;
    NSArray *arr = nil;
    NSError *error = nil;
    LGAppDelegate *appDelegate = (LGAppDelegate *) [[[UIApplication sharedApplication] delegate] retain];

    //verify geocodes for text address/location information.
    request = [[[NSFetchRequest alloc] init] retain];
    error = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
    
    [context lock];
    arr                     = [[[context executeFetchRequest:request error:&error] copy] retain]; 
    [context unlock];
    
    NSLog(@"mapItems: %d", arr.count);
    NSInteger i = 0;
    NSInteger j = 0;
    NSInteger k = 0;
    NSInteger l = 0;
    NSInteger m = 0;
    NSInteger n = 0;
    NSInteger o = 0;
    
    for (MapItem *mapitem in arr) {
        
        if (mapitem.geocodeAccuracy == LGMapItemGeocodeAccuracy_None) i++;
        if (mapitem.geocodeAccuracy == LGMapItemGeocodeAccuracy_Country) j++;
        if (mapitem.geocodeAccuracy == LGMapItemGeocodeAccuracy_State) k++;
        if (mapitem.geocodeAccuracy == LGMapItemGeocodeAccuracy_City) l++;
        if (mapitem.geocodeAccuracy == LGMapItemGeocodeAccuracy_PostalCode) m++;
        if (mapitem.geocodeAccuracy == LGMapItemGeocodeAccuracy_Municipality) n++;
        if (mapitem.geocodeAccuracy == LGMapItemGeocodeAccuracy_Street) o++;
    }
    [request release];
    [arr release];
    [appDelegate release];
    NSLog(@"none: %d country: %d State: %d City: %d Postal Code: %d Municipality: %d Street: %d", i, j, k, l, m, n, o);

    
    
    //verify geocodes for text address/location information.
    request = [[[NSFetchRequest alloc] init] retain];
    error = nil;
    request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
    
    request.predicate       = [NSPredicate predicateWithFormat:@"((datafeedtype_id == %@ AND geocodeaccuracy < %@) OR (datafeedtype_id == %@ AND geocodeaccuracy < %@) OR (datafeedtype_id == %@ AND geocodeaccuracy < %@))",
                               [NSNumber numberWithInt:LGDataFeedTypeAddressBook], 
                               [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_Street], 
                               [NSNumber numberWithInt:LGDataFeedTypeLinkedIn], 
                               [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_City],
                               [NSNumber numberWithInt:LGDataFeedTypeFaceBookFriend], 
                               [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_City]
                               ];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"geocodeaccuracy" ascending:NO]];
    request.fetchLimit      = 100;
    
    [context lock];
    arr                     = [[[context executeFetchRequest:request error:&error] copy] retain]; 
    [context unlock];
    
    NSLog(@"refreshAllMapitemsInManagedObjectContext: %d", arr.count);

    [arr makeObjectsPerformSelector:@selector(retain)];
    [arr makeObjectsPerformSelector:@selector(doHousekeeping)];
    [arr makeObjectsPerformSelector:@selector(release)];

    [request release];
    [arr release];
    [appDelegate release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (NSInteger)mapItemRecordsInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"mapItemRecordsInManagedObjectContext()"];
    
    NSInteger i = 0;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MapItem"];
	NSError *error = nil;
    
    [context lock];
    i = [context countForFetchRequest:request error:&error];
    [context unlock];
    
	[request release];
    
    return i;
}

+ (NSInteger)recordsForDataFeedType:(LGDataFeedType)dataFeedType
                    InManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"mapItemRecordsInManagedObjectContext()"];
    
    NSInteger i = 0;
	NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MapItem"];
    request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id = %d", dataFeedType];

    [context lock];
    i = [context countForFetchRequest:request error:&error];
    [context unlock];
    
	[request release];
    
    return i;
}

+ (NSInteger)recordsForDataFeedType:(LGDataFeedType)dataFeedType
                    GeocodeAccuracy:(LGMapItemGeocodeAccuracy)geocodeAccuracy
             InManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"mapItemRecordsInManagedObjectContext()"];
    
    NSInteger i = 0;
	NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MapItem"];
    switch (geocodeAccuracy) {
        case LGMapItemGeocodeAccuracy_Street: {
            request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id = %d AND geocodeaccuracy = %d", dataFeedType, LGMapItemGeocodeAccuracy_Street];
            break;
        }
            
        case LGMapItemGeocodeAccuracy_BadAddress: {
            request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id = %d AND geocodeaccuracy = %d", dataFeedType, LGMapItemGeocodeAccuracy_BadAddress];
            break;
        }

        case LGMapItemGeocodeAccuracy_None: {
            request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id = %d AND geocodeaccuracy = %d", dataFeedType, LGMapItemGeocodeAccuracy_None];
            break;
        }
            
        default: {
            request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id = %d AND geocodeaccuracy > 0 AND geocodeaccuracy < %d", dataFeedType, LGMapItemGeocodeAccuracy_Street];
            break;
        }
    }
    
    [context lock];
    i = [context countForFetchRequest:request error:&error];
    [context unlock];
    
	[request release];
    
    return i;
}




+ (NSFetchRequest *)requestMapItemsWithin:(NSInteger)meters QueryType:(LGQueryType)queryType InManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"requestMapItemsWithin:QueryType:InManagedObjectContext()"];

    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    request.entity = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
    request.returnsDistinctResults = YES;
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"checkincount" ascending:NO]]; // @"distancefromlastlocation"
    
    request.fetchBatchSize = kLGNEARBYPLACES_MAXRECORDS;
    request.fetchLimit = kLGNEARBYPLACES_MAXRECORDS;
    
    switch (queryType) {
        case LGQueryTypePlace:
            request.predicate       = [NSPredicate predicateWithFormat:@"!(datafeedtype_id IN {%d, %d, %d, %d, %d}) AND (distancefromlastlocation <= %d)",
                                       LGDataFeedTypeAddressBook, 
                                       LGDataFeedTypeCalendar, 
                                       LGDataFeedTypeFaceBookFriend,
                                       LGDataFeedTypeOutlook,  
                                       LGDataFeedTypeLinkedIn,
                                       meters];
            break;
            
        case LGQueryTypePeople:
            request.predicate       = [NSPredicate predicateWithFormat:@"(datafeedtype_id IN {%d, %d, %d, %d, %d}) AND (distancefromlastlocation <= %d)",
                                       LGDataFeedTypeAddressBook, 
                                       LGDataFeedTypeCalendar, 
                                       LGDataFeedTypeFaceBookFriend,
                                       LGDataFeedTypeOutlook,  
                                       LGDataFeedTypeLinkedIn,
                                       meters];
            break;
            
        case LGQueryTypePeopleAndPlaces:
            request.predicate       = [NSPredicate predicateWithFormat:@"(distancefromlastlocation <= %d)", meters];
            break;
            
    }

    return request;
}

+ (NSInteger)distanceFromLastLocationForMapItem:(NSString *)unique_id InManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"distanceFromLastLocationForMapItem:InManagedObjectContext()"];
    
    NSInteger i = 0;
	NSError *error  = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
	request.predicate       = [NSPredicate predicateWithFormat:@"unique_id = %@", unique_id];
    request.fetchLimit      = 1;
    
    
    [context lock];
	MapItem *mapitem  = [[[context executeFetchRequest:request error:&error] copy] lastObject];
    [context unlock];
	[request release];
    
    i = [mapitem.distancefromlastlocation integerValue];
    [mapitem release];

    return i;
}

@end
