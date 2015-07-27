//
//  LGAppDelegate.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGMessageBoxView.h"
#import "LGActivityIndicatorView.h"
#import "LGMainMenuViewController.h"
#import "LGAppDeclarations.h"
#import "Facebook.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@class Reachability;


@interface LGAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) Facebook *facebook;
//@property (nonatomic, retain) NSOperationQueue *operationQueue;

//UIKit 
@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet LGMainMenuViewController *rootViewController;
@property (nonatomic, retain) LGMessageBoxView *messageBox;
@property (nonatomic, retain) LGActivityIndicatorView *indicatorView;

//Core Data
@property (readonly) NSURL *applicationDocumentsDirectoryURL;
@property (readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;


//Looking Glass: public app utility methods and convenience functions
- (void)showAlert:(NSString *)message title:(NSString *)title;

//Singleton Instances + related properties
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) Reachability   *deviceReachabilityWIFI;
@property (nonatomic, retain) Reachability   *deviceReachabilityWWAN;

@property (readonly) BOOL isDeviceMultitaskingSupported;
@property (readonly) BOOL isDeviceCharging;
@property (readonly) BOOL isDeviceBatteryLevelOk;
@property (readonly) BOOL isDeviceConnectedToAnything;
@property (readonly) BOOL isDeviceConnectedToWifi;
@property (readonly) BOOL isDeviceConnectedToWWAN;



@end


