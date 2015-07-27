//
//  LGDataModelObject.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGDataModelObject.h"

@implementation LGDataModelObject
{
    BOOL didRequestThumbnail;
}

@synthesize delegate;
@synthesize dataFeedType;
@synthesize dataFeedTypeName;
@synthesize isBusy;
@synthesize isCancelled;
@synthesize appDelegate;

@synthesize rowNumber;

@synthesize geocodeStatusImage;
@synthesize geocodeAccuracy;

@synthesize firstLetterOfTitle;
@synthesize tableCellTitle;
@synthesize tableCellSubTitle;

@synthesize applicationCacheDirectoryURL;
@synthesize thumbnailCachePath;
@synthesize thumbnailImage;
@synthesize thumbnailURL;

@synthesize integratorFacebook;
@synthesize integratorAddressBook;
@synthesize integratorLinkedIn;


//required datamodel properties
@dynamic unique_id;
@dynamic datafeedtype_id;
@dynamic thumbnailurl;



#pragma mark - Setters and Getters
- (BOOL)canProcessRequest
{
    if (self.isCancelled) {
        //NSLog(@"%@ is cancelled, canProcessRequest = NO", self.unique_id);
        return NO; 
    } 
    
    return YES;
}


- (UIImage *)geocodeStatusImage
{
    if (!geocodeStatusImage) {
        
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"geocodeStatusImage()"];

        //no geocode, or, bad address
        if (self.geocodeAccuracy <= LGMapItemGeocodeAccuracy_None) { 
            geocodeStatusImage = [[UIImage imageNamed:@"LGTableViewCell_geocodeStatusImage_Error"] retain];
            return geocodeStatusImage;
        }
        
        if (self.dataFeedType == LGDataFeedTypeLinkedIn || self.dataFeedType == LGDataFeedTypeFaceBookFriend) {
            if (self.geocodeAccuracy >= LGMapItemGeocodeAccuracy_City) return nil;  //this is as good as it gets with linkedin and facebook
            else geocodeStatusImage = [[UIImage imageNamed:@"LGTableViewCell_geocodeStatusImage_Caution"] retain];
            return geocodeStatusImage;
        }
        
        //general catch-all logic buckets
        if (self.geocodeAccuracy <= LGMapItemGeocodeAccuracy_PostalCode) geocodeStatusImage = [[UIImage imageNamed:@"LGTableViewCell_geocodeStatusImage_Caution"] retain];
        
    }
    return geocodeStatusImage;
}

- (void)resetGeocodeStatusImage
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"resetGeocodeStatusImage()"];

    if (geocodeStatusImage) {
        [geocodeStatusImage release];
        geocodeStatusImage = nil;
    }
    
}


- (LGAppIntegratorFacebook *)integratorFacebook
{
    if (!integratorFacebook) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"integratorFacebook()"];
        
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeFaceBookFriend]) return nil;
        if (![LGAppDataFeed isEnabledDataFeedType:LGDataFeedTypeFaceBookFriend]) return nil;
        
        integratorFacebook = [[[LGAppIntegratorFacebook alloc] init] retain];
        integratorFacebook.delegate = self;
    }
    return integratorFacebook;
}

- (LGAppIntegratorAddressBook *)integratorAddressBook
{
    if (!integratorAddressBook) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"integratorAddressBook()"];
        
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeAddressBook]) return nil;
        if (![LGAppDataFeed isEnabledDataFeedType:LGDataFeedTypeAddressBook]) return nil;

        integratorAddressBook = [[[LGAppIntegratorAddressBook alloc] init] retain];
        integratorAddressBook.delegate = self;
    }
    return integratorAddressBook;
}

- (LGAppIntegratorLinkedIn *)integratorLinkedIn
{
    if (!integratorLinkedIn) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"integratorLinkedIn()"];
        
        if (![LGAppDataFeed isUnlockedDataFeedType:LGDataFeedTypeLinkedIn]) return nil;
        if (![LGAppDataFeed isEnabledDataFeedType:LGDataFeedTypeLinkedIn]) return nil;

        integratorLinkedIn = [[[LGAppIntegratorLinkedIn alloc] init] retain];
        integratorLinkedIn.delegate = self;
    }
    return integratorLinkedIn;
}

-(LGAppDelegate *)appDelegate
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"appDelegate()"];
    
    if (!appDelegate) appDelegate = (LGAppDelegate *) [[[UIApplication sharedApplication] delegate] retain];
    return appDelegate;
}

-(NSString *)dataFeedTypeName
{
    if (!dataFeedTypeName) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"dataFeedTypeName ()"];
        dataFeedTypeName = [[LGAppDataFeed nameForDataFeedType:self.dataFeedType] copy];
    }
    return dataFeedTypeName;
}

-(LGDataFeedType)dataFeedType
{
    if (!dataFeedType) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"dataFeedType ()"];
        dataFeedType = (LGDataFeedType)[self.datafeedtype_id integerValue];
    }
    return dataFeedType;
}

- (NSURL *)applicationCacheDirectoryURL
{
    if (!applicationCacheDirectoryURL) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"applicationCacheDirectoryURL()"];
        applicationCacheDirectoryURL = [[NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"LG_CACHE_"]] copy];
    }
    return applicationCacheDirectoryURL;
}

-(NSURL *)thumbnailURL
{
    if (!thumbnailURL) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"thumbnailURL()"];
        thumbnailURL = [[NSURL URLWithString:self.thumbnailurl] retain];
    }
    return thumbnailURL;
}

-(NSString *)thumbnailCachePath
{
    if (!thumbnailCachePath) {
        if (self.thumbnailURL) {
            if (OBJECT_DEBUG) [self logObjectVariables:@"thumbnailCachePath()"];
            thumbnailCachePath = [[NSString stringWithFormat:@"%@%@thumbnail_%@", [self.applicationCacheDirectoryURL path], [[self class] description], [self.thumbnailURL lastPathComponent]] retain];
        }
    }
    return thumbnailCachePath;
    
}

-(UIImage *)thumbnailImage
{
    if (!thumbnailImage) {
        if (self.thumbnailCachePath) {
            if (OBJECT_DEBUG) [self logObjectVariables:@"thumbnailImage()"];
            thumbnailImage  =  [[[UIImage alloc] initWithContentsOfFile:self.thumbnailCachePath] retain];
        }
    }
    return thumbnailImage;
}

-(void)setThumbnailImage:(UIImage *)newThumbnailImage
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"setThumbnailImage()"];
    
    @synchronized(self) {
        [newThumbnailImage retain];
        
        if (thumbnailImage) {
            [thumbnailImage release];
            thumbnailImage = nil;
        }
        
        thumbnailImage  =  newThumbnailImage;
    }
    [UIImagePNGRepresentation(thumbnailImage) writeToFile:self.thumbnailCachePath atomically:YES];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(thumbnailImageDidLoad:)]) {
            [self.delegate thumbnailImageDidLoad:thumbnailImage];
        }
    }
}

- (NSString *)firstLetterOfTitle
{
    if (!firstLetterOfTitle && self.tableCellTitle) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"firstLetterOfTitle()"];
        
        firstLetterOfTitle = [[[self.tableCellTitle substringToIndex:1] capitalizedString] copy];
    }
    return firstLetterOfTitle;
}

- (NSString *)tableCellTitle
{
    return tableCellTitle;
}

- (void)setTableCellTitle:(NSString *)newTableCellTitle
{
    
    @synchronized(self) {
        [tableCellTitle release];
        tableCellTitle = [[newTableCellTitle copy] retain];
    }

    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(tableCellTitleTextDidChange:)]) {
            [self.delegate tableCellTitleTextDidChange:tableCellTitle];
        }
    }

}
- (NSString *)tableCellSubTitle
{
    
    return tableCellSubTitle;
}
- (void)setTableCellSubTitle:(NSString *)newTableCellSubTitle
{
    @synchronized(self) {
        [tableCellSubTitle release];
        tableCellSubTitle = [[newTableCellSubTitle copy] retain];
    }
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(tableCellSubtitleTextDidChange:)]) {
            [self.delegate tableCellSubtitleTextDidChange:tableCellSubTitle];
        }
    }
    
}


#pragma mark - Thread Management
-(BOOL)isBusy
{
    return isBusy;
}

- (void)setBusy:(BOOL)busy
{
    isBusy = busy;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = busy;
}


- (BOOL)cancelAllRequests
{
    isCancelled = YES;
    if (isBusy) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"cancelAllRequests()"];
        [self reset];
        [self setBusy:NO];
    }
    return YES;
}
- (void)reset
{
    isBusy = NO;
    isCancelled = NO;
    delegate = nil;
    
    [self resetIntegrators];
    
    if (appDelegate) {
        [appDelegate release];
        appDelegate = nil;
    }
    if (applicationCacheDirectoryURL) {
        [applicationCacheDirectoryURL release];
        applicationCacheDirectoryURL = nil;
    }
    
    if (dataFeedTypeName) {
        [dataFeedTypeName release];
        dataFeedTypeName = nil;
    }
    
    if (geocodeStatusImage) {
        [geocodeStatusImage release];
        geocodeStatusImage = nil;
    }
    
    if (firstLetterOfTitle) {
        [firstLetterOfTitle release];
        firstLetterOfTitle = nil;
    }
    if (tableCellTitle) {
        [tableCellTitle release];
        tableCellTitle = nil;
    }
    if (tableCellSubTitle) {
        [tableCellSubTitle release];
        tableCellSubTitle = nil;
    }
    
    if (thumbnailURL) {
        [thumbnailURL release];
        thumbnailURL = nil;
    }
    if (thumbnailCachePath) {
        [thumbnailCachePath release];
        thumbnailCachePath = nil;
    }
    if (thumbnailImage) {
        [thumbnailImage release];
        thumbnailImage = nil;
    }

}

- (void)resetIntegrators;
{
    if (integratorAddressBook) {
        [integratorFacebook cancelRequest];
        [integratorAddressBook release];
        integratorAddressBook = nil;
    }
    if (integratorFacebook) {
        [integratorAddressBook cancelRequest];
        [integratorFacebook release];
        integratorFacebook = nil;
    }
    if (integratorLinkedIn) {
        [integratorLinkedIn cancelRequest];
        [integratorLinkedIn release];
        integratorLinkedIn = nil;
    }
}

#pragma mark - Public API methods
- (void)requestThumbnail
{
    if (thumbnailImage) return;         //we already have a thumbnail, so nothing to do.
    if (didRequestThumbnail) return;    //we've already requested the thumbnail, we're probably still waiting for results.
    if (!self.thumbnailurl)  return;    //there's no thumnail to download, so nothing to do.
    if (OBJECT_DEBUG) [self logObjectVariables:@"requestThumbnail()"];
    
    dispatch_queue_t myQueue = dispatch_queue_create("my queue", NULL);
    dispatch_async(myQueue, ^
                   {
                       self.thumbnailImage = [LGAppDataFeed Image:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.thumbnailURL]] Pixels:100];
                   });
    dispatch_release(myQueue);
    didRequestThumbnail = YES;

}

-(void)doHousekeeping
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doHousekeeping()"];
    if (self.canProcessRequest) {
        
        //do housekeeping activities here.
        [self requestThumbnail];
        
    }
    //See page 137 of Core Data Programming Guide for peformance details on refreshing individual managed objects.
    //
    // FIX NOTE: cool idea, but it cause the screen to flicker when the in-memory property values are released.
    //           this also causes the screen to momentarily freeze (about .5 seconds).
    //[self.appDelegate.managedObjectContext refreshObject:self mergeChanges:YES];
}

- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) {
        NSLog(@"%@(%@).%@",[[self class] description], self.unique_id, suffix);
    }
}
+ (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG) NSLog(@"%@.%@",[[self class] description], suffix);
}


- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];

    [self cancelAllRequests];
    [self reset];
    
    [super dealloc];
    
}
@end
