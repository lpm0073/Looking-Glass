//
//  LGAppDelegate.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGAppDelegate.h"
#import "MapItem.h"
#import "Person.h"
#import "LGAppIntegratorLinkedIn.h"
#import "LGAppIntegratorAddressBook.h"
#import "LGAppIntegratorFacebook.h"


/*=======================================================================================================================================================================
 * local API
 *=======================================================================================================================================================================*/
@interface LGAppDelegate()

@property (nonatomic, retain)  NSUbiquitousKeyValueStore *ubiquitousKeyValueStore;

- (void)logObjectVariables:(NSString *)suffix;
- (void)runOnceOnlyAppWelcome;
- (void)clearCache;


@end

/*=======================================================================================================================================================================
 * Implementation
 *=======================================================================================================================================================================*/
@implementation LGAppDelegate

#pragma mark - Property Synthesis

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize indicatorView;
@synthesize messageBox;
@synthesize applicationDocumentsDirectoryURL;
@synthesize ubiquitousKeyValueStore;
@synthesize facebook;
//@synthesize operationQueue;

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize managedObjectModel          = __managedObjectModel;
@synthesize persistentStoreCoordinator  = __persistentStoreCoordinator;

@synthesize locationManager;
@synthesize deviceReachabilityWIFI;
@synthesize deviceReachabilityWWAN;


#pragma mark - Looking Glass Setters and Getters
/*=======================================================================================================================================================================
 * 
 *=======================================================================================================================================================================*/
- (Reachability *)deviceReachabilityWIFI
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"deviceReachabilityWIFI()"];
    if (!deviceReachabilityWIFI) {
        deviceReachabilityWIFI = [[Reachability reachabilityForLocalWiFi] retain];
        
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method "reachabilityChanged" will be called. 
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    }
    return deviceReachabilityWIFI;
}

- (Reachability *)deviceReachabilityWWAN
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"deviceReachabilityWWAN()"];
    if (!deviceReachabilityWWAN) {
        deviceReachabilityWWAN = [[Reachability reachabilityForInternetConnection] retain];
        
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method "reachabilityChanged" will be called. 
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    }
    return deviceReachabilityWWAN;
}

- (CLLocationManager *)locationManager
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"locationManager()"];
    if (!locationManager) {
        // Create location manager with filters set for battery efficiency.
        locationManager                     = [[[CLLocationManager alloc] init] retain]; 
        locationManager.delegate            = self;
        locationManager.distanceFilter      = 2000;       //assuming that this means meters??
        locationManager.desiredAccuracy     = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
    }
    return locationManager;
}

- (BOOL)isDeviceConnectedToWWAN
{
    BOOL retVal = NO;
    retVal = ([deviceReachabilityWWAN currentReachabilityStatus] != NotReachable);
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isDeviceConnectedToWWAN() = %d", retVal]];
    return retVal;
}
- (BOOL)isDeviceConnectedToWifi
{
    BOOL retVal = NO;
    retVal = ([deviceReachabilityWIFI currentReachabilityStatus] == ReachableViaWiFi);
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isDeviceConnectedToWifi() = %d", retVal]];
    return retVal;
}
- (BOOL)isDeviceConnectedToAnything
{
    BOOL retVal = NO;
    retVal = (self.isDeviceConnectedToWifi || self.isDeviceConnectedToWWAN);
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isDeviceConnectedToAnything() = %d", retVal]];
    
    if (!retVal) {
        [self showAlert:NSLocalizedString(@"AppTitle", @"Looking Glass") title:@"No Internet!"];
    }
    return retVal;
}


- (BOOL)isDeviceBatteryLevelOk
{
    //kind of an arbitrary threshold, but point is that we don't want to kick off a big
    //process if the battery was nearly dead when user connected the charger.
    BOOL retVal = NO;
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateUnknown) return YES; //don't know, so we'll assume we're fine.
    retVal = ([UIDevice currentDevice].batteryLevel > .25);     
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isDeviceBatteryLevelOk() = %d", retVal]];
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"BatteryLevel = %f", [UIDevice currentDevice].batteryLevel]];
    return retVal;
}

- (BOOL)isDeviceCharging
{
    BOOL retVal = NO;
    retVal = (([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) || ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateFull));
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isDeviceCharging() = %d", retVal]];
    return retVal;
}

- (BOOL)isDeviceMultitaskingSupported
{
    
    BOOL retVal = NO;
    UIDevice *device            = [[UIDevice currentDevice] retain];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]) retVal = device.multitaskingSupported;
    [device release];
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:[NSString stringWithFormat:@"isDeviceMultitaskingSupported() = %d", retVal]];
    return retVal;
}

/*
- (NSOperationQueue *)operationQueue
{
    if (!operationQueue) {
        operationQueue = [[[NSOperationQueue alloc] init] retain];
        [operationQueue setMaxConcurrentOperationCount:5];
        [operationQueue setName:@"operationQueue"];
    }
    return operationQueue;
}
 */

- (UIActivityIndicatorView *)indicatorView
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"indicatorView()"];
    
    if (!indicatorView) {
        indicatorView = [[[LGActivityIndicatorView alloc] init] retain];
        
        [self.window addSubview:indicatorView];
    }
    return indicatorView;
}
- (LGMessageBoxView *)messageBox
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"messageBox()"];
    if (!messageBox) {
        messageBox         = [[[LGMessageBoxView alloc] initWithFrame:CGRectMake(3, 3, [[UIScreen mainScreen] bounds].size.width-6, 30)] retain];
        [self.window addSubview:messageBox];
    }
    return messageBox;
}




#pragma mark - Frameworks Setters &  Getters
/*=======================================================================================================================================================================
 * 
 *=======================================================================================================================================================================*/
- (NSManagedObjectContext *)managedObjectContext
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"managedObjectContext()"];
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    if (self.persistentStoreCoordinator != nil) {
        __managedObjectContext = [[[NSManagedObjectContext alloc] init] retain];
        [__managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    
    __managedObjectContext.undoManager = nil;       //NOTE: per Core Data Programming Guide page 77. this is supposed to improve performance on background worker threads.
    
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"managedObjectModel()"];
    
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LookingGlass" withExtension:@"momd"];
    __managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] retain];
    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"persistentStoreCoordinator()"];
    
    if (__persistentStoreCoordinator != nil) return __persistentStoreCoordinator;
    else {
        NSURL *storeURL = [[self applicationDocumentsDirectoryURL] URLByAppendingPathComponent:@"LookingGlass.sqlite"];
        
        NSError *error = nil;
        __persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]] retain];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }    
    }
    
    return __persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectoryURL
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"applicationDocumentsDirectoryURL()"];
    
    if (!applicationDocumentsDirectoryURL) {
        applicationDocumentsDirectoryURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] retain];
    }
    return applicationDocumentsDirectoryURL;
}


//iCloud
- (NSUbiquitousKeyValueStore *)ubiquitousKeyValueStore {
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"ubiquitousKeyValueStore()"];
    if (!ubiquitousKeyValueStore) {
        ubiquitousKeyValueStore = [[NSUbiquitousKeyValueStore defaultStore] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateKVStoreItems:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:ubiquitousKeyValueStore];
    }
    return ubiquitousKeyValueStore;
}
   


#pragma mark - Utility Methods
/*=======================================================================================================================================================================
 * 
 *=======================================================================================================================================================================*/
- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    NSLog(@"%@.%@",[[self class] description], suffix);   
}


- (void)showAlert:(NSString *)message title:(NSString *)title
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"showAlert:title()"];

    UIAlertView *alert  = [[[UIAlertView alloc] init] autorelease];
    alert.title         = title;
    alert.message       = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];

}



-(void)clearCache
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"clearCache()"];

    //cleanup the sandbox. this deletes cached person profile images.
    NSDate *cacheDeleteDate = [[NSDate dateWithTimeIntervalSinceNow: -kLGCACHE_DAYS_TO_KEEP_OBJECTS * 24 * 60 * 60] retain];
    
    NSFileManager *defaultManager = [[NSFileManager defaultManager] retain];
    
    NSError *error = nil;
    NSArray *filesArray = [[defaultManager contentsOfDirectoryAtURL:[NSURL URLWithString:NSTemporaryDirectory()] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error] retain];

    if (OBJECT_DEBUG) {
        for (NSURL *file in filesArray) {
            NSString *filename = [file lastPathComponent];
            NSLog(@"file: %@", filename);
        }
    }
    
    for (NSURL *file in filesArray) {
        NSString *filename = [file lastPathComponent];
        NSString *prefix = [filename substringWithRange:NSMakeRange(0, [filename length] >= 8 ? 8 : [filename length])];
        
        if ([prefix isEqual:@"LG_CACHE"]) {
            NSDate *modDate = [[defaultManager attributesOfItemAtPath:[file path] error:&error] fileModificationDate];
            if ([modDate earlierDate:cacheDeleteDate] == modDate) {
                BOOL success = [defaultManager removeItemAtURL:file error:&error];
                if (!success || error) {
                    if (OBJECT_DEBUG) NSLog(@"could not delete: %@ %@", error, [error userInfo]);
                } else {
                    if (OBJECT_DEBUG) NSLog(@"deleted: %@", file);
                }
            }
        }
    }
    
    [filesArray release];
    filesArray = nil;
    
    [defaultManager release];
    defaultManager = nil;
    
    [cacheDeleteDate release];
    cacheDeleteDate = nil;
    
}

- (void)runOnceOnlyAppWelcome
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"runOnceOnly()"];
    //runs exactly one time when the app has first been installed.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AppRanOnce"]) return;
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"runOnceOnly()"];
    
    //FIX NOTE: THIS CAUSES THE ROOT VIEW CONTROLLER ERROR TO APPEAR AT FIRST APP LAUNCH.
    //[self showAlert:NSLocalizedString(@"AppTitle", @"Looking Glass") title:NSLocalizedString(@"LGAppDelegate_Welcome", @"Welcome message")];
    
    
    [LGAppDataFeed unlockDataFeedType:LGDataFeedTypeFaceBookFriend];
    [LGAppDataFeed unlockDataFeedType:LGDataFeedTypeLinkedIn];
    [LGAppDataFeed unlockDataFeedType:LGDataFeedTypeAddressBook];

    
    //we shouldn't really need to do this but for some reason the default values of the app plist are always set to null unless we initialize here.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AutoSynchEnabled_preference"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutoSynchIfNoWifi_preference"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutoSynchIfDisconnected_preference"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"imagecaching_preference"];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppRanOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UIApplicationDelegate
/*=======================================================================================================================================================================
 * 
 *=======================================================================================================================================================================*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"application:didFinishLaunchingWithOptions()"];
    
    // defaul app launch sequence
    self.window                 = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootViewController     = [[LGMainMenuViewController alloc] initWithNibName:@"LGMainMenuViewController" bundle:nil];
    self.navigationController   = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    self.navigationController.delegate = self;
    [self.window addSubview:[self.navigationController view]];
    [self.window makeKeyAndVisible];
    
    UILocalNotification *locationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey];
    if (locationKey) {
        NSLog(@"we were launched in reseponse to a location change event.");
        
    }
    
    //other app initializations
    [self clearCache];
    [self runOnceOnlyAppWelcome];

    //location manager startup sequence
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [self.locationManager startMonitoringSignificantLocationChanges];
    else {
        NSLog(@"significantLocationChangeMonitoringAvailable are not available.");
    }
    if ([CLLocationManager locationServicesEnabled]) [self.locationManager startUpdatingLocation];
    else {
        NSLog(@"locationServicesEnabled = NO.");
    }
    
    
    //for iCloud storage synch
    [self.ubiquitousKeyValueStore synchronize];     // Register for iCloud key/value preferences synchronization across devices
    
    
    //device self-awareness initializations
    [self.deviceReachabilityWIFI startNotifier];        // receive notifications on device connectivity
    [self.deviceReachabilityWWAN startNotifier];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelDidChange:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateDidChange:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object:nil];
        
    
    
    return YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"applicationWillEnterForeground()"];
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"applicationDidBecomeActive()"];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [self.locationManager startMonitoringSignificantLocationChanges];
    if ([CLLocationManager locationServicesEnabled]) [self.locationManager startUpdatingLocation];
    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if (OBJECT_DEBUG) [self logObjectVariables:@"applicationWillResignActive()"];

    [self saveContext];                 //save any pending changes to managed objects
    
                                        //shut down location manager activities
    if ([CLLocationManager locationServicesEnabled]) [self.locationManager stopUpdatingLocation];
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [self.locationManager stopMonitoringSignificantLocationChanges];

    //[self.operationQueue cancelAllOperations];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"applicationDidEnterBackground()"];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

	// Reset the icon badge number to zero.
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}


- (void)applicationWillTerminate:(UIApplication *)application
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"applicationWillTerminate()"];
    [self saveContext];

}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"applicationDidReceiveMemoryWarning");
}


- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    [window release];
    [navigationController release];
    [rootViewController release];
    if (indicatorView) [indicatorView release];
    if (messageBox) [messageBox release];
    
    if (applicationDocumentsDirectoryURL) [applicationDocumentsDirectoryURL release];
    if (ubiquitousKeyValueStore) [ubiquitousKeyValueStore release];

    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    
    [locationManager stopUpdatingLocation];
    [locationManager stopMonitoringSignificantLocationChanges];
    locationManager.delegate = nil;
    [locationManager release];
    locationManager = nil;
    
    if (deviceReachabilityWIFI) {
        [deviceReachabilityWIFI stopNotifier];
        [deviceReachabilityWIFI release];
        deviceReachabilityWIFI = nil;
    }
    if (deviceReachabilityWWAN) {
        [deviceReachabilityWWAN stopNotifier];
        [deviceReachabilityWWAN release];
        deviceReachabilityWWAN = nil;
    }
    
    /*
    if (operationQueue) {
        [operationQueue cancelAllOperations];
        [operationQueue release];
        operationQueue = nil;
    }
     */

    if (facebook) {
        [facebook release];
        facebook = nil;
    }

    [super dealloc];
}

/*=======================================================================================================================================================================
 * Framework API callbacks
 *=======================================================================================================================================================================*/
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

    if (OBJECT_DEBUG) [self logObjectVariables:@"navigationController:willShowViewController()"];
    [self.managedObjectContext lock];

}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"navigationController:didShowViewController()"];
    [self.managedObjectContext unlock];

}


#pragma mark - Framework API - Facebook API
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"application:handleOpenURL()"];
    
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"application:openURL:sourceApplication:annotation()"];
    
    return [self.facebook handleOpenURL:url];
}


#pragma mark - Framework API - iCloud
- (void)updateKVStoreItems:(NSNotification*)notification {
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"updateKVStoreItems:()"];
    
    // Get the list of keys that changed.
    NSDictionary *userInfo      = [[notification userInfo] retain];
    NSNumber *reasonForChange   = [[userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey] retain];
    NSInteger reason            = -1;
    
    // If a reason could not be determined, do not update anything.
    if (!reasonForChange) return;
    
    // Update only for changes from the server.
    reason = [reasonForChange integerValue];
    if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
        // If something is changing externally, get the changes
        // and update the corresponding keys locally.
        NSArray *changedKeys                = [[userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey] retain];
        NSUbiquitousKeyValueStore *store    = [NSUbiquitousKeyValueStore defaultStore];
        NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
        
        // This loop assumes you are using the same key names in both
        // the user defaults database and the iCloud key-value store
        for (NSString* key in changedKeys) {
            id value = [store objectForKey:key];
            [userDefaults setObject:value forKey:key];
        }
        
        [changedKeys release];
        changedKeys = nil;
        
    }
    
    [userInfo release];
    userInfo = nil;
    
    [reasonForChange release];
    reasonForChange = nil;
    
}


#pragma mark - Framework API - Core Data
- (void)saveContext
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"saveContext()"];

    NSError *error                                  = nil;
    if (self.managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort(); //FIX NOTE: RESEARCH Error Domain=NSCocoaErrorDomain Code=133020 "The operation couldn’t be completed.
        }
    }
}

#pragma mark - Framework API - Core Location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"locationManager:didUpdateToLocation(%f, %f):fromLocation:(%f, %f)", 
                                                newLocation.coordinate.latitude, 
                                                newLocation.coordinate.longitude, 
                                                oldLocation.coordinate.latitude, 
                                                oldLocation.coordinate.longitude
                                                ]
                       ];
    
    
    
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"locationManager:didEnterRegion()"];
    
    //location manager encountered a region in which we were monitoring -- in face, we just enterred the region...
    NSLog(@"[LGAppDelegate locationManager:didEnterRegion:] %@", [region description]);
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"locationManager:didFailWithError()"];
    NSLog(@"%@", error);
    
    // show the error alert
    //[self showAlert:@"Error obtaining location" title:[error localizedDescription]];
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"locationManager:didChangeAuthorizationStatus to %d", status);
}

#pragma mark - Framework API - Reachability
//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"reachabilityChanged:()"];
    
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    if (self.isDeviceConnectedToWifi) {
        // good news: we weren't connected to WIFI, but now we are.
    }
}

#pragma mark - Framework API - UIKit/UIDevice
- (void)batteryLevelDidChange:(NSNotification *)notification
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"batteryLevelDidChange()"];
    
}

- (void)batteryStateDidChange:(NSNotification *)notification
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"batteryStateDidChange()"];
    
}

@end
