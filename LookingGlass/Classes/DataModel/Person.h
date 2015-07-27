//
//  Person.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGDataModelObject.h"

@class Attendee, Checkin, MapItem;

@interface Person : LGDataModelObject <LGDataModelObject>

@property (nonatomic, readonly) NSString *firstLetterOfName;


// dynamic properties
@property (nonatomic, retain) NSNumber * distancefromlastlocation;      //Looking Glass
@property (nonatomic, copy) NSString *title;                            //LinkedIn
@property (nonatomic, copy) NSString * name;
@property (nonatomic) BOOL isfacebookfriend;
@property (nonatomic, retain) NSSet *person_Attendee;
@property (nonatomic, retain) NSSet *person_Checkin;

//additional facebook standard user info properties
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *locale;
@property (nonatomic, retain) NSNumber *timezone;
@property (nonatomic, copy) NSString *current_location;
@property (nonatomic, copy) NSString *middle_name;
@property (nonatomic, copy) NSString *hometown_location;
@property (nonatomic, retain) NSNumber *profile_update_time;

- (void)requestPlaces;

+ (Person *)initInManagedContext:(NSManagedObjectContext *)thisContext;
+ (Person *)initWithPersonId:(NSString *)thisPerson_id inManagedObjectContext:(NSManagedObjectContext *)thisContext;
+ (void)removeForPersonId:(NSString *)thisPerson_id inManagedObjectContext:(NSManagedObjectContext *)thisContext;

+ (NSString *)nameForID:(NSString *)person_id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)refreshAllPeopleInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)updateDistanceFromLastLocationTo:(NSInteger)distance ForPerson:(NSString *)unique_id InManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)initializeDistanceFromLastLocationInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSInteger)recordsForDataFeedType:(LGDataFeedType)dataFeedType
             InManagedObjectContext:(NSManagedObjectContext *)context;


@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addPerson_AttendeeObject:(Attendee *)value;
- (void)removePerson_AttendeeObject:(Attendee *)value;
- (void)addPerson_Attendee:(NSSet *)values;
- (void)removePerson_Attendee:(NSSet *)values;

- (void)addPerson_CheckinObject:(Checkin *)value;
- (void)removePerson_CheckinObject:(Checkin *)value;
- (void)addPerson_Checkin:(NSSet *)values;
- (void)removePerson_Checkin:(NSSet *)values;
@end


