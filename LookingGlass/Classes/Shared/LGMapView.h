//
//  LGMapView.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "LGMessageBoxView.h"

@interface LGMapView : MKMapView
{
    
}

@property (nonatomic, retain, readonly) UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic, retain, readonly) NSArray *mapTypeChoices;

- (void)zoomToFitMapAnnotations;
- (void)removeAllMapAnnotations;
- (void)addMapAnnotationsWithArrayContents:(NSArray <MKAnnotation>*)annotations;

@end
