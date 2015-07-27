//
//  LGAppDataFeed.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "LGAppDataFeed.h"
#import "Person.h"
#import "Checkin.h"
#import "MapItem.h"
#import "Attendee.h"


#pragma mark - Private Declarations
@interface LGAppDataFeed()
{
    BOOL _didCancelRequest;
    
}
+ (void)setCartForDataFeedType:(LGDataFeedType)dataFeedType Quantity:(NSInteger)quantity;

@end

@implementation LGAppDataFeed

#pragma mark - Synthesized Properties

@synthesize delegate;
@synthesize appDelegate;
@synthesize managedObjectContext;
@synthesize canProcessRequest;
@synthesize progressView;

//common API method input parameters
@synthesize getPeopleNextTime;
@synthesize getPeopleTimeStamp;
@synthesize fromLocation;
@synthesize fromDistance;
@synthesize checkinListPerson_id;


// Helper and Convenience Properties
@synthesize dataFeedType;

// Data Feed Common Properties
@synthesize isBusy = _isBusy;

/*==========================================================================================================================================
 *
 *==========================================================================================================================================*/
#pragma mark - Setters and Getters


- (BOOL)didCancelRequest
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"didCancelRequest() == %d", _didCancelRequest]];
    return _didCancelRequest;
}

- (LGAppDelegate *)appDelegate
{
    if (!appDelegate) appDelegate = (LGAppDelegate *) [[[UIApplication sharedApplication] delegate] retain];
    return appDelegate;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!managedObjectContext) managedObjectContext = [self.appDelegate.managedObjectContext retain];
    return managedObjectContext;
}

- (BOOL)canProcessRequest
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"canProcessRequest()"];
    if (![LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType]) return NO;
    if (self.isBusy) return NO;
    if (!self.appDelegate.isDeviceConnectedToAnything) return NO;
    if (!self.appDelegate.isDeviceBatteryLevelOk) return NO;
    return YES;
}

- (NSDate *)getPeopleTimeStamp
{
    if (!getPeopleTimeStamp) {
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"getPeopleTimeStamp()", [getPeopleTimeStamp description]]];
        
        getPeopleTimeStamp = [[[self getTimestampForDataElement:[NSString stringWithFormat:@"%@GetPeople", [[self class] description]]] copy] retain];
        if (getPeopleTimeStamp == nil) getPeopleTimeStamp = [[NSDate distantPast] retain];
    }
    return getPeopleTimeStamp;
}

- (void)setGetPeopleTimeStamp:(NSDate *)newGetPeopleTimeStamp
{
    @synchronized(self) {
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"setGetPeopleTimeStamp()"];
        [newGetPeopleTimeStamp retain];
        [getPeopleTimeStamp release];
        getPeopleTimeStamp = newGetPeopleTimeStamp;
        
        [self setTimestampForDataElement:[NSString stringWithFormat:@"%@GetPeople", [[self class] description]] toDate:newGetPeopleTimeStamp];
    }
}

- (NSDate *)getPeopleNextTime
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"getPeopleNextTime()"];
    
    if (self.appDelegate.isDeviceConnectedToWifi) return [NSDate dateWithTimeInterval:60 * 60 * kLGFRIENDS_MIN_HOURS_TO_REQUERY_LIST_WIFI sinceDate:self.getPeopleTimeStamp];
    else {
        if (self.appDelegate.isDeviceConnectedToAnything) return [NSDate dateWithTimeInterval:60 * 60 * kLGFRIENDS_MIN_HOURS_TO_REQUERY_LIST_WWAN sinceDate:self.getPeopleTimeStamp];
        else {
            return [NSDate distantFuture];
        }
    }
}

#pragma mark - App Data Feed Methods
/*================================================================================================================================================
 *
 *================================================================================================================================================*/
- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
        //
        // object instance variables go here
        //
    }
    if (OBJECT_DEBUG) {
        NSLog(@"%@->%@.%@",[[self superclass] description], [[self class] description], suffix);
    }
}
+ (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
        //
        // object instance variables go here
        //
    }
    if (OBJECT_DEBUG) {
        NSLog(@"%@->%@.%@",[[self superclass] description], [[self class] description], suffix);
    }
}



-(Attendee *)AttendeeForAttendeeId:(NSString *)attendee_id 
                   CheckinId:(NSString *)checkin_id
                    PersonId:(NSString *)person_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"insertAttendeeForAttendeeId:CheckinId:PersonId(%@)", attendee_id]];
    
    if (!attendee_id) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"insertAttendeeForAttendeeId:CheckinId:PersonId() - attendee_id == nil"];
        return nil;
    }
    if (!checkin_id) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"insertAttendeeForAttendeeId:CheckinId:PersonId() - checkin_id == nil"];
        return nil;
    }
    if (!person_id) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"insertAttendeeForAttendeeId:CheckinId:PersonId() - person_id == nil"];
        return nil;
    }
    
	Attendee *attendee = nil;

	
    if (![self existsAttendeeForAttendeeId:attendee_id]) {
        attendee                    = [NSEntityDescription insertNewObjectForEntityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
        attendee.unique_id          = attendee_id;
        attendee.datafeedtype_id    = [NSNumber numberWithInt:self.dataFeedType];
        attendee.attendee_Checkin   = [Checkin initWithCheckInId:checkin_id inManagedObjectContext:self.managedObjectContext];
        attendee.attendee_Person    = [Person initWithPersonId:person_id inManagedObjectContext:self.managedObjectContext];

    } else {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSError *error          = nil;
        request.entity          = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:self.managedObjectContext];
        request.predicate       = [NSPredicate predicateWithFormat:@"attendee_id = %@", attendee_id];
        request.fetchLimit      = 1;
        
        [self.appDelegate.managedObjectContext lock];
        NSArray *arr            = [[[self.managedObjectContext executeFetchRequest:request error:&error] copy] retain];
        [self.appDelegate.managedObjectContext unlock];
        attendee                = [arr lastObject];
        [request release];
        [arr release];
    }
    
    return attendee;
}


-(Person *)PersonForPersonID:(NSString *)person_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"insertPersonForPersonID(%@)", person_id]];
    if (!person_id) return nil;
    
    Person *myPerson = nil;

    if (![self existsPersonForPersonID:person_id]) {
		myPerson                    = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
        myPerson.unique_id          = person_id;
    } else {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        request.entity          = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
        request.predicate       = [NSPredicate predicateWithFormat:@"unique_id = %@", person_id];
        request.fetchLimit      = 1;
        
        [self.appDelegate.managedObjectContext lock];
        NSArray *arr            = [[[self.managedObjectContext executeFetchRequest:request error:&error] copy] retain];
        [self.appDelegate.managedObjectContext unlock];
        myPerson                = [arr lastObject];
        [request release];
        [arr release];
    }
	
    return myPerson;
}

-(Checkin *)CheckinForCheckinID:(NSString *)checkin_id 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"insertCheckinForCheckinID()"];
    
    Checkin *myCheckin = nil;
    
    
    
    if (![self existsCheckinForCheckinID:checkin_id]) {
		myCheckin                  = [NSEntityDescription insertNewObjectForEntityForName:@"Checkin" inManagedObjectContext:self.managedObjectContext];
        myCheckin.unique_id        = checkin_id;
    } else {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        request.entity          = [NSEntityDescription entityForName:@"Checkin" inManagedObjectContext:self.managedObjectContext];
        request.predicate       = [NSPredicate predicateWithFormat:@"unique_id = %@", checkin_id];
        request.fetchLimit      = 1;
        
        [self.appDelegate.managedObjectContext lock];
        NSArray *arr            = [[[self.managedObjectContext executeFetchRequest:request error:&error] copy] retain];
        [self.appDelegate.managedObjectContext unlock];
        myCheckin               = [arr lastObject];
        [request release];
        [arr release];
    }
    
    return myCheckin;
}


-(MapItem *)MapItemForMapItemID:(NSString *)mapItem_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"insertMapItemForMapItemID()"];
    
    MapItem *mapItem = nil;
	
    
    if (![self existsMapItemForMapItemID:mapItem_id]) {
		mapItem                 = [NSEntityDescription insertNewObjectForEntityForName:@"MapItem" inManagedObjectContext:self.managedObjectContext];
        mapItem.unique_id       = mapItem_id;
        mapItem.timestamp       = [NSDate date];
        mapItem.reversegeocoded = [NSNumber numberWithInt:0];
    } else {
        //check to see if MapItem already exists.....
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSError *error = nil;
        
        request.entity          = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:self.managedObjectContext];
        request.predicate       = [NSPredicate predicateWithFormat:@"unique_id = %@", mapItem_id];
        request.fetchLimit      = 1;

        [self.appDelegate.managedObjectContext lock];
        NSArray *arr            = [[[self.managedObjectContext executeFetchRequest:request error:&error] copy] retain];
        [self.appDelegate.managedObjectContext unlock];
        
        mapItem                 = [arr lastObject];
        [arr release];
        [request release];
    }
    

    return mapItem;
}

- (BOOL)existsEntity:(NSString *)entity ForPredicate:(NSString *)predicate
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat: @"existsEntity(%@):ForPredicate(%@)", entity, predicate]];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSError *error = nil;
    
	request.entity          = [NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext];
	request.predicate       = [NSPredicate predicateWithFormat:predicate];
    request.fetchLimit      = 1;
    request.resultType      = NSManagedObjectIDResultType;  //only returns an array of id's instead of actually instantiating the objects.
	
    BOOL exists = NO;
    
    [self.appDelegate.managedObjectContext lock];
    if ([self.managedObjectContext countForFetchRequest:request error:&error] > 0) exists = YES;
    [self.appDelegate.managedObjectContext unlock];
    
	[request release];
    
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat: @"existsEntity(%@):ForPredicate(%@) result = %d", entity, predicate, exists]];
    
    return exists;
    
}

- (BOOL)existsPersonForPersonID:(NSString *)unique_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat: @"existsPersonForPersonID(%@)", unique_id]];
    return [self existsEntity:@"Person" ForPredicate:[NSString stringWithFormat:@"unique_id == \"%@\"", unique_id]];
}
- (BOOL)existsCheckinForCheckinID:(NSString *)unique_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat: @"existsCheckinForCheckinID(%@)", unique_id]];
    return [self existsEntity:@"Checkin" ForPredicate:[NSString stringWithFormat:@"unique_id == \"%@\"", unique_id]];
}

- (BOOL)existsMapItemForMapItemID:(NSString *)unique_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat: @"existsMapItemForMapItemID(%@)", unique_id]];
    return [self existsEntity:@"MapItem" ForPredicate:[NSString stringWithFormat:@"unique_id == \"%@\"", unique_id]];
}
- (BOOL)existsAttendeeForAttendeeId:(NSString *)unique_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat: @"existsAttendeeForAttendeeId(%@)", unique_id]];
    return [self existsEntity:@"Attendee" ForPredicate:[NSString stringWithFormat:@"unique_id == \"%@\"", unique_id]];
}


- (BOOL)setTimestampForDataElement:(NSString *)suffix toDate:(NSDate *)date
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"setTimeStampForDataElement(%@)", suffix]];

    NSString *key = [[[self class] description] stringByAppendingString:suffix];
    
    // Save authorization information
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
    [defaults setObject:date forKey:key];
    [defaults synchronize];
    [defaults release];

    return YES;
}

- (NSDate *)getTimestampForDataElement:(NSString *)suffix
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"getTimeStampForDataElement(%@)", suffix]];
    
    NSString *key = [[[self class] description] stringByAppendingString:suffix];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:key]) {
        return [(NSDate *)[defaults objectForKey:key] copy];
    }

    return nil;
}

#pragma mark - Thread Mgt Methods

- (BOOL)cancelRequest
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"cancelRequest()"];
    
    _didCancelRequest = YES;
    if (checkinListPerson_id) checkinListPerson_id = nil;
    if (fromLocation) fromLocation = nil;
    
    //[self.appDelegate.operationQueue cancelAllOperations];

    [self setBusy:NO];
    return YES;
}
- (BOOL)isBusy
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isBusy() - super == %d", _isBusy]];
    return _isBusy;
}


- (void)setBusy:(BOOL)busy
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"setBusy(%d) - super", busy]];

    if (busy) {
        _didCancelRequest = NO;
    }
    [self.progressView setHidden:!busy];
    [self.progressView setProgress:.0];
    _isBusy = busy;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = busy;
    
}

#pragma mark - API Class Convenience Methods

+ (BOOL)isUnlockedDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"isUnlockedDataFeedType"];
    
    BOOL retVal = NO;
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
   
    if ([defaults objectForKey:[LGAppDataFeed keyForDataFeedType:dataFeedType]]) retVal = YES;
    else retVal = NO;
    
    [defaults release];
    return retVal;
}

+ (void)unlockDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"unlockDataFeedType"];

    if ([LGAppDataFeed isUnlockedDataFeedType:dataFeedType]) return;
    
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];

    [defaults setObject:[NSDate date] forKey:[LGAppDataFeed keyForDataFeedType:dataFeedType]];
    [defaults synchronize];
    [defaults release];
    
    //by default, if we're unlocking a datafeed then we should also enable it.
    [self setDataFeedType:dataFeedType Enabled:YES];
    
}

+ (BOOL)isEnabledDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"isEnabledDataFeedType:"];
    
    BOOL retVal = NO;
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
    NSString *key = [[NSString stringWithFormat:@"%@Enabled", [LGAppDataFeed keyForDataFeedType:dataFeedType]] retain];
    
    if (![defaults objectForKey:key]) {
        retVal = NO;
    } else {
        retVal = [[defaults objectForKey:key] boolValue];
    }
    
    [defaults release];
    [key release];
    return retVal;
}

+ (void)setDataFeedType:(LGDataFeedType)dataFeedType Enabled:(BOOL)enabled
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"setDataFeedType:Enabled:"];
    
    if (![LGAppDataFeed isUnlockedDataFeedType:dataFeedType]) {
        enabled = NO;
    }
    
    
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
    NSString *key = [[NSString stringWithFormat:@"%@Enabled", [LGAppDataFeed keyForDataFeedType:dataFeedType]] retain];
    
    [defaults setObject:[NSNumber numberWithBool:enabled] forKey:key];
    [defaults synchronize];
    [defaults release];
    [key release];
}


+ (NSDate *)purchaseDateForDataFeedType:(LGDataFeedType)dataFeedType
{
   if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"purchaseDateForDataFeedType"];
    
    NSDate *retVal = nil;
    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
    
    retVal = (NSDate *)[defaults objectForKey:[LGAppDataFeed keyForDataFeedType:dataFeedType]];
    
    [defaults release];
    return retVal;
}
+ (NSString *)purchaseDateForDataFeedTypeAsLocalizedString:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"purchaseDateForDataFeedTypeAsLocalizedString:"];

    return [[NSDateFormatter localizedStringFromDate:[LGAppDataFeed purchaseDateForDataFeedType:dataFeedType] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle] copy];
}

+ (void)setCartForDataFeedType:(LGDataFeedType)dataFeedType Quantity:(NSInteger)quantity
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"setCartForDataFeedType"];

    NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
    NSString *cartKey = [[NSString stringWithFormat:@"Cart%@", [LGAppDataFeed keyForDataFeedType:dataFeedType]] retain];
    
    [defaults setObject:[NSNumber numberWithInt:quantity] forKey:cartKey];
    [defaults synchronize];
    
    [defaults release];
    [cartKey release];
    
}
+ (void)initShoppingCart
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"initShoppingCart"];

    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeAddressBook];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeBeacon];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeCalendar];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeFaceBookFriend];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeFaceBookCheckin];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeFaceBookPlace];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeFourSquare];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeGooglePlaces];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeGooglePlus];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeGowalla];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeGroupon];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeJive];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeLinkedIn];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeLOCKERZ];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeMySpace];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeOutlook];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeSkype];
    [LGAppDataFeed removeFromCartDataFeedType:LGDataFeedTypeTwitter];

}

+ (void)addToCartDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"addToCartDataFeedType"];

    if ([LGAppDataFeed isUnlockedDataFeedType:dataFeedType]) return;
    else {
        [LGAppDataFeed setCartForDataFeedType:dataFeedType Quantity:1];
    }
    
}
+ (void)removeFromCartDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"removeFromCartDataFeedType"];

    [LGAppDataFeed setCartForDataFeedType:dataFeedType Quantity:0];
    
}
+ (NSInteger)getCartQtyForDataFeedType:(LGDataFeedType)dataFeedType
{
    
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"getCartQtyForDataFeedType"];
    
    if ([LGAppDataFeed isUnlockedDataFeedType:dataFeedType]) return 0;
    else {
        NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
        NSString *cartKey = [[NSString stringWithFormat:@"Cart%@", [LGAppDataFeed keyForDataFeedType:dataFeedType]] retain];
        NSInteger i = 0;
        
        if ([defaults objectForKey:cartKey]) i = [(NSNumber *)[defaults objectForKey:cartKey] integerValue];
        
        [defaults release];
        [cartKey release];
        return i;
    }
    
}

+ (NSInteger)getCartQtyTotal
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"getCartQtyTotal"];
    NSInteger i = 0;
    
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeAddressBook];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeBeacon];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeCalendar];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFaceBookFriend];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFaceBookCheckin];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFaceBookPlace];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFourSquare];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGooglePlaces];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGooglePlus];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGowalla];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGroupon];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeJive];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeLinkedIn];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeLOCKERZ];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeMySpace];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeOutlook];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeSkype];
    i += [LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeTwitter];
    
    return i;
}

+ (NSMutableArray *)getCartMutableArray
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"getCartMutableArray"];

    NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
    
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeAddressBook] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeAddressBook]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeBeacon] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeBeacon]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeCalendar] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeCalendar]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFaceBookFriend] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFaceBookFriend]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFaceBookCheckin] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFaceBookCheckin]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFaceBookPlace] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFaceBookPlace]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeFourSquare] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFourSquare]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGooglePlaces] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGooglePlaces]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGooglePlus] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGooglePlus]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGowalla] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGowalla]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeGroupon] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGroupon]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeJive] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeJive]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeLinkedIn] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeLinkedIn]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeLOCKERZ] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeLOCKERZ]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeMySpace] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeMySpace]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeOutlook] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeOutlook]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeSkype] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeSkype]];
    if ([LGAppDataFeed getCartQtyForDataFeedType:LGDataFeedTypeTwitter] > 0) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeTwitter]];
    
    return arr;
}

+ (NSMutableArray *)getUnlockedDataFeedsMutableArray
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"getUnlockedDataFeedsMutableArray"];
    
    NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
    
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeAddressBook]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeAddressBook]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeBeacon]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeBeacon]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeCalendar]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeCalendar]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFaceBookFriend]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFaceBookFriend]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFaceBookCheckin]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFaceBookCheckin]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFaceBookPlace]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFaceBookPlace]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFourSquare]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeFourSquare]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeGooglePlaces]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGooglePlaces]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeGooglePlus]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGooglePlus]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeGowalla]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGowalla]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeGroupon]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeGroupon]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeJive]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeJive]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeLinkedIn]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeLinkedIn]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeLOCKERZ]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeLOCKERZ]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeMySpace]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeMySpace]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeOutlook]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeOutlook]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeSkype]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeSkype]];
    if ([LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeTwitter]) [arr addObject:[NSNumber numberWithInt:LGDataFeedTypeTwitter]];
    
    return arr;
}

+ (NSString *)nameForDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"nameForDataFeedType"];

    switch (dataFeedType)
    {
        case LGDataFeedTypeAddressBook: return @"Address Book";
        case LGDataFeedTypeBeacon: return @"Beacon";
        case LGDataFeedTypeCalendar: return @"Calendar";
        case LGDataFeedTypeFaceBookFriend: return @"Facebook Friend";
        case LGDataFeedTypeFaceBookCheckin: return @"Facebook Checkin";
        case LGDataFeedTypeFaceBookPlace: return @"Facebook Places";
        case LGDataFeedTypeFourSquare: return @"Four Square";             
        case LGDataFeedTypeGooglePlus: return @"Google Plus";
        case LGDataFeedTypeGooglePlaces: return @"Google Places";
        case LGDataFeedTypeGowalla: return @"Gowalla";
        case LGDataFeedTypeGroupon: return @"Groupon";
        case LGDataFeedTypeJive: return @"Jive";
        case LGDataFeedTypeLinkedIn: return @"LinkedIn";
        case LGDataFeedTypeLOCKERZ: return @"LOCKERZ";
        case LGDataFeedTypeMySpace: return @"MySpace";
        case LGDataFeedTypeOutlook: return @"MS Outlook";
        case LGDataFeedTypeSkype: return @"Skype";
        case LGDataFeedTypeTwitter: return @"Twitter";
    }
    
    NSLog(@"nameForDataFeedType: internal error with DataFeedType: %d", dataFeedType);
    
}

+ (NSString *)keyForDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"keyForDataFeedType"];

    NSString *s = [[NSString  stringWithFormat:@"%@TokenKey", [LGAppDataFeed nameForDataFeedType:dataFeedType]] retain];
    
    NSString *key = [s stringByReplacingOccurrencesOfString:@" " withString:@""];
    [s release]; 
    
    return key;
}

+ (UIImage *)imageForDataFeedTypeLarge:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"imageForDataFeedTypeLarge"];

    switch (dataFeedType)
    {
        case LGDataFeedTypeBeacon: return [UIImage imageNamed:@"LGDataFeedImageLarge_Beacon"];
        case LGDataFeedTypeAddressBook: return [UIImage imageNamed:@"LGDataFeedImageLarge_Addressbook"];
        case LGDataFeedTypeCalendar: return [UIImage imageNamed:@"LGDataFeedImageLarge_Calendar"];
        case LGDataFeedTypeFaceBookFriend: return [UIImage imageNamed:@"LGDataFeedImageLarge_Facebook"];
        case LGDataFeedTypeFaceBookCheckin: return [UIImage imageNamed:@"LGDataFeedImageLarge_Facebook"];
        case LGDataFeedTypeFaceBookPlace: return [UIImage imageNamed:@"LGDataFeedImageLarge_Facebook"];
        case LGDataFeedTypeFourSquare: return [UIImage imageNamed:@"LGDataFeedImageLarge_Foursquare"];
        case LGDataFeedTypeGooglePlaces: return [UIImage imageNamed:@"LGDataFeedImageLarge_GooglePlus"];
        case LGDataFeedTypeGooglePlus: return [UIImage imageNamed:@"LGDataFeedImageLarge_GooglePlus"];
        case LGDataFeedTypeGowalla: return [UIImage imageNamed:@"LGDataFeedImageLarge_Gowalla"];
        case LGDataFeedTypeGroupon: return [UIImage imageNamed:@"LGDataFeedImageLarge_Groupon"];
        case LGDataFeedTypeJive: return [UIImage imageNamed:@"LGDataFeedImageLarge_Jive"];
        case LGDataFeedTypeLinkedIn: return [UIImage imageNamed:@"LGDataFeedImageLarge_Linkedin"];
        case LGDataFeedTypeLOCKERZ: return [UIImage imageNamed:@"LGDataFeedImageLarge_Lockerz"];
        case LGDataFeedTypeMySpace: return [UIImage imageNamed:@"LGDataFeedImageLarge_MySpace"];
        case LGDataFeedTypeOutlook: return [UIImage imageNamed:@"LGDataFeedImageLarge_Outlook"];
        case LGDataFeedTypeSkype: return [UIImage imageNamed:@"LGDataFeedImageLarge_Skype"];
        case LGDataFeedTypeTwitter: return [UIImage imageNamed:@"LGDataFeedImageLarge_Twitter"];
    }
    return nil;
}

+ (UIImage *)imageForDataFeedTypeSmall:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"imageForDataFeedTypeSmall"];

    switch (dataFeedType)
    {
        case LGDataFeedTypeBeacon: return [UIImage imageNamed:@""];
        case LGDataFeedTypeAddressBook: return [UIImage imageNamed:@""];
        case LGDataFeedTypeCalendar: return [UIImage imageNamed:@""];
        case LGDataFeedTypeFaceBookFriend: return [UIImage imageNamed:@"LGDataFeedImageSmall_Facebook"];
        case LGDataFeedTypeFaceBookCheckin: return [UIImage imageNamed:@"LGDataFeedImageSmall_Facebook"];
        case LGDataFeedTypeFaceBookPlace: return [UIImage imageNamed:@"LGDataFeedImageSmall_Facebook"];
        case LGDataFeedTypeFourSquare: return [UIImage imageNamed:@""];
        case LGDataFeedTypeGooglePlaces: return [UIImage imageNamed:@""];
        case LGDataFeedTypeGooglePlus: return [UIImage imageNamed:@""];
        case LGDataFeedTypeGowalla: return [UIImage imageNamed:@""];
        case LGDataFeedTypeGroupon: return [UIImage imageNamed:@""];
        case LGDataFeedTypeJive: return [UIImage imageNamed:@""];
        case LGDataFeedTypeLinkedIn: return [UIImage imageNamed:@"LGDataFeedImageSmall_Linkedin"];
        case LGDataFeedTypeLOCKERZ: return [UIImage imageNamed:@""];
        case LGDataFeedTypeMySpace: return [UIImage imageNamed:@""];
        case LGDataFeedTypeOutlook: return [UIImage imageNamed:@""];
        case LGDataFeedTypeSkype: return [UIImage imageNamed:@""];
        case LGDataFeedTypeTwitter: return [UIImage imageNamed:@""];
    }
    return nil;
}

+ (UIImage *)imageForDataFeedTypeFormatted:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"imageForDataFeedTypeFormatted:"];

    UIImage *image = [LGAppDataFeed imageForDataFeedTypeLarge:dataFeedType];
    
    return [LGAppDataFeed Image:image Pixels:25];
}

+ (UIImage *)Image:(UIImage *)image Pixels:(float)px
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"Image:Pixels"];

    // Resize, crop the image to make sure it is square and renders well on Retina display
    float ratio;
    float delta;
    CGPoint offset;
    CGSize size = image.size;
    if (size.width > size.height) {
        ratio   = px / size.width;
        delta   = (ratio * size.width - ratio * size.height);
        offset  = CGPointMake(delta / 2, 0);
    } else {
        ratio   = px / size.height;
        delta   = (ratio * size.height - ratio * size.width);
        offset  = CGPointMake(0, delta / 2);
    }
    CGRect clipRect = CGRectMake(-offset.x, -offset.y, (ratio * size.width) + delta, (ratio * size.height) + delta);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(px, px), YES, 1.0);
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (CGFloat)priceForDataFeedType:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"priceForDataFeedType:"];

    NSString *s = [NSString stringWithFormat:@"Price_%@", [LGAppDataFeed nameForDataFeedType:dataFeedType]];

    return [NSLocalizedString(s, @"localized product price") floatValue];
}

+ (NSString *)priceForDataFeedTypeAsLocalizedString:(LGDataFeedType)dataFeedType
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"priceForDataFeedTypeAsLocalizedString:"];

    
    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
    //Price_Free
    CGFloat price = [LGAppDataFeed priceForDataFeedType:dataFeedType];
    NSString *formatted = nil;
    
    if (price > 0.0f) formatted = [currencyStyle stringFromNumber:[NSNumber numberWithFloat:price]];
    else formatted = NSLocalizedString(@"Price_Free", @"Free");
    
    [currencyStyle release];
    
    return formatted;
}

+ (NSString *)priceTextForDataFeedTypeAsLocalizedString:(LGDataFeedType)dataFeedType
{
    [self logObjectVariables:@"buyButtonTextForDataFeedTypeId()"];
    
    if ([LGAppDataFeed isUnlockedDataFeedType:dataFeedType]) {
        NSString *format = NSLocalizedString(@"buyButtonText_Purchased", @"Purchased %1$@");
        return [NSString stringWithFormat:format, [LGAppDataFeed purchaseDateForDataFeedTypeAsLocalizedString:dataFeedType]];
    }
    
    if ([LGAppDataFeed priceForDataFeedType:dataFeedType] == 0) {
        NSString *format = NSLocalizedString(@"buyButtonText_Free", @"Connect to %1$@");
        return [NSString stringWithFormat:format, [LGAppDataFeed nameForDataFeedType:dataFeedType]];
        
    } else {
        NSString *format = NSLocalizedString(@"buyButtonText_Premium", @"Add To Cart For Only %1$@");
        return [NSString stringWithFormat:format, [LGAppDataFeed priceForDataFeedTypeAsLocalizedString:dataFeedType]];
    }
}


+ (CGFloat)getCartCostTotal
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"getCartCostTotal"];

    NSMutableArray *products = [LGAppDataFeed getCartMutableArray];
    CGFloat total = 0;
    
    for (NSNumber *product in products) {
        
        total += [LGAppDataFeed priceForDataFeedType:[product integerValue]];
    
    }
    
    return total;
}
+ (NSString *)getCartCostTotalAsLocalizedString
{
    if (OBJECT_DEBUG) [LGAppDataFeed logObjectVariables:@"getCartCostTotalAsLocalizedString"];

    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSString *formatted = [currencyStyle stringFromNumber:[NSNumber numberWithFloat:[LGAppDataFeed getCartCostTotal]]];
    
    [currencyStyle release];
    
    return formatted;

}

#pragma mark - Object Lifecycle

- (LGAppDataFeed *)initWithDataFeedType:(LGDataFeedType)thisDataFeedType
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithDataFeedType:"];

    if (![LGAppDataFeed isUnlockedDataFeedType:thisDataFeedType]) {
        NSLog(@"LGAppDataFeed.initWithDataFeedType() internal error: locked datafeedtype %@ tried to instantiate itself.", [LGAppDataFeed nameForDataFeedType:thisDataFeedType]);
        return nil;
    }
    
    if (self = [super init]) {
        [self logObjectVariables:@"init()"];
        self.dataFeedType = thisDataFeedType;
        _didCancelRequest = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc"];
    [self cancelRequest];
    
    if (appDelegate) {
        [appDelegate release];
        appDelegate = nil;
    }
    
    if (managedObjectContext) {
        [managedObjectContext release];
        managedObjectContext = nil;
    }
     
    [progressView release];
    
    if (getPeopleTimeStamp) {
        [getPeopleTimeStamp release];
        getPeopleTimeStamp = nil;
    }
    if (getPeopleNextTime) {
        [getPeopleNextTime release];
        getPeopleNextTime = nil;
    }
    if (fromLocation) {
        [fromLocation release];
        fromLocation = nil;
    }
    if (checkinListPerson_id) {
        [checkinListPerson_id release];
        checkinListPerson_id = nil;
    }
    [super dealloc];
}


#pragma mark - API methods
- (void)EnableDataFeed
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"EnableDataFeed"];

    if (![LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType]) return;
    [LGAppDataFeed setDataFeedType:self.dataFeedType Enabled:YES];
    [self setGetPeopleTimeStamp:[NSDate distantPast]];
}

- (void)DisableDataFeed
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"DisableDataFeed"];
    
    [self setBusy:YES];
    [LGAppDataFeed setDataFeedType:self.dataFeedType Enabled:NO];
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("my queue", NULL);
    dispatch_barrier_async(myQueue, ^
                           {
                               [self.appDelegate.managedObjectContext lock];
                               
                               [Attendee removeAllObjectsForDataFeedType:self.dataFeedType ProgressView:self.progressView FromManagedObjectContext:self.managedObjectContext];
                               [Checkin removeAllObjectsForDataFeedType:self.dataFeedType ProgressView:self.progressView FromManagedObjectContext:self.managedObjectContext];
                               [MapItem removeAllObjectsForDataFeedType:self.dataFeedType ProgressView:self.progressView FromManagedObjectContext:self.managedObjectContext];
                               [Person removeAllObjectsForDataFeedType:self.dataFeedType ProgressView:self.progressView FromManagedObjectContext:self.managedObjectContext];
                               
                               [self.appDelegate.managedObjectContext unlock];
                               
                           }
                           );
    dispatch_release(myQueue);
    
}

- (BOOL)getPeoplewithCycleTest:(BOOL)test
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"getPeoplewithCycleTest:"];
    if (!self.canProcessRequest) return NO;

    if (test) {
        NSDate *now = [NSDate date];
        if ([now earlierDate:self.getPeopleNextTime] == now) return NO;
        
        
    }

    return YES;

}
- (BOOL)getCheckinsForPersonId:(NSString *)person_id withCycleTest:(BOOL)test
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"getCheckinsForPersonId:withCycleTest"];
    if (!self.canProcessRequest) return NO;
    
    if (test) {
        
    }

    return YES;
}
- (BOOL)getPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location withCycleTest:(BOOL)test
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"getPlacesWithinDistance:fromLocation:withCycleTest"];
    if (!self.canProcessRequest) return NO;
    if (test) {
        
    }
    
    return YES;
}


- (void)didGetPeople
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"didGetPeople"];
    
}
- (void)didGetCheckinsForPersonId:(NSString *)person_id
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"didGetCheckinsForPersonId"];
    
}
- (void)didGetPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"didGetPlacesWithinDistance:fromLocation"];

    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(didGetPlacesWithinDistance:fromLocation:)]) {
            
            [self.delegate didGetPlacesWithinDistance:fromDistance fromLocation:fromLocation];
            
        }
    }

}


@end







