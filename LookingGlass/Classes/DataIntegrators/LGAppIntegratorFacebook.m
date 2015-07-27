//
//  LGAppIntegratorFacebook.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.

#import "LGAppIntegratorFacebook.h"
#import "LGAppDeclarations.h"
#import "Attendee.h"
#import "MapItem.h"
#import "Checkin.h"
#import "Person.h"

#define kIMPORT_BATCH_LIMIT 100

typedef enum _LGFBQueryType {
    LGFBQueryTypeFriendsList  = 1,
    LGFBQueryTypeCheckins     ,
    LGFBQueryTypeLikes        ,
    LGFBQueryTypePlaces       ,
    LGFBQueryTypeAppLogin
} LGFBQueryType;



// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitue [app_id] for your real Facebook app id).
//FACEBOOK ID CODE VALUES. additional info about these two values: https://developers.facebook.com/apps/237187503009894
static NSString* kFBAppId = @"237187503009894";
static NSString* kFBSecretId = @"c87e75636d244e7e6687e92c0592e4c0";
static NSString* kFBAppAccessToken = @"237187503009894|VnHS8P8pu45Z1MBJ6UMYh6-brBE";        //mcdaniel: added this 22-Dec-2011, but ended up not using it.


@interface LGAppIntegratorFacebook()

@property (nonatomic, readonly) LGFBQueryType currentQueryType;
@property (nonatomic, retain) NSArray *facebookPermissions;
@property (retain) NSDictionary *resultDictionary;
@property (retain) NSArray *resultArray;

- (void)processRequest;
//- (NSOperation *)processRequestOperation;

@end

@implementation LGAppIntegratorFacebook

@synthesize facebookPermissions;
@synthesize facebook;
@synthesize resultDictionary;
@synthesize resultArray;
@synthesize currentQueryType    = _currentQueryType;

#pragma mark - Setters and Getters
- (NSArray *)facebookPermissions
{
    if (!facebookPermissions) {
        facebookPermissions = [[[NSArray alloc] initWithObjects:@"user_checkins", @"friends_checkins", @"user_about_me", @"user_location", @"friends_location", nil] retain];
    }
    return facebookPermissions;
}

- (Facebook *)facebook
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"facebook()"];

    if (!facebook) facebook = [[[Facebook alloc] initWithAppId:kFBAppId andDelegate:self] retain];      //NOTE: "andDelegate" refers to sessionDelegate
    return facebook;
}

- (BOOL)canProcessRequest
{
    return ([super canProcessRequest] && self.facebook.isSessionValid);
}

#pragma mark - insert methods
/*================================================================================================================================================
 *
 *================================================================================================================================================*/
-(NSString *)nameForPageId:(NSString *)page_id pageArray:(NSArray *)arr
{
    for (NSInteger i = 0; i < arr.count; i++) {
        NSDictionary *dict = [arr objectAtIndex:i];
        if ([[[dict objectForKey:@"page_id"] stringValue] isEqualToString:page_id]) {
            return [dict objectForKey:@"name"];
        }
    }
    return nil;
}

-(void)insertMapItemForCheckinDictionary:(NSDictionary *)checkinDictionary nameArray:(NSArray *)nameArray
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"insertMapItemForCheckinDictionary:nameDictionary()"];

    NSString *mapItem_id    = [[checkinDictionary objectForKey:@"page_id"] stringValue];
    if (![self existsMapItemForMapItemID:mapItem_id]) {
        NSDictionary *locationDictionary = [[checkinDictionary objectForKey:@"coords"] retain];
        MapItem *mapItem                 = [[self MapItemForMapItemID:mapItem_id] retain];
        mapItem.reversegeocoded          = [NSNumber numberWithInt:0];

        mapItem.datafeedtype_id          = [NSNumber numberWithInt:LGDataFeedTypeFaceBookCheckin];
        mapItem.latitude                 = [NSNumber numberWithFloat: [[locationDictionary objectForKey:@"latitude"] floatValue]];
        mapItem.longitude                = [NSNumber numberWithFloat: [[locationDictionary objectForKey:@"longitude"] floatValue]];
        mapItem.title                    = [self nameForPageId:mapItem_id pageArray:nameArray];
        mapItem.geocodeaccuracy          = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_Street];
        [mapItem release];
        [locationDictionary release];
    }
}


-(void)insertCheckinForCheckinDictionary:(NSDictionary *)checkinDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"insertCheckinForCheckinDictionary:fromDictionary:PlaceDictionary()"];
    
    NSString *checkin_id = [[[checkinDictionary objectForKey:@"checkin_id"] description] retain];
    if (![self existsCheckinForCheckinID:checkin_id]) {
        Checkin *myCheckin              = [(Checkin *)[self CheckinForCheckinID:checkin_id] retain];
        
        myCheckin.comment           = [checkinDictionary objectForKey:@"message"];
        myCheckin.create_date       = [NSDate dateWithTimeIntervalSince1970:[[checkinDictionary objectForKey:@"timestamp"] integerValue]];
        myCheckin.datafeedtype_id   = [NSNumber numberWithInt:LGDataFeedTypeFaceBookCheckin];
        
        //relationships....
        Person *checkin_person = [[Person initWithPersonId:[[checkinDictionary objectForKey:@"author_uid"] stringValue] inManagedObjectContext:self.managedObjectContext] retain];
        MapItem *checkin_mapItem = [[MapItem initWithMapItemId:[[checkinDictionary objectForKey:@"page_id"] stringValue] inManagedObjectContext:self.managedObjectContext] retain];

        myCheckin.Checkin_Person    = checkin_person;        
        myCheckin.Checkin_Mapitem   = checkin_mapItem;
        
        if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"insertCheckinForCheckinDictionary:fromDictionary(%@):PlaceDictionary(%@)", checkin_person.unique_id, checkin_mapItem.unique_id]];
        [checkin_person release];
        [checkin_mapItem release];
        [myCheckin release];
    }
}

-(void)insertPersonForDictionary:(NSDictionary *)person Person_id:(NSString *)person_id isFacebookFriend:(BOOL)isFriend
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"insertPersonForDictionary()"];
    if ([person objectForKey:@"uid"] == nil && [person objectForKey:@"id"] == nil) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"insertPersonForDictionary() -- invalid dictionary structure passed. exiting."];
        return;
    }
    
    Person *myPerson = [(Person *)[self PersonForPersonID:person_id] retain];    //inherited from superclass
    
    //new record
    if (!myPerson.name || [myPerson.datafeedtype_id integerValue] == 0) {
        myPerson.name               = [[person objectForKey:@"name"] copy];
        myPerson.isfacebookfriend   = isFriend;
        myPerson.datafeedtype_id    = [NSNumber numberWithInt:self.dataFeedType];
    }
    
    //if there's a profile update time then we'll use this to decide if we should update the record. otherwise, do nothing more.
    if (myPerson.profile_update_time) {
        NSDate *curProfileUpdateTime = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[myPerson.profile_update_time doubleValue]];
        NSDate *newProfileUpdateTime = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[[person valueForKey:@"profile_update_time"] doubleValue]];
        
        if ([curProfileUpdateTime isEqualToDate:newProfileUpdateTime]) return;
    }
    
    if (isFriend) {
        
        //FIX NOTE: check name orientation in name_format to see if first, last or last, first.
        if (![[person objectForKey:@"first_name"] isKindOfClass:[NSNull class]]) myPerson.first_name        = [person objectForKey:@"first_name"];
        if (![[person objectForKey:@"middle_name"] isKindOfClass:[NSNull class]]) myPerson.middle_name      = [person objectForKey:@"middle_name"];
        if (![[person objectForKey:@"last_name"] isKindOfClass:[NSNull class]]) myPerson.last_name          = [person objectForKey:@"last_name"];
        if (![[person objectForKey:@"locale"] isKindOfClass:[NSNull class]]) myPerson.locale                = [person objectForKey:@"locale"];
        if (![[person objectForKey:@"timezone"] isKindOfClass:[NSNull class]]) myPerson.timezone            = [person valueForKey:@"timezone"];
        if (![[person objectForKey:@"profile_update_time"] isKindOfClass:[NSNull class]]) myPerson.profile_update_time= [[person valueForKey:@"profile_update_time"] copy];
        if (![[person objectForKey:@"pic_small"] isKindOfClass:[NSNull class]]) myPerson.thumbnailurl       = [person objectForKey:@"pic_small"];

        myPerson.name = [NSString stringWithFormat:@"%@ %@", myPerson.first_name, myPerson.last_name];
        myPerson.tableCellTitle = myPerson.name;
        myPerson.tableCellSubTitle = [LGAppDataFeed nameForDataFeedType:self.dataFeedType];

        if (![[person objectForKey:@"name"] isKindOfClass:[NSNull class]]) myPerson.name = [person valueForKey:@"name"];

        myPerson.timestamp = [NSDate date];
        
        NSDictionary *current_location = [[person objectForKey:@"current_location"] retain];
        if (![current_location isKindOfClass:[NSNull class]]) {
            //==============================================================================================
            // MapItem
            //==============================================================================================
            MapItem *mapItem            = [[self MapItemForMapItemID:myPerson.unique_id] retain];
            mapItem.datafeedtype_id     = [NSNumber numberWithInt:self.dataFeedType];
            mapItem.timestamp           = [NSDate date];
            mapItem.title               = myPerson.name;
            mapItem.geocodeaccuracy     = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_None];
            mapItem.city                = [current_location objectForKey:@"city"];
            mapItem.state               = [current_location objectForKey:@"state"];
            mapItem.thumbnailurl        = myPerson.thumbnailurl;
            
            //==============================================================================================
            // Checkin
            //==============================================================================================
            Checkin *checkin          = [[self CheckinForCheckinID:myPerson.unique_id] retain];
            checkin.comment           = nil;
            checkin.create_date       = [NSDate date];
            checkin.datafeedtype_id   = [NSNumber numberWithInt:self.dataFeedType];
            checkin.thumbnailurl      = myPerson.thumbnailurl;
            
            //relationships....
            checkin.Checkin_Person    = myPerson;        
            checkin.Checkin_Mapitem   = mapItem;
            
            [checkin release];
            [mapItem release];
            
        }  // if current_location
        [current_location release];
        
    }  // if isFriend
    [myPerson release];     
}

-(void)insertPeopleForDictionary:(NSDictionary *)dictionary isFriend:(BOOL)isfriend
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"insertPeopleForDictionary()"];
    if (self.didCancelRequest) return;


    //dictionary might contain only 1 person
    if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"name"]) {
        [self insertPersonForDictionary:dictionary Person_id:[dictionary objectForKey:@"id"] isFacebookFriend:NO];
        return;
    }
    
    // or, it might also be a tags dictionary, which contains multiple people
    NSDictionary *tagsDictionary = [dictionary objectForKey:@"data"];
    for (NSDictionary *tag in tagsDictionary) {
        if (!self.didCancelRequest) {
            [self insertPersonForDictionary:tag Person_id:[tag objectForKey:@"id"] isFacebookFriend:NO];
        } else return;
    }
}

-(void)processNearbyPlaces
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"insertMapItemForFacebookPlacesArray()"];
    
    //store our current location in Plist. we won't allow re-queries until current location has changed by at least LGFB_MIN_DISTANCE_CHANGE_TO_REQUERY
    // Save authorization information
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
    [defaults setObject:[NSNumber numberWithFloat: self.fromLocation.coordinate.longitude] forKey:@"LGFBdownloadPlacesWithinDistanceLongitude"];
    [defaults setObject:[NSNumber numberWithFloat: self.fromLocation.coordinate.latitude] forKey:@"LGFBdownloadPlacesWithinDistanceLatitude"];
    [defaults setObject:[NSNumber numberWithInteger: self.fromDistance] forKey:@"LGFBdownloadPlacesWithinDistanceRange"];
    [defaults synchronize];
    [defaults release];

    float results = self.resultDictionary.count;
    float i = 0;
    
    for (NSDictionary *placeDictionary in self.resultDictionary) {
        if (!self.didCancelRequest) {
            i++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:i / results];
            });

            NSString *mapItem_id                 = [[[placeDictionary objectForKey:@"page_id"] description] retain];
            
            if (![self existsMapItemForMapItemID:mapItem_id]) {
                MapItem *mapItem                 = [[NSEntityDescription insertNewObjectForEntityForName:@"MapItem" inManagedObjectContext:self.managedObjectContext] retain];
                mapItem.unique_id                = mapItem_id;
                mapItem.reversegeocoded          = [NSNumber numberWithInt:0];
                mapItem.timestamp                = [NSDate date];
                
                mapItem.datafeedtype_id          = [NSNumber numberWithInt:LGDataFeedTypeFaceBookPlace];
                mapItem.latitude                 = [NSNumber numberWithFloat: [[placeDictionary objectForKey:@"latitude"] floatValue]];
                mapItem.longitude                = [NSNumber numberWithFloat: [[placeDictionary objectForKey:@"longitude"] floatValue]];
                mapItem.title_description        = [[placeDictionary objectForKey:@"display_subtext"] copy];
                mapItem.title                    = [[placeDictionary objectForKey:@"name"] copy];
                mapItem.checkincount             = [NSNumber numberWithInt:[[placeDictionary objectForKey:@"checkin_count"] integerValue]];
                mapItem.geocodeaccuracy          = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_Street];
                mapItem.userLocation             = self.fromLocation;
                mapItem.distancefromlastlocation = [NSNumber numberWithInt:mapItem.distanceFromCurrentLocation];
                
                [mapItem release];
            }
            
            [mapItem_id release];
            
        } else break;
    }

    if (!self.didCancelRequest) {
        [super didGetPlacesWithinDistance:self.fromDistance fromLocation:self.fromLocation];
    }
    self.checkinListPerson_id = nil;    
}

-(void)processNewCheckins
{
    /*================================================================================================================
     * process all core data entities based on the JSON file we'll download using this object.
     *
     * our processing strategy is as follows
     * a) delete any data which is no longer relevant (eg, timestamp is stale)
     * b) insert any new data. we'll test to see if records exist. if they don't then we insert. if they do then we MIGHT delete/re-insert the data depending on specifics of the record
     * c) synchronize our map data as necesary so that map annotations are consistent with the Core Data.
     *
     * iterate through all Facebook checkins.
     * process anything witha 1:1 relationship to checkin.
     * call appropriate method for anything else (which contains a 1:many relationship).
     *================================================================================================================*/
    if (OBJECT_DEBUG) [self logObjectVariables:@"processNewCheckins()"];
    

    NSArray *checkinArray = [[self.resultArray objectAtIndex:0] objectForKey:@"fql_result_set"];
    NSArray *nameArray = [[self.resultArray objectAtIndex:1] objectForKey:@"fql_result_set"];
    
    for (float i; i < (float)checkinArray.count; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:i / checkinArray.count];
        });

        NSDictionary *checkinDict = [checkinArray objectAtIndex:i];
        [self insertMapItemForCheckinDictionary:checkinDict nameArray:nameArray];
        [self insertCheckinForCheckinDictionary:checkinDict];

    }

    if (self.delegate != nil  && !self.didCancelRequest) {
        if ([self.delegate respondsToSelector:@selector(didGetCheckinsForPersonId:)]) {
            
            [self.delegate didGetCheckinsForPersonId:self.checkinListPerson_id];
            
        }
    }
    self.checkinListPerson_id = nil;
}

-(void)processNewFriends
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processNewFriends()"];

    float results = self.resultDictionary.count;
    float i = 0;
    NSInteger iBatchCount = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    for (NSDictionary *friend in self.resultDictionary) {
        if (!self.didCancelRequest) {
            i++;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:i / results];
            });

            //see Core Data Programming Guide page 152 for details on this pattern. this is intended to reduce the memory footprint of large imports
            if (iBatchCount == kIMPORT_BATCH_LIMIT) {
                [self.appDelegate saveContext];
                
                [pool drain];
                pool = [[NSAutoreleasePool alloc] init];
                
                iBatchCount = 0;
            }

            
            NSString *person_id = [[friend objectForKey:@"uid"] description];
            [self insertPersonForDictionary:friend Person_id:person_id isFacebookFriend:YES];
        } else break;
    }
    
    [pool drain];
    
    if (!self.didCancelRequest) {
        self.getPeopleTimeStamp = [NSDate date];
        
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(didGetPeople)]) {
                
                [self.delegate didGetPeople];
                
            }
        }
    }
}

/*================================================================================================================================================
 * Callbacks
 *================================================================================================================================================*/
#pragma mark - FBSessionDelegate 
/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"fbDidLogin()"];

    // Save authorization information
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
    [defaults setObject:self.facebook.accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:self.facebook.expirationDate forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [defaults release];
    [self.appDelegate.facebook release];
    self.appDelegate.facebook = nil;
    
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"fbDidNotLogin()"];

    [self cancelRequest];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"fbDidLogout()"];
    
    NSLog(@"fbDidLogout :=))");

}

#pragma mark - FBRequestDelegate
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"request:didFailWithError()"];
    NSLog(@"error: %@", [error description]);
    
    request.delegate = nil; //to prevent any further calls to self.
    [self cancelRequest]; 
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"request:didReceiveResponse()"];
    if (self.didCancelRequest) {
        [request.connection cancel];
    }
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"request:didLoad()"];

    request.delegate = nil; //to prevent any further calls to self.
  
    if (self.didCancelRequest) {
        [request.connection cancel];
        return;
    }
    [self.progressView setProgress:.33];
    
    if (OBJECT_DEBUG_VERBOSE) {
        NSLog(@"request url: %@", request.url );
        NSLog(@"request httpMethod: %@", request.httpMethod);
        NSLog(@"request params: %@", [request.params description]);
        NSLog(@"request result class: %@", [[result class] description]);
        NSLog(@"request result: %@", [result description]);
        NSLog(@"\n");
    }
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        self.resultDictionary = [result objectForKey:@"data"];
        self.resultArray = [result objectForKey:@"data"];
    } else return;
    
    
    [self.appDelegate saveContext];
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("my queue", NULL);
    dispatch_async(myQueue, ^
                   {

                       [self processRequest]; 
                       
                   });
    dispatch_release(myQueue);

    
}

#pragma mark - object Utility and Helper methods
/*================================================================================================================================================
 * Utility Methods
 *================================================================================================================================================*/
/*
- (NSOperation *)processRequestOperation
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processRequestOperation()"];
    NSLog(@"%@.processRequestOperation", [[self class] description]);

    NSInvocationOperation *theOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(processRequest) object:nil] autorelease];
    return theOp;
}
*/

- (void)processRequest 
{
    if (self.didCancelRequest) return;
    if (OBJECT_DEBUG) [self logObjectVariables:@"processRequest()"];
    [self.appDelegate.managedObjectContext lock];
    
    switch (self.currentQueryType) {
        case LGFBQueryTypeFriendsList:
            if (OBJECT_DEBUG) [self logObjectVariables:@"processRequest() - LGFBQueryTypeFriendsList"];
            [self processNewFriends];
            break;
            
        case LGFBQueryTypeCheckins:
            if (OBJECT_DEBUG) [self logObjectVariables:@"processRequest() - LGFBQueryTypeCheckins"];
            [self processNewCheckins];
            break;
            
        case LGFBQueryTypeLikes:
            break;
            
        case LGFBQueryTypePlaces:
            if (OBJECT_DEBUG) [self logObjectVariables:@"processRequest() - LGFBQueryTypePlaces"];
            [self processNearbyPlaces];
            break;
            
        case LGFBQueryTypeAppLogin:
            break;
            
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:0];
        [self.progressView setHidden:YES];
    });
    
    [self.appDelegate saveContext];
    [self.appDelegate.managedObjectContext unlock];
    [self setBusy:NO];
}

- (BOOL)executeGraphRequest:(NSString *)graphPath Parameters:(NSMutableDictionary *)parameters Delegate:(id<FBRequestDelegate>)delegate
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeGraphRequest:Parameters:Delegate()"];
    [self setBusy:YES];
    
    if (!parameters) parameters = [[NSMutableDictionary alloc] init];
    else [parameters retain];
    
    [self.facebook requestWithGraphPath:graphPath andParams:parameters andDelegate:delegate];
    [parameters release];
    
    return YES;
}
- (BOOL)executeGraphRequest:(NSString *)graphPath forQueryType:(LGFBQueryType)queryType Parameters:(NSMutableDictionary *)parameters
{
    if (!self.canProcessRequest) return NO;
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeGraphRequest()"];

    [self setBusy:YES];
    _currentQueryType = queryType;
    if (!parameters) parameters = [[NSMutableDictionary alloc] init];
    else [parameters retain];
    
    [self.facebook requestWithGraphPath:graphPath andParams:parameters andDelegate:self];
    [parameters release];
    
    return YES;
}


#pragma mark - Thread Management

- (BOOL)cancelRequest
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"cancelRequest()"];
    if (self.isBusy) {
        if ([super cancelRequest]) {
        }
    }
            
    if (resultDictionary) resultDictionary = nil;
    
    if (facebook) {
        [facebook logout:self];
    }

    return YES;
}

#pragma mark - LGAppDataFeed Protocol
/*

- (void)EnableDataFeed
{
    [super EnableDataFeed];
}

- (void)DisableDataFeed
{
    [super DisableDataFeed];
    
}
*/


- (BOOL)getPeoplewithCycleTest:(BOOL)test
{
    if (!self.canProcessRequest) return NO;
    if ([super getPeoplewithCycleTest:test]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"getPeople()"];
        
        NSString *fql = @"SELECT uid, first_name, middle_name, last_name, name, name_format, pic_small, profile_update_time, current_location, locale FROM user WHERE uid = me() OR uid IN (SELECT uid2 FROM friend WHERE uid1 = me())";
        
        NSMutableDictionary *parameters = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           fql, @"q",
                                           nil] retain];
        
        BOOL retVal = [self executeGraphRequest:@"fql" forQueryType:LGFBQueryTypeFriendsList Parameters:parameters];
        [parameters release];
        return retVal;
    }
    return NO;
    

}
- (BOOL)getPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location withCycleTest:(BOOL)test
{
    if (!self.canProcessRequest || !location) return NO;
    if ([super getPlacesWithinDistance:distance fromLocation:location withCycleTest:test]) {
        if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"downloadPlacesWithinDistance(%d):fromLocation(%f, %f)", distance, location.coordinate.latitude, location.coordinate.longitude]];
        
        //lookup coordinate from the most recent query
        NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
        float latitude  = [defaults floatForKey:@"LGFBdownloadPlacesWithinDistanceLatitude"];
        float longitude = [defaults floatForKey:@"LGFBdownloadPlacesWithinDistanceLongitude"];
        self.fromDistance    = [defaults integerForKey:@"LGFBdownloadPlacesWithinDistanceRange"];
        [defaults release];
        
        if (test) {  // = YES if we want to consider how much the user's device has moved since the last Nearby Places query
            if (latitude != 0 && longitude != 0) {
                self.fromLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                if ([location distanceFromLocation:self.fromLocation] < kLGNEARBYPLACES_MIN_REQUERY_DISTANCE && (distance == self.fromDistance)) return NO;
            }
        }
        
        //now, reset our local property object to the current reference location. we'll refer to this location object after query results have returned.
        self.fromLocation = location;
        self.fromDistance = distance;
        
        latitude = self.fromLocation.coordinate.latitude;
        longitude = self.fromLocation.coordinate.longitude;
        if (self.fromDistance <= 0 || longitude == 0 || latitude == 0) return NO;
        
        if (OBJECT_DEBUG) [self logObjectVariables:@"downloadPlacesWithinDistance:fromLocation"];
        if (self.fromDistance > 50000) self.fromDistance = 50000;  //this is Facebook's range limit for their distance() fql function
        
        NSString *fql = [NSString stringWithFormat:@"SELECT page_id, name, description, geometry, latitude, longitude, checkin_count, display_subtext FROM place WHERE distance(latitude, longitude, %C%f%C, %C%f%C) < %d", (unichar) 0x0022, latitude, (unichar) 0x0022, (unichar) 0x0022, longitude, (unichar) 0x0022, self.fromDistance];
        
        
        
        NSMutableDictionary *parameters = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            fql, @"q",
                                            nil] retain];
        
        BOOL retVal = [self executeGraphRequest:@"fql" forQueryType:LGFBQueryTypePlaces Parameters:parameters];
        [parameters release];
        
        return retVal;
    }

    return NO;
}


-(BOOL)getCheckinsForPersonId:(NSString *)person_id withCycleTest:(BOOL)test
{
    if (!self.canProcessRequest) return NO;
    if ([super getCheckinsForPersonId:person_id withCycleTest:test]) {
        if (OBJECT_DEBUG) [self logObjectVariables:[[[@"getCheckinsForPersonId(" stringByAppendingString:person_id] stringByAppendingString:@")"] copy]];
        
        self.checkinListPerson_id = person_id;
        
        //see http://developers.facebook.com/docs/reference/fql/
        //for additional info on facebook FQL multi-query.
        
        NSString *fql1 = [NSString stringWithFormat:@"SELECT checkin_id, page_id, author_uid, timestamp, message, coords FROM checkin WHERE author_uid= %@", self.checkinListPerson_id];
        NSString *fql2 = [NSString stringWithFormat:@"SELECT page_id, name FROM page WHERE page_id IN (SELECT page_id FROM #queryCheckin)"];
        NSString *fql = [NSString stringWithFormat: @"{\"queryCheckin\":\"%@\",\"queryName\":\"%@\"}",fql1,fql2];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            fql, @"q",
                                            nil];
        
        return [self executeGraphRequest:@"fql" forQueryType:LGFBQueryTypeCheckins Parameters:parameters];
        
    }
    return NO;
    
}


#pragma mark - object lifecycle
- (void)authorizeFacebook
{
    self.appDelegate.facebook = self.facebook;
    [self.facebook authorize:self.facebookPermissions];

}

-(LGAppIntegratorFacebook *)init
{
    if (self = [super initWithDataFeedType:LGDataFeedTypeFaceBookFriend]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"init()"];
        
        /*===================================================================================
         *
         *  ported from sample app: application:didFinishLaunchingWithOptions
         *
         *===================================================================================*/
        
        
        // Check App ID:
        // This is really a warning for the developer, this should not
        // happen in a completed app
        if (!kFBAppId) {
            UIAlertView *alertView = [[UIAlertView alloc] 
                                      initWithTitle:@"Setup Error" 
                                      message:@"Missing app ID. You cannot run the app until you provide this in the code." 
                                      delegate:self 
                                      cancelButtonTitle:@"OK" 
                                      otherButtonTitles:nil, 
                                      nil];
            [alertView show];
            [alertView release];
        } else {
            // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
            // be opened, doing a simple check without local app id factored in here
            NSString *url = [NSString stringWithFormat:@"fb%@://authorize",kFBAppId];
            BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
            NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
            if ([aBundleURLTypes isKindOfClass:[NSArray class]] && 
                ([aBundleURLTypes count] > 0)) {
                NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
                if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                    NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                    if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                        ([aBundleURLSchemes count] > 0)) {
                        NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                        if ([scheme isKindOfClass:[NSString class]] && 
                            [url hasPrefix:scheme]) {
                            bSchemeInPlist = YES;
                        }
                    }
                }
            }
            // Check if the authorization callback will work
            BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
            if (!bSchemeInPlist || !bCanOpenUrl) {
                UIAlertView *alertView = [[UIAlertView alloc] 
                                          initWithTitle:@"Setup Error" 
                                          message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist." 
                                          delegate:self 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil, 
                                          nil];
                [alertView show];
                [alertView release];
            } else {
                //Handle Facebook login...            
                // Check and retrieve authorization information
                NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
                if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
                    self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
                    self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
                }
                [defaults release];
                if (!self.facebook.isSessionValid) {
                    [self authorizeFacebook];
                }
            }
        }
    }
    return self;
}


-(void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    if (self.isBusy) [self cancelRequest];
    
    if (facebook) {
        [facebook release];
    }
    
    if (facebookPermissions) {
        [facebookPermissions release];
        facebookPermissions = nil;
    }
    
    if (resultDictionary) {
        [resultDictionary release];
        resultDictionary = nil;
    }
    
    [super dealloc];
}


@end

/*
 - (BOOL)requestFacebookAppAccessToken
 {
 if (OBJECT_DEBUG) [self logObjectVariables:@"requestFacebookAppAccessToken()"];
 
 NSString *graphPath = @"oauth/access_token";
 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
 kFBAppId, @"client_id",
 kFBSecretId, @"client_secret",
 @"client_credentials", @"grant_type",
 nil];
 
 [self executeGraphRequest:graphPath forQueryType:LGFBQueryTypeAppLogin Parameters:params];
 [params release];
 
 return NO;
 }

 */

/*
 if (self.currentQueryType == LGFBQueryTypeAppLogin) {
 //in this case the results are returned in a NSMutableData object (a raw data stream), which has to be un-enconded.
 NSString *fbAppAccessTokenKey = [[NSString alloc] initWithData:(NSData *)result encoding:NSUTF8StringEncoding];
 
 // Save authorization information
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 [defaults setObject:fbAppAccessTokenKey forKey:@"FBAppAccessTokenKey"];
 [defaults synchronize];
 
 return;
 }
 */

