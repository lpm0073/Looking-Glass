//
//  Checkin.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGDataModelObject.h"

@class Attendee, MapItem, Person;

@interface Checkin : LGDataModelObject <LGDataModelObject>
{
    
}

@property (nonatomic, readonly, copy) NSString *checkinOwnerName;
@property (nonatomic, readonly, copy) NSString *checkinPlace;
@property (nonatomic, readonly, copy) NSString *checkinDateString;
@property (nonatomic, readonly) NSInteger distancefromlastlocation;


//core data dynamic properties
@property (nonatomic, copy) NSString * application_name;
@property (nonatomic, copy) NSString * comment;
@property (nonatomic, retain) NSDate * create_date;

@property (nonatomic, retain) MapItem *checkin_Mapitem;
@property (nonatomic, retain) NSSet *checkin_Attendee;
@property (nonatomic, retain) Person *checkin_Person;



+ (Checkin *)initWithCheckInId:(NSString *)checkin_id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)removeForCheckInId:(NSString *)checkin_id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSString *)titleForId:(NSString *)checkin_id inManagedObjectContext:(NSManagedObjectContext *)context;


@end

@interface Checkin (CoreDataGeneratedAccessors)

- (void)addCheckin_AttendeeObject:(Attendee *)value;
- (void)removeCheckin_AttendeeObject:(Attendee *)value;
- (void)addCheckin_Attendee:(NSSet *)values;
- (void)removeCheckin_Attendee:(NSSet *)values;

@end
