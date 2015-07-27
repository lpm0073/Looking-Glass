//
//  Person.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "Checkin.h"
#import "MapItem.h"


#define LG_FACEBOOK_CHECKINS_MAX_REFRESH_MINUTES 15
//#define LG_FACEBOOK_STANDARDUSERINFO_REFRESH_DAYS 7

@interface Person()

@property (nonatomic, retain) NSDate *checkinsLoadedTimeStamp;

@end

@implementation Person

@synthesize firstLetterOfName;
@synthesize checkinsLoadedTimeStamp;
@synthesize tableCellTitle;
@synthesize tableCellSubTitle;

@dynamic name;
@dynamic isfacebookfriend;
@dynamic person_Attendee;
@dynamic person_Checkin;
@dynamic title;
@dynamic distancefromlastlocation;

//additional facebook standard user info properties
@dynamic timestamp;
@dynamic first_name;
@dynamic last_name;
@dynamic locale;
@dynamic timezone;
@dynamic current_location;
@dynamic middle_name;
@dynamic hometown_location;
@dynamic profile_update_time;



#pragma mark - Setters and Getters
- (NSString *)tableCellTitle
{
    if (!tableCellTitle) {
        @synchronized(self) {
            if (self.first_name && self.last_name) tableCellTitle = [[NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name] copy];
            else {
                if (self.name) tableCellTitle = [self.name copy];
                else if (self.last_name) tableCellTitle = [self.last_name copy];
                else if (self.first_name) tableCellTitle = [self.first_name copy];
                else tableCellTitle = NSLocalizedString(@"person_NoName", @"No Name");
            }
        }
    }
    return tableCellTitle;
}
- (NSString *)tableCellSubTitle
{
    if (!tableCellSubTitle) {
        @synchronized(self) {
            if (self.dataFeedType == LGDataFeedTypeLinkedIn) {
                tableCellSubTitle  = [self.title copy];
            } else {
                tableCellSubTitle  = [[LGAppDataFeed nameForDataFeedType:self.dataFeedType] copy];
            }
        }
    }
    return tableCellSubTitle;
}

- (LGMapItemGeocodeAccuracy)geocodeAccuracy
{
    //LinkedIn short-circuits the data model, linking person directly to mapItem.
    if (self.dataFeedType == LGDataFeedTypeLinkedIn) {
        MapItem *mapitem = [[MapItem initWithMapItemId:self.unique_id inManagedObjectContext:self.appDelegate.managedObjectContext] autorelease];
        return mapitem.geocodeAccuracy;
    }
    if (self.person_Checkin) {
        Checkin *checkin = [self.person_Checkin anyObject];
        if (checkin.checkin_Mapitem) {
            return checkin.checkin_Mapitem.geocodeAccuracy;
        }
        
    }
    return LGMapItemGeocodeAccuracy_None;
}

- (NSString *)firstLetterOfName
{
    if (!firstLetterOfName) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"firstLetterOfName ()"];
        firstLetterOfName = [[[self.name substringToIndex:1] capitalizedString] copy];
    } 
    return firstLetterOfName;
}


#pragma mark - LGAppDataFeedDelegate methods
- (void)didGetCheckinsForPersonId:(NSString *)person_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"didDownloadCheckinsForPersonId()"];

    //we'll use this to prevent serial downloading of the checkin list, as this data is quasi-static
    //and so only needs periodic updating.
    self.checkinsLoadedTimeStamp = [NSDate date];
    [self.appDelegate saveContext];
    [self setBusy:NO];
}

#pragma mark - Object API methods

- (void)requestPlaces
{
    if (self.isBusy) return;
    if (checkinsLoadedTimeStamp) {
        if ([checkinsLoadedTimeStamp compare:[NSDate dateWithTimeIntervalSinceNow:-60 * LG_FACEBOOK_CHECKINS_MAX_REFRESH_MINUTES]] == NSOrderedDescending) return;
    }
    if (OBJECT_DEBUG) [self logObjectVariables:@"requestPlaces()"];

    switch (self.dataFeedType)
    {
        case LGDataFeedTypeBeacon:
        case LGDataFeedTypeAddressBook:
            if (!self.integratorAddressBook.isBusy) {
                //nothing to do here.
            }
            break;
        case LGDataFeedTypeCalendar:
        case LGDataFeedTypeFaceBookFriend:
            if (!self.integratorFacebook.isBusy) {
                if (OBJECT_DEBUG_VERBOSE) NSLog(@"requestPlaces - LGDataFeedTypeFaceBook %@", self.unique_id);
                [self.integratorFacebook getCheckinsForPersonId:self.unique_id withCycleTest:YES];
                [self setBusy:YES];
            }
            break;
        case LGDataFeedTypeFaceBookCheckin: break;
        case LGDataFeedTypeFaceBookPlace: break;
        case LGDataFeedTypeFourSquare: break;
        case LGDataFeedTypeGooglePlaces: break;
        case LGDataFeedTypeGooglePlus: break;
        case LGDataFeedTypeGowalla: break;
        case LGDataFeedTypeGroupon: break;
        case LGDataFeedTypeJive: break;
        case LGDataFeedTypeLinkedIn: break;
        case LGDataFeedTypeLOCKERZ: break;
        case LGDataFeedTypeMySpace: break;
        case LGDataFeedTypeOutlook: break;
        case LGDataFeedTypeSkype: break;
        case LGDataFeedTypeTwitter: break;
            break;
    }
    
}

- (void)doHousekeeping
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doHousekeeping()"];
    [super doHousekeeping];
    
    //[self requestPlaces];  FIX NOTE: LIKE THIS IDEA, BUT THE SCREEN FREEZES SOMETIMES WHILE THIS IS RUNNING.
    
    if (self.geocodeAccuracy < LGMapItemGeocodeAccuracy_Street) {
        //FIX NOTE: add call to mapItem geocode
    }
    
}

+ (NSString *)nameForID:(NSString *)person_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"nameForID: inManagedObjectContext()"];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"unique_id = %@", person_id];
    request.fetchLimit      = 1;

	NSError *error  = nil;
    
    [context lock];
	NSArray *arr    = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    
    Person *person  = [arr lastObject];
	[request release];
    [arr release];
    
    return [person.name copy];
}


#pragma mark - Object Lifecycle
-(void)reset
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"reset()"];

    if (firstLetterOfName) {
        [firstLetterOfName release];
        firstLetterOfName = nil;
    }
    if (checkinsLoadedTimeStamp) {
        [checkinsLoadedTimeStamp release];
        checkinsLoadedTimeStamp = nil;
    }
    if (tableCellTitle) {
        [tableCellTitle release];
        tableCellTitle = nil;
    }
    if (tableCellSubTitle) {
        [tableCellSubTitle release];
        tableCellSubTitle = nil;
    }
    
    [super reset];
}
-(void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    [self reset];
    [super dealloc];
}


+ (Person *)initInManagedContext:(NSManagedObjectContext *)thisContext
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"initInManagedContext:()"];
    
    Person *person              = nil;
    person                      = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:thisContext];

    
    if (OBJECT_DEBUG) [self logObjectVariables:@"initInManagedContext()"];
    return person;
}

+ (Person *)initWithPersonId:(NSString *)thisPerson_id inManagedObjectContext:(NSManagedObjectContext *)thisContext
{

    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithPersonId:inManagedObjectContext()"];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity          = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:thisContext];
	request.predicate       = [NSPredicate predicateWithFormat:@"unique_id = %@", thisPerson_id];
    request.fetchLimit      = 1;

	NSError *error  = nil;
    
    [thisContext lock];
	NSArray *arr    = [[[thisContext executeFetchRequest:request error:&error] copy] retain];  // <-- NOTE, the request actually should return exactly 1 record
    [thisContext unlock];
    
    Person *person  = [arr lastObject];
	[request release];
    [arr release];
    
    if (OBJECT_DEBUG) [self logObjectVariables:[[@"initWithPersonId(" stringByAppendingString:thisPerson_id] stringByAppendingString:@") - exiting"]];
    return person;
}

+ (void)removeForPersonId:(NSString *)thisPerson_id inManagedObjectContext:(NSManagedObjectContext *)thisContext
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"removeForPersonId()"];

    Person *obj = [Person initWithPersonId:thisPerson_id inManagedObjectContext:thisContext];
    if (obj) {
        [thisContext deleteObject:obj];
    }
}

+ (void)refreshAllPeopleInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [Person logObjectVariables:@"refreshAllPeopleInManagedObjectContext()"];

    NSFetchRequest *request = nil;
    NSArray *arr = nil;
    NSError *error = nil;
    
    LGAppDelegate *appDelegate = (LGAppDelegate *) [[[UIApplication sharedApplication] delegate] retain];
    

    //download thumbnail images for facebook and linkedin person records.
    request = [[NSFetchRequest alloc] init];
    error = nil;
    request.entity          = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
    
    [context lock];
    arr                     = [[[context executeFetchRequest:request error:&error] copy] retain]; 
    [context unlock];
    
    for (Person *person in arr) {
        [person doHousekeeping]; 
    }
    [request release];
    [arr release];
    [appDelegate release];

}

+ (void)updateDistanceFromLastLocationTo:(NSInteger)distance 
                               ForPerson:(NSString *)unique_id 
                  InManagedObjectContext:(NSManagedObjectContext *)context
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"updateDistanceFromLastLocationTo:ForPerson(%@)", unique_id]];

	NSError *error  = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity          = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
	request.predicate       = [NSPredicate predicateWithFormat:@"unique_id = %@", unique_id];
    request.fetchLimit      = 1;
    
    
    [context lock];
	Person *person  = [[[context executeFetchRequest:request error:&error] copy] lastObject];
    [context unlock];
	[request release];
    
    if (person) {
        person.distancefromlastlocation = [NSNumber numberWithInt: distance];
        [context save:&error];
        [context reset];
    }
}

+ (void)initializeDistanceFromLastLocationInManagedObjectContext:(NSManagedObjectContext *)context
{

    if (OBJECT_DEBUG) [self logObjectVariables:@"initializeDistanceFromLastLocationInManagedObjectContext()"];
    
    NSError *error  = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity          = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
	request.predicate       = [NSPredicate predicateWithFormat:@"distancefromlastlocation == nil OR distancefromlastlocation >= 0"];
    
    [context lock];
	NSArray *arr  = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
	[request release];

    for (Person *person in arr) {
        person.distancefromlastlocation = [NSNumber numberWithInt:-1];
    }
    [context save:&error];
    
    [arr release];

}

+ (void)removeAllObjectsForDataFeedType:(LGDataFeedType)dataFeedType 
                           ProgressView:(UIProgressView *)progressView 
               FromManagedObjectContext:(NSManagedObjectContext *)context

{
    if (OBJECT_DEBUG) [self logObjectVariables:@"removeAllObjectsForDataFeedType:FromManagedObjectContext()"];

    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
	NSError *error = nil;
    
	request.entity          = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
    request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id == %d", dataFeedType];
    
    [context lock];
    NSArray *arr            = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];

    CGFloat i = arr.count;
    CGFloat results = i;
    
	for (Person *obj in arr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressView setProgress: i / results animated:YES];
        });
        i --;

        [Person removeForPersonId:obj.unique_id inManagedObjectContext:context];
    }
	[request release];
    [arr release];
    [context save:&error];

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


@end
