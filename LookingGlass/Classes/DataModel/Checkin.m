//
//  Checkin.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Checkin.h"
#import "Attendee.h"
#import "MapItem.h"
#import "Person.h"


@implementation Checkin

@synthesize checkinOwnerName;
@synthesize checkinPlace;
@synthesize checkinDateString;
@synthesize distancefromlastlocation;

@dynamic application_name;
@dynamic comment;
@dynamic create_date;
@dynamic checkin_Mapitem;
@dynamic checkin_Attendee;
@dynamic checkin_Person;


#pragma mark - Setters and Getters
- (NSInteger)distancefromlastlocation
{
    return [self.checkin_Mapitem.distancefromlastlocation integerValue];
}

- (NSString *)tableCellTitle {
    return self.checkinPlace;
}
- (NSString *)tableCellSubTitle {
    if (self.dataFeedType == LGDataFeedTypeFaceBookFriend || self.dataFeedType == LGDataFeedTypeLinkedIn || self.dataFeedType == LGDataFeedTypeAddressBook) {
        return [LGAppDataFeed nameForDataFeedType:self.dataFeedType];
    }
    return self.checkinDateString;
}
- (LGMapItemGeocodeAccuracy)geocodeAccuracy
{
    if (self.checkin_Mapitem) return self.checkin_Mapitem.geocodeAccuracy;
    return LGMapItemGeocodeAccuracy_None;
    
}

- (NSString *)checkinPlace
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"checkinPlace()"];
    if (!checkinPlace) {
        if (!self.checkin_Mapitem) return nil;
        if (!self.checkin_Mapitem.title) return nil;
        checkinPlace = [self.checkin_Mapitem.title copy];
    }
    return checkinPlace;
}

- (NSString *)checkinOwnerName
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"ownerName()"];
    if (!checkinOwnerName) {
        if (!self.checkin_Person) return nil;
        if (!self.checkin_Person.name) return nil;
        checkinOwnerName = [self.checkin_Person.name copy];
    }
    return checkinOwnerName;
}


- (NSString *)checkinDateString
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"checkinDateString()"];
    if (!checkinDateString && self.create_date) {
        checkinDateString = [[NSDateFormatter localizedStringFromDate:self.create_date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle] copy];
        if (!checkinDateString) checkinDateString = NSLocalizedString(@"checkin_NoDate", @"(No Date)");
    }
    return checkinDateString;
}


+ (NSString *)titleForId:(NSString *)checkin_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"titleForId()"];

    NSFetchRequest *request     = [[NSFetchRequest alloc] init];
	request.entity              = [NSEntityDescription entityForName:@"Checkin" inManagedObjectContext:context];
	request.predicate           = [NSPredicate predicateWithFormat:@"unique_id = %@", [checkin_id copy]];
    request.fetchLimit          = 1;
	
	NSError *error              = nil;
    [context lock];
	NSArray *arr                = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    Checkin *checkin            = [[arr lastObject] retain];
	[request release];
    [arr release];

    request             = [[NSFetchRequest alloc] init];
	request.entity      = [NSEntityDescription entityForName:@"MapItem" inManagedObjectContext:context];
	request.predicate   = [NSPredicate predicateWithFormat:@"MapItem = %@", checkin.checkin_Mapitem];
    request.fetchLimit      = 1;
	error = nil;
    
    [context lock];
    NSArray *arr2    = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    MapItem *mapItem  = [arr2 lastObject];
	[request release];
    [checkin release];
    [arr2 release];
    
    return [mapItem.title copy];
}

+ (Checkin *)initWithCheckInId:(NSString *)checkin_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithCheckInId:inManagedObjectContext()"];

    Checkin *checkin = nil;
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Checkin" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"unique_id = %@", checkin_id];
    request.fetchLimit      = 1;

	NSError *error = nil;
	NSArray *arr = [[[context executeFetchRequest:request error:&error] copy] retain];  // <-- NOTE, the request actually should return exactly 1 record
    checkin      = [arr lastObject];
	[request release];
    [arr release];
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithCheckInId()"];
    return checkin;
}

+ (void)removeForCheckInId:(NSString *)checkin_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"removeForCheckInId()"];

    Checkin *obj = [Checkin initWithCheckInId:checkin_id inManagedObjectContext:context];
    if (obj) {
        [context deleteObject:obj];
    }

}

- (void)dealloc 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    if (checkinPlace) {
        [checkinPlace release];
        checkinPlace = nil;
    }
    if (checkinOwnerName) {
        [checkinOwnerName release];
        checkinOwnerName = nil;
    }
    if (checkinDateString) {
        [checkinDateString release];
        checkinDateString = nil;
    }
    
    [super dealloc];
}

+ (void)removeAllObjectsForDataFeedType:(LGDataFeedType)dataFeedType 
                           ProgressView:(UIProgressView *)progressView 
               FromManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"removeAllObjectsForDataFeedType:FromManagedObjectContext()"];

    NSFetchRequest *request = [[[NSFetchRequest alloc] init] retain];
	NSError *error = nil;
    
	request.entity          = [NSEntityDescription entityForName:@"Checkin" inManagedObjectContext:context];
    request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id == %d", dataFeedType];
    
    [context lock];
    NSArray *arr            = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    
    CGFloat i = arr.count;
    CGFloat results = i;
    
	for (Checkin *obj in arr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressView setProgress: i / results animated:YES];
        });
        i --;

        [Checkin removeForCheckInId:obj.unique_id inManagedObjectContext:context];
    }
	[request release];
    [arr release];
    [context save:&error];

}

@end
