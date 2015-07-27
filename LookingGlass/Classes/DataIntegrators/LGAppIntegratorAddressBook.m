//
//  LGAppIntegratorAddressBook.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGAppIntegratorAddressBook.h"
#import "Person.h"
#import "MapItem.h"
#import "Attendee.h"
#import "Checkin.h"

#define kIMPORT_BATCH_LIMIT 200

@interface LGAppIntegratorAddressBook()
{
}

@end
@implementation LGAppIntegratorAddressBook

+(NSDictionary *)addressDictionaryForID:(NSString *)person_id atIndex:(CFIndex)addressIndex
  {
      ABRecordRef person      = ABAddressBookGetPersonWithRecordID(ABAddressBookCreate(), [person_id intValue] );
      ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
      
      return ABMultiValueCopyValueAtIndex(address, addressIndex);
  }

+(NSDictionary *)addressDictionaryForID:(NSString *)person_id
{
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(ABAddressBookCreate(), [person_id intValue] );
    if (ABMultiValueGetCount(ABRecordCopyValue(person, kABPersonAddressProperty)) > 0) {
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        
        return ABMultiValueCopyValueAtIndex(address, 0);
    }
    return nil;
}



-(BOOL)getCheckinsForPersonId:(NSString *)person_id withCycleTest:(BOOL)test
{
    if (!self.canProcessRequest) return NO;
    if ([super getCheckinsForPersonId:person_id withCycleTest:test]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"getCheckinsForPersonId()"];
        
        return YES;
    }
    return NO;    
}

-(BOOL)getPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location withCycleTest:(BOOL)test
{
    if (!self.canProcessRequest) return NO;
    if ([super getPlacesWithinDistance:distance fromLocation:location withCycleTest:test]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"getPlacesWithinDistance:fromLocation:withCycleTest()"];

        return YES;
    }
    return NO;
}

-(void)getPeople
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"getPeople()"];
    if (!self.canProcessRequest) return;
    
    NSInteger iBatchCount = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *allPeople           = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) retain];
    float results                = allPeople.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setBusy:YES];
    });

    for (NSUInteger i = 0; i < allPeople.count; i++) {
        if (!self.didCancelRequest) {
            

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress: (float)i / results animated:YES];
            });


            //NSLog(@"getPeople() - progress: %f", (float)i / results);
            
            ABRecordRef person           = (ABRecordRef)[allPeople objectAtIndex:i];
            
            NSString *person_id          = [[[NSNumber numberWithInt:ABRecordGetRecordID(person)] stringValue] copy];
            NSString *nameFirst          = [(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) copy];
            NSString *nameLast           = [(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) copy];
            NSDate   *modificationDate   = [(NSDate *)ABRecordCopyValue(person, kABPersonModificationDateProperty) retain];
            Person *thisPerson;
            
            if (![self existsPersonForPersonID:person_id] || ([modificationDate laterDate:self.getPeopleTimeStamp] == modificationDate)) {
                if (OBJECT_DEBUG) NSLog(@"ABRecordGetRecordID(%d): %@ - %@ %@", i, person_id, nameFirst, nameLast);
                
                if (nameFirst || nameLast) {  
                    ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
                    
                    if (ABMultiValueGetCount(address) > 0) {
                        iBatchCount++;
                        
                        //see Core Data Programming Guide page 152 for details on this pattern. this is intended to reduce the memory footprint of large imports
                        if (iBatchCount == kIMPORT_BATCH_LIMIT) {
                            [self.appDelegate saveContext];
                            
                            [pool drain];
                            pool = [[NSAutoreleasePool alloc] init];
                            
                            iBatchCount = 0;
                        }
                        
                        //==============================================================================================
                        // Person
                        //==============================================================================================
                        thisPerson                  = [[self PersonForPersonID:person_id] retain];
                        thisPerson.datafeedtype_id  = [NSNumber numberWithInt:self.dataFeedType];
                        thisPerson.isfacebookfriend = NO;
                        thisPerson.first_name       = nameFirst;
                        thisPerson.last_name        = nameLast;
                        thisPerson.name             = [NSString stringWithFormat:@"%@ %@", nameFirst, nameLast];
                        thisPerson.timestamp        = modificationDate;
                        thisPerson.tableCellTitle   = thisPerson.name;
                        thisPerson.tableCellSubTitle = [LGAppDataFeed nameForDataFeedType:self.dataFeedType];
                        
                        for (CFIndex j = 0; j < ABMultiValueGetCount(address); j++) {
                            CFDictionaryRef dict       = ABMultiValueCopyValueAtIndex(address, j);
                            NSString * unique_id        = [[person_id stringByAppendingString:[[NSNumber numberWithInt:j] stringValue]] copy];
                            NSString * thisCity        = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressCityKey) copy];
                            NSString * thisState       = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressStateKey) copy];
                            
                            
                            if (thisCity || thisState) { 
                                NSString * thisStreet      = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressStreetKey) copy];
                                NSString * thisPostalCode  = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressZIPKey) copy];
                                NSString * thisCountry     = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressCountryKey) copy];
                                
                                NSString * thisAddressType = [(NSString *)ABMultiValueCopyLabelAtIndex(address, j) copy];
                                thisAddressType = [thisAddressType stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
                                thisAddressType = [thisAddressType stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
                                
                                
                                
                                //==============================================================================================
                                // MapItem
                                //==============================================================================================
                                MapItem *mapItem            = [[self MapItemForMapItemID:unique_id] retain];
                                mapItem.datafeedtype_id     = [NSNumber numberWithInt:self.dataFeedType];
                                mapItem.timestamp           = [NSDate date];
                                
                                mapItem.title               = [NSString stringWithFormat:@"%@ - %@", thisPerson.name, thisAddressType];
                                mapItem.city                = [thisCity uppercaseString];
                                mapItem.state               = [thisState uppercaseString];
                                mapItem.postalcode          = [thisPostalCode uppercaseString];
                                mapItem.street              = [thisStreet uppercaseString];
                                mapItem.country             = [thisCountry uppercaseString];
                                
                                mapItem.geocodeaccuracy     = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_None];
                                
                                //==============================================================================================
                                // Checkin
                                //==============================================================================================
                                Checkin *checkin          = [[self CheckinForCheckinID:unique_id] retain];
                                checkin.comment           = nil;
                                checkin.create_date       = modificationDate;
                                checkin.datafeedtype_id   = [NSNumber numberWithInt:self.dataFeedType];
                                
                                //relationships....
                                checkin.Checkin_Person    = thisPerson;        
                                checkin.Checkin_Mapitem   = mapItem;
                                
                                [checkin release];
                                [mapItem release];
                                 
                                //[thisStreet release];
                                //[thisPostalCode release];
                                //[thisCountry release];
                                //[thisAddressType release];
                                
                            } // if city/state
                             
                             
                            CFRelease(dict);
                            //[unique_id release];
                            //[thisCity release];
                            //[thisState release];
                        } //for CFIndex
                        
                        [thisPerson release];
                    } //if ABMultiValueGetCount(address)
                    CFRelease(address);
                    
                } // if nameFirst / nameLast
            } // exists person
            //[nameFirst release];
            //[nameLast release];
            //[person_id release];
            [modificationDate release];
            CFRelease(person);
            
        } else break;   // didCancelRequest
    }
    [allPeople release];
    
    //memory management stuff.
    [self.appDelegate saveContext];
    [pool drain];
    
    //CFRelease(addressBook);
    
    if (!self.didCancelRequest) {
        self.getPeopleTimeStamp = [NSDate date];        
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(didGetPeople)]) {
                [self.delegate didGetPeople];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:0];
        [self.progressView setHidden:YES];
        [self setBusy:NO];
    });

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


-(BOOL)getPeoplewithCycleTest:(BOOL)test {
    if ([super getPeoplewithCycleTest:test]) {
        
        if (OBJECT_DEBUG) [self logObjectVariables:@"getPeoplewithCycleTest()"];
        
        dispatch_queue_t myQueue = dispatch_queue_create("my queue", NULL);
        dispatch_barrier_async(myQueue, ^
        {
            [self.appDelegate.managedObjectContext lock];
            [self getPeople];
            [self.appDelegate.managedObjectContext unlock];

        });
        dispatch_release(myQueue);
        
        return YES;
    }
    return NO;
}

#pragma mark - object lifecycle

- (void)authorizeAddressBook
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"authorizeAddressBook()"];
    
}

- (LGAppIntegratorAddressBook *)init
{
    if (self = [super initWithDataFeedType:LGDataFeedTypeAddressBook]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"init()"];
        
        if (NO) {
            [self authorizeAddressBook];
        }

    }
    return self;
}

- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    [super dealloc];
}
@end
