//
//  LGMapView.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGMapView.h"
#import "LGAppDelegate.h"
#import <MapKit/MKGeometry.h>

#define kLGMAPVIEW_MAXANNOTATIONS 50

#define MAP_SATELLITE NSLocalizedString(@"LGMapView_Satelite",  @"Satelite")
#define MAP_HYBRID NSLocalizedString(@"LGMapView_Hybrid",  @"Hybrid")
#define MAP_STANDARD NSLocalizedString(@"LGMapView_Normal",  @"Normal")


@interface LGMapView()
{
    MKMapPoint mapPointForCurrentUserLocation;
}

@property (nonatomic, retain, readonly) LGAppDelegate *appDelegate;


@end


@implementation LGMapView

@synthesize mapTypeSegmentedControl; 
@synthesize mapTypeChoices;
@synthesize appDelegate;

- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) NSLog(@"%@.%@", [[self class] description], suffix);
}

#pragma mark - Setters and Getters
- (LGAppDelegate *)appDelegate
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"appDelegate()"];
    
    if (!appDelegate) appDelegate = (LGAppDelegate *) [[[UIApplication sharedApplication] delegate] retain];
    return appDelegate;
}



#pragma mark - object methods
- (void)removeAllMapAnnotations
{
    
    [self logObjectVariables:@"removeAllMapAnnotations()"];

    [self removeAnnotations:[[self.annotations copy] autorelease]];

}


- (void)zoomToFitMapAnnotations
{ 
    if ([self.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord; 
    topLeftCoord.latitude       = -90; 
    topLeftCoord.longitude      = 180; 
    
    CLLocationCoordinate2D bottomRightCoord; 
    bottomRightCoord.latitude   = 90; 
    bottomRightCoord.longitude  = -180; 
    
    
    for(NSObject <MKAnnotation>  *annotation in self.annotations) { 
        
       // NSLog(@"long, lat: %f, %f", annotation.coordinate.longitude, annotation.coordinate.latitude);
        
        
        topLeftCoord.longitude      = fmin(topLeftCoord.longitude, annotation.coordinate.longitude); 
        topLeftCoord.latitude       = fmax(topLeftCoord.latitude, annotation.coordinate.latitude); 
        bottomRightCoord.longitude  = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude); 
        bottomRightCoord.latitude   = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude); 
    }
    
    // user's current location (usually) is not included in the annotations array. so, if we want to 
    // consider their location as part of the re-sizing set then we have to manually add this last interation.
    
    //CLLocation *currentLocation = self.userLocation;
    CLLocation *currentLocation = self.appDelegate.locationManager.location;        //NOTE: changed from MapView userLocation because this property is usually slow to initialize
                                                                                    //      which cause the first instantiation rendering to be inaccurate.
    
    topLeftCoord.longitude      = fmin(topLeftCoord.longitude, currentLocation.coordinate.longitude); 
    topLeftCoord.latitude       = fmax(topLeftCoord.latitude, currentLocation.coordinate.latitude); 
    bottomRightCoord.longitude  = fmax(bottomRightCoord.longitude, currentLocation.coordinate.longitude); 
    bottomRightCoord.latitude   = fmin(bottomRightCoord.latitude, currentLocation.coordinate.latitude); 
    
    MKCoordinateRegion region; 
    region.center.latitude      = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5; 
    region.center.longitude     = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5; 
    region.span.latitudeDelta   = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; 
    
    // Add a little extra space on the sides 
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; 
    
    region = [self regionThatFits:region]; 
    [self setRegion:region animated:NO]; 
}

- (void)addMapAnnotationsWithArrayContents:(NSArray <MKAnnotation>*)annotations
{
    [self logObjectVariables:@"addMapAnnotationsWithArrayContents()"];
    
    [annotations retain];

    for (NSObject<MKAnnotation> *annotation in annotations) {
        if (self.annotations.count < kLGMAPVIEW_MAXANNOTATIONS) {
            if (!((NSInteger)annotation.coordinate.latitude == 0 && (NSInteger)annotation.coordinate.longitude == 0)) {
                [self addAnnotation:annotation];
            }
        }
    }
    
    [annotations release];
    
}
    

-(void)changedMapType:(UISegmentedControl *)segmentedControl
{
    [self logObjectVariables:@"changedMapType()"];

    if (segmentedControl.selectedSegmentIndex == [mapTypeChoices indexOfObject:MAP_STANDARD]) {
        self.mapType = MKMapTypeStandard;
    } 
    if (segmentedControl.selectedSegmentIndex == [mapTypeChoices indexOfObject:MAP_HYBRID]) {
        self.mapType = MKMapTypeHybrid;
    }
    if (segmentedControl.selectedSegmentIndex == [mapTypeChoices indexOfObject:MAP_SATELLITE]) {
        self.mapType = MKMapTypeSatellite;
    }
    
}

#pragma mark - object life cycle

-(void)localInitialization
{
    [self logObjectVariables:@"localInitialization()"];

    //segmented control for map type buttons
    mapTypeChoices                                      = [[NSArray arrayWithObjects:MAP_SATELLITE, MAP_HYBRID, MAP_STANDARD, nil] retain];
    mapTypeSegmentedControl                             = [[[UISegmentedControl alloc] initWithItems:self.mapTypeChoices] retain];
    mapTypeSegmentedControl.segmentedControlStyle       = UISegmentedControlStyleBar;
    switch (self.mapType) {
        case MKMapTypeHybrid:self.mapTypeSegmentedControl.selectedSegmentIndex      = [self.mapTypeChoices indexOfObject:MAP_HYBRID]; break;
         case MKMapTypeSatellite:self.mapTypeSegmentedControl.selectedSegmentIndex   = [self.mapTypeChoices indexOfObject:MAP_SATELLITE]; break;
        case MKMapTypeStandard:self.mapTypeSegmentedControl.selectedSegmentIndex    = [self.mapTypeChoices indexOfObject:MAP_STANDARD]; break;
    }
    [self.mapTypeSegmentedControl addTarget:self action:@selector(changedMapType:) forControlEvents:UIControlEventValueChanged];
    
    //Custom configuration of our mapview...
    self.zoomEnabled            = YES;
    self.scrollEnabled          = YES;
    self.showsUserLocation      = YES;
    self.userLocation.title     = NSLocalizedString(@"LGMapViewUserLocation", @"You are here");
    
    self.userTrackingMode       = MKUserTrackingModeNone;
}

-(LGMapView *)init
{
    if (self = [super init]) {
        [self logObjectVariables:@"init()"];
        [self localInitialization];
    }
    return self;
}

-(LGMapView *)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self logObjectVariables:@"initWithFrame()"];
        [self localInitialization];
    }
    return self;
}

-(void)dealloc
{
    [mapTypeSegmentedControl release];
    mapTypeSegmentedControl = nil;
    
    [mapTypeChoices release];
    mapTypeChoices = nil;
    
    if (appDelegate) {
        [appDelegate release];
        appDelegate = nil;
    }
    
    [super dealloc];
}

@end

