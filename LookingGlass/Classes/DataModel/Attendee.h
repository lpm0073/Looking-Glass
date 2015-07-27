//
//  Attendee.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGDataModelObject.h"

@class Checkin, Person;

@interface Attendee : LGDataModelObject <LGDataModelObject>
{
}

@property (nonatomic, readonly) NSString *person_name;

//core data dynamic properties
//@property (nonatomic, copy) NSString * attendee_id;
@property (nonatomic, retain) Checkin *attendee_Checkin;
@property (nonatomic, retain) Person *attendee_Person;

+ (Attendee *)initWithAttendeeId:(NSString *)thisAttendee_id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)removeForAttendeeId:(NSString *)attendee_id inManagedObjectContext:(NSManagedObjectContext *)context;

@end
