//
//  LGRootViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBShapedButton.h"
#import "LGAppDeclarations.h"

@interface LGMainMenuViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *catalogueButton;

//big red button in center of screen
@property (nonatomic, retain) IBOutlet OBShapedButton *nearbyAnythingButton;

//top-left button
@property (nonatomic, retain) IBOutlet OBShapedButton *nearbyPeopleButton;

//top-right button
@property (nonatomic, retain) IBOutlet OBShapedButton *peopleNearButton;

//bottom-left button
@property (nonatomic, retain) IBOutlet OBShapedButton *nearbyPlacesButton;

//botton-right button
@property (nonatomic, retain) IBOutlet OBShapedButton *placesNearButton;


//orphaned button (all people)
@property (nonatomic, retain) IBOutlet UIButton *peopleButton;


//Toolbar
- (IBAction)doRefresh:(id)sender;
- (IBAction)doCatalogue:(id)sender;

- (IBAction)doNearbyPeople:(id)sender;
- (IBAction)doPeopleNear:(id)sender;

- (IBAction)doNearbyAnything:(id)sender;

- (IBAction)doNearbyPlaces:(id)sender;
- (IBAction)doPlacesNear:(id)sender;


//orphan
- (IBAction)doPeople:(id)sender;


@end
