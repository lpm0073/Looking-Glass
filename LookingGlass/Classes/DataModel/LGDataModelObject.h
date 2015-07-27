//
//  LGDataModelObject.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "LGAppIntegratorFacebook.h"
#import "LGAppIntegratorAddressBook.h"
#import "LGAppIntegratorLinkedIn.h"


@protocol LGDataModelManagedObjectDelegate;

@protocol LGDataModelObject <NSObject>

+ (void)removeAllObjectsForDataFeedType:(LGDataFeedType)dataFeedType 
                           ProgressView:(UIProgressView *)progressView
               FromManagedObjectContext:(NSManagedObjectContext *)context;

@end




@interface LGDataModelObject : NSManagedObject <LGAppDataFeedDelegate>
{
    id <LGDataModelManagedObjectDelegate> delegate;
}

@property (nonatomic, assign) id <LGDataModelManagedObjectDelegate> delegate; 
@property (nonatomic, readonly) LGDataFeedType dataFeedType;
@property (nonatomic, copy, readonly) NSString *dataFeedTypeName;
@property (nonatomic, retain, readonly) LGAppDelegate *appDelegate;
@property (nonatomic, retain, readonly) NSURL *applicationCacheDirectoryURL;


@property (nonatomic) NSInteger rowNumber;

@property (nonatomic, readonly) LGMapItemGeocodeAccuracy geocodeAccuracy;
@property (nonatomic, retain, readonly) UIImage *geocodeStatusImage;


//Data integrators
@property (nonatomic, retain, readonly) LGAppIntegratorFacebook *integratorFacebook;
@property (nonatomic, retain, readonly) LGAppIntegratorAddressBook *integratorAddressBook;
@property (nonatomic, retain, readonly) LGAppIntegratorLinkedIn *integratorLinkedIn;

//Common object properties
@property (nonatomic, readonly) NSString *firstLetterOfTitle;       //used with fetchresultscontroller section groups
@property (copy) NSString *tableCellSubTitle;
@property (copy) NSString *tableCellTitle;


@property (nonatomic, copy, readonly) NSString *thumbnailCachePath;
@property (nonatomic, retain, readonly) NSURL *thumbnailURL;
@property (retain) UIImage *thumbnailImage;


//required common datamodel properties
@property (nonatomic, copy) NSString *unique_id;
@property (nonatomic, copy) NSString *thumbnailurl;
@property (nonatomic, retain) NSNumber * datafeedtype_id;



//Thread Management
@property (readonly) BOOL canProcessRequest;
@property (readonly) BOOL isBusy;
@property (readonly) BOOL isCancelled;
- (BOOL)cancelAllRequests;
- (void)setBusy:(BOOL)busy;
- (void)reset;
- (void)resetIntegrators;

//public API
- (void)logObjectVariables:(NSString *)suffix;
+ (void)logObjectVariables:(NSString *)suffix;
- (void)doHousekeeping;
- (void)requestThumbnail;
- (void)resetGeocodeStatusImage;


@end


@protocol LGDataModelManagedObjectDelegate  <NSObject>

@optional
//called when a profile pic has been successfully downloaded.
- (void)thumbnailImageDidLoad:(UIImage *)thumbnailImage;

//called when any data model object modifies text attributes that are used for table cells.
- (void)tableCellTitleTextDidChange:(NSString *)newText;

- (void)tableCellSubtitleTextDidChange:(NSString *)newText;

- (void)coordinatesDidChange:(CLLocation *)location GeocodeAccuracy:(LGMapItemGeocodeAccuracy)geocodeAccuracy;


@end

