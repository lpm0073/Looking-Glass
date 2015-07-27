//
//  Attendee.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Attendee.h"
#import "Checkin.h"
#import "Person.h"


@implementation Attendee

@synthesize person_name;

//@dynamic attendee_id;
@dynamic attendee_Checkin;
@dynamic attendee_Person;


-(NSString *)person_name
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"person_name()"];
    if (!person_name) {
        if (!self.attendee_Person) return nil;
        if (!self.attendee_Person.name) return nil;
        person_name = [self.attendee_Person.name copy];
    }
    return person_name;
}


- (void)awakeFromFetch
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"awakeFromFetch()"];
    
    self.tableCellTitle = self.attendee_Person.name;
}

+ (Attendee *)initWithAttendeeId:(NSString *)thisAttendee_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithAttendeeId:inManagedObjectContext()"];

    Attendee *attendee = nil;
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"attendee_id = %@", [thisAttendee_id copy]];
    request.fetchLimit      = 1;

	
	NSError *error = nil;
	NSArray *arr = [[[context executeFetchRequest:request error:&error] copy] retain];  
    attendee = [arr lastObject];
	[request release];
    [arr release];
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"initWithAttendeeId()"];
    return attendee;
}

+ (void)removeForAttendeeId:(NSString *)attendee_id inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"removeForAttendeeId()"];

    Attendee *obj = [Attendee initWithAttendeeId:attendee_id inManagedObjectContext:context];
    if (obj) {
        [context deleteObject:obj];
    }
}

- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    if (person_name) {
        [person_name release];
        person_name = nil;
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
    
	request.entity          = [NSEntityDescription entityForName:@"Attendee" inManagedObjectContext:context];
    request.predicate       = [NSPredicate predicateWithFormat:@"datafeedtype_id == %d", dataFeedType];
    
    [context lock];
    NSArray *arr            = [[[context executeFetchRequest:request error:&error] copy] retain];
    [context unlock];
    
    CGFloat i = (CGFloat)arr.count;
    CGFloat results = i;
    
	for (Attendee *obj in arr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressView setProgress: i / results animated:YES];
        });
        i --;
        
        [Attendee removeForAttendeeId:obj.unique_id inManagedObjectContext:context];
    }
	[request release];
    [arr release];
    [context save:&error];
}
@end
