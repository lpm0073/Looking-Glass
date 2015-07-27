//
//  LGAddressViewController.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGAppDeclarations.h"
#import "LGMapView.h"



@interface LGAddressViewController : UIViewController <UITextViewDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) IBOutlet UIButton *goThereButton;
@property (nonatomic, retain) IBOutlet UIButton *correctButton;
@property (nonatomic, retain) IBOutlet UIButton *doOverButton;

@property (nonatomic, retain) IBOutlet UILabel *reverseGeocodedAddressLabel;
@property (nonatomic, retain) IBOutlet UITextView *addressTextView;
@property (nonatomic, retain) IBOutlet LGMapView *mapView;
@property (nonatomic, retain) IBOutlet UIPickerView *distancePicker;

@property (nonatomic) LGQueryType queryType;

- (id)initWithQueryTuype:(LGQueryType)queryType;

- (IBAction)doGoThereButton:(id)sender;
- (IBAction)doCorrectButton:(id)sender;
- (IBAction)doDoOverButton:(id)sender;

@end
