//
//  LGAppDataFeed.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGAppDelegate.h"
#import <UIKit/UIKit.h>         // for progressView object


@protocol LGAppDataFeedDelegate;

@protocol LGAppDataFeed <NSObject>

- (BOOL)getPeoplewithCycleTest:(BOOL)test;
- (BOOL)getPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location withCycleTest:(BOOL)test;

@end


@interface LGAppDataFeed : NSObject

// Data Feed Common Properties
@property (nonatomic, retain, readonly) LGAppDelegate *appDelegate;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) id <LGAppDataFeedDelegate> delegate;
@property (nonatomic) LGDataFeedType dataFeedType;
@property (nonatomic, retain) UIProgressView *progressView;

// Interface session management
@property (readonly) BOOL canProcessRequest;
@property (retain) NSDate *getPeopleTimeStamp;
@property (nonatomic, retain, readonly) NSDate *getPeopleNextTime;
@property (retain) CLLocation *fromLocation;
@property () NSInteger fromDistance;
@property (copy) NSString *checkinListPerson_id;


//thread management
@property (readonly) BOOL isBusy;
- (void)setBusy:(BOOL)busy;

@property (readonly) BOOL didCancelRequest;
- (BOOL)cancelRequest;


// Shopping Cart Convenience Methods
+ (void)initShoppingCart;

+ (void)addToCartDataFeedType:(LGDataFeedType)dataFeedType;
+ (void)removeFromCartDataFeedType:(LGDataFeedType)dataFeedType;
+ (NSInteger)getCartQtyForDataFeedType:(LGDataFeedType)dataFeedType;
+ (NSInteger)getCartQtyTotal;
+ (CGFloat)getCartCostTotal;
+ (NSString *)getCartCostTotalAsLocalizedString;

+ (NSMutableArray *)getCartMutableArray;
+ (NSMutableArray *)getUnlockedDataFeedsMutableArray;

// Data Feed Type Convenience Methods
+ (BOOL)isUnlockedDataFeedType:(LGDataFeedType)dataFeedType;
+ (void)unlockDataFeedType:(LGDataFeedType)dataFeedType;
+ (BOOL)isEnabledDataFeedType:(LGDataFeedType)dataFeedType;
+ (void)setDataFeedType:(LGDataFeedType)dataFeedType Enabled:(BOOL)enabled;

+ (NSDate *)purchaseDateForDataFeedType:(LGDataFeedType)dataFeedType;
+ (NSString *)purchaseDateForDataFeedTypeAsLocalizedString:(LGDataFeedType)dataFeedType;
+ (NSString *)nameForDataFeedType:(LGDataFeedType)dataFeedType;
+ (NSString *)keyForDataFeedType:(LGDataFeedType)dataFeedType;

+ (UIImage *)imageForDataFeedTypeLarge:(LGDataFeedType)dataFeedType;
+ (UIImage *)imageForDataFeedTypeSmall:(LGDataFeedType)dataFeedType;
+ (UIImage *)imageForDataFeedTypeFormatted:(LGDataFeedType)dataFeedType;
+ (UIImage *)Image:(UIImage *)image Pixels:(float)px;

+ (CGFloat)priceForDataFeedType:(LGDataFeedType)dataFeedType;
+ (NSString *)priceForDataFeedTypeAsLocalizedString:(LGDataFeedType)dataFeedType;
+ (NSString *)priceTextForDataFeedTypeAsLocalizedString:(LGDataFeedType)dataFeedType;


//App Data Feed Utility Methods
- (BOOL)existsPersonForPersonID:(NSString *)unique_id;
- (BOOL)existsCheckinForCheckinID:(NSString *)unique_id;
- (BOOL)existsMapItemForMapItemID:(NSString *)unique_id;
- (BOOL)existsAttendeeForAttendeeId:(NSString *)unique_id;

- (id)PersonForPersonID:(NSString *)person_id;
- (id)CheckinForCheckinID:(NSString *)checkin_id;
- (id)MapItemForMapItemID:(NSString *)mapItem_id;
- (id)AttendeeForAttendeeId:(NSString *)attendee_id CheckinId:(NSString *)checkin_id PersonId:(NSString *)person_id;

- (BOOL)setTimestampForDataElement:(NSString *)suffix toDate:(NSDate *)date;
- (NSDate *)getTimestampForDataElement:(NSString *)suffix;


// API
- (void)logObjectVariables:(NSString *)suffix;

- (LGAppDataFeed *)initWithDataFeedType:(LGDataFeedType)dataFeedType;
- (void)EnableDataFeed;
- (void)DisableDataFeed;

- (BOOL)getPeoplewithCycleTest:(BOOL)test;
- (BOOL)getCheckinsForPersonId:(NSString *)person_id withCycleTest:(BOOL)test;
- (BOOL)getPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location withCycleTest:(BOOL)test;

- (void)didGetPeople;
- (void)didGetCheckinsForPersonId:(NSString *)person_id;
- (void)didGetPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location;

@end



@protocol LGAppDataFeedDelegate  <NSObject>

@optional
- (void)didGetPeople;
- (void)didGetCheckinsForPersonId:(NSString *)person_id;
- (void)didGetPlacesWithinDistance:(NSInteger)distance fromLocation:(CLLocation *)location;

@end

