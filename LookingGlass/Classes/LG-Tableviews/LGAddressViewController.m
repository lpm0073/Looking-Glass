//
//  LGAddressViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGAddressViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LGTVCNearbyPlaces.h"
#import "LGTVCPeople.h"


@interface LGAddressViewController()
{
    NSInteger distanceForQuery;
}

@property (nonatomic, retain, readonly) CLGeocoder *geocoder;
@property (nonatomic, retain) CLLocation <MKAnnotation> *location;

- (void)doTapGesture:(UITapGestureRecognizer *)gesture;
- (void)doSwipeGesture;

- (void)logObjectVariables:(NSString *)suffix;
- (NSString *)defaultTextMessage;
- (void)toggleMapView;
- (void)geocode;
- (void)reverseGeocode;
- (void)hideKeyboard;

@end


@implementation LGAddressViewController

@synthesize goThereButton;
@synthesize correctButton;
@synthesize doOverButton;

@synthesize reverseGeocodedAddressLabel;

@synthesize addressTextView;
@synthesize queryType;
@synthesize mapView;
@synthesize distancePicker;
@synthesize geocoder;
@synthesize location;

#pragma mark Setters and Getters
- (CLGeocoder *)geocoder
{
    if (!geocoder) {
        geocoder = [[[CLGeocoder alloc] init] retain];
    }
    return geocoder;
}

- (NSString *)defaultTextMessage
{
    
    return NSLocalizedString(@"LGAddressVC_defaultaddr", @"a valid, well-known, localized address");
    
}


#pragma mark IBActions

- (IBAction)doGoThereButton:(id)sender
{
    [self logObjectVariables:@"doGoThereButton"];
    [self geocode];
    
}

- (IBAction)doCorrectButton:(id)sender
{
    [self logObjectVariables:@"doCorrectButton"];

    [self toggleMapView];

    LGTVCNearbyPlaces *tvc = [[LGTVCNearbyPlaces alloc] initWithLocation:self.location 
                                                    DistanceFromLocation:distanceForQuery
                                                               QueryType:self.queryType];
    
    [self.navigationController pushViewController:tvc animated:YES];
    [tvc release];
    return;
}

- (IBAction)doDoOverButton:(id)sender
{
    [self logObjectVariables:@"doDoOverButton"];

    self.reverseGeocodedAddressLabel.text = nil;
    [self toggleMapView];
    
}

- (void)doSwipeGesture
{
    [self logObjectVariables:@"doSwipeGesture"];
    [self hideKeyboard];
}

-(void)doTapGesture:(UITapGestureRecognizer *)gesture
{
    
    [self logObjectVariables:@"doTapGesture:"];
    //seems to be the case that the tap gesture is not recognized inside the addressTextView.
    //which is good, as we don't have to evaluate this logic, just resignFirstresponder.
     
    gesture.cancelsTouchesInView = NO;
    [self hideKeyboard];

}


#pragma mark Utility Methods

- (void)toggleMapView
{
    [self logObjectVariables:@"toggleMapView"];
    
    if (self.mapView.hidden) {
        
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            self.addressTextView.hidden = YES;
            [self.view sendSubviewToBack:self.addressTextView];
            
            self.distancePicker.hidden = YES;
            [self.view sendSubviewToBack:self.distancePicker];
            
            [self.mapView zoomToFitMapAnnotations];
            self.mapView.hidden = NO;
            [self.view bringSubviewToFront:self.mapView];
            
            self.reverseGeocodedAddressLabel.hidden = NO;
            [self.view bringSubviewToFront:self.reverseGeocodedAddressLabel];
            
            goThereButton.hidden = YES;
            [self.view sendSubviewToBack:self.goThereButton];
            
            correctButton.hidden = NO;
            doOverButton.hidden = NO;
            [self.view bringSubviewToFront:self.correctButton];
            [self.view bringSubviewToFront:self.doOverButton];
        } completion:nil];
        
    } else {
        
        
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            self.addressTextView.hidden = NO;
            [self.view bringSubviewToFront:self.addressTextView];
            
            self.distancePicker.hidden = NO;
            [self.view bringSubviewToFront:self.distancePicker];
            
            [self.mapView removeAllMapAnnotations];
            self.mapView.hidden = YES;
            [self.view sendSubviewToBack:self.mapView];
            
            self.reverseGeocodedAddressLabel.hidden = YES;
            [self.view sendSubviewToBack:self.reverseGeocodedAddressLabel];
            
            goThereButton.hidden = NO;
            [self.view bringSubviewToFront:self.goThereButton];
            
            correctButton.hidden = YES;
            doOverButton.hidden = YES;
            [self.view sendSubviewToBack:self.correctButton];
            [self.view sendSubviewToBack:self.doOverButton];
        } completion:nil];

    }
    
}

- (void)geocode
{
    [self logObjectVariables:@"geocode()"];
    
    [self.geocoder geocodeAddressString:self.addressTextView.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            CLError coreLocationError = (CLError)error;
            if (coreLocationError != kCLErrorGeocodeFoundPartialResult) {
                [self.reverseGeocodedAddressLabel setText:@"Nothing Found."];
            }
        } else {
            [self reverseGeocode];
        }
        
        if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(location)]) {
            
            self.location = (CLLocation <MKAnnotation>*)[[placemarks objectAtIndex:0] location];
            [self.mapView addAnnotation:self.location];
            
        }
        [self toggleMapView];
    }];
    
}

- (void)reverseGeocode
{
    [self logObjectVariables:@"reverseGeocode()"];
    
    [self.geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
        /*
         placemark:
         Contains an array of CLPlacemark objects. For most geocoding requests, this array should contain only one entry. However, forward-geocoding requests may return multiple placemark objects in situations where the specified address could not be resolved to a single location.
         If the request was canceled or there was an error in obtaining the placemark information, this parameter is nil.        
         */
        if (error){
            CLError coreLocationError = (CLError)error;
            if (coreLocationError != kCLErrorGeocodeFoundPartialResult) {
                [self.reverseGeocodedAddressLabel setText:[self.addressTextView.text capitalizedString]];
                return;
            }
        }
        
        for (CLPlacemark *placemark in placemarks) {  //there should nearly always be only 1 placemark in the results
            
            NSString *s = nil;
            
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(thoroughfare)]) {
                
                s = [[placemarks objectAtIndex:0] thoroughfare];
            }
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(sublocality)]) {
                
                if (s) {
                    s = [NSString stringWithFormat:@"%@, %@", s, [[placemarks objectAtIndex:0] subLocality]];
                } else {
                    s = [[placemarks objectAtIndex:0] subLocality];
                }
            }
            
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(locality)]) {
                if (s) {
                    s = [NSString stringWithFormat:@"%@, %@", s, [[placemarks objectAtIndex:0] locality]];
                } else {
                    s = [[placemarks objectAtIndex:0] locality];
                }
            }
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(administrativeArea)]) {
                if (s) {
                    s = [NSString stringWithFormat:@"%@, %@", s, [[placemarks objectAtIndex:0] administrativeArea]];
                } else {
                    s = [[placemarks objectAtIndex:0] administrativeArea];
                }
            }
            if ([[placemarks objectAtIndex:0] respondsToSelector:@selector(country)]) {
                if (s) {
                    s = [NSString stringWithFormat:@"%@, %@", s, [[placemarks objectAtIndex:0] country]];
                } else {
                    s = [[placemarks objectAtIndex:0] country];
                }
            }
            
            [self.reverseGeocodedAddressLabel setText:s];
            break;
        }
        
    }];
}

- (void)hideKeyboard
{
    [self logObjectVariables:@"hideKeyboard"];
    
    if (self.addressTextView.isFirstResponder) {
        [self.addressTextView resignFirstResponder];
    }
    
}

- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) {
        NSLog(@"%@.%@",[[self class] description], suffix);   
    }
}

#pragma mark Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)atextView
{
    [self logObjectVariables:@"textViewShouldBeginEditing"];

    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self hideKeyboard];
        return NO;
    }
    else
        return YES;

}

#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
   
    [self logObjectVariables:@"keyboardWillShow"];
    
    if ([self.addressTextView.text isEqualToString:[self  defaultTextMessage]]) {
        
        self.addressTextView.text = nil;
        self.addressTextView.textColor = [UIColor darkTextColor];

    }
   
}

#pragma mark - UIPickerViewDelegate Protocol
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 250; 
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker0", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
        case 1:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker1", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
        case 2:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker2", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
        case 3:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker3", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
        case 4:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker4", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
        case 5:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker5", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
        case 6:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker6", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
        case 7:
            return [NSString stringWithFormat:NSLocalizedString(@"LGAddressVC_picker7", @"n %1$@"), NSLocalizedString(@"LGAddressVC_unit", @"Kilometers")];
            break;
    }
    return [NSString stringWithFormat:@"Row %d not found.", row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            distanceForQuery = 1 * 1000;
            break;
        case 1:
            distanceForQuery = 10 * 1000;
            break;
        case 2:
            distanceForQuery = 25 * 1000;
            break;
        case 3:
            distanceForQuery = 50 * 1000;
            break;
        case 4:
            distanceForQuery = 100 * 1000;
            break;
        case 5:
            distanceForQuery = 200 * 1000;
        case 6:
            distanceForQuery = 500 * 1000;
        case 7:
            distanceForQuery = 1000 * 1000;
            break;
    }
}

#pragma mark - UIPickerViewDataSource Protocol 
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 8;
}


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self logObjectVariables:@"initWithNibName"];
    }
    return self;
}

- (id)initWithQueryTuype:(LGQueryType)thisQueryType
{
    if (self = [self initWithNibName:@"LGAddressViewController" bundle:nil]) {
        self.queryType = thisQueryType;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self logObjectVariables:@"didReceiveMemoryWarning"];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self logObjectVariables:@"viewDidLoad"];

    distanceForQuery = 1 * 1000;       //default value
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    UIGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doSwipeGesture)];
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTapGesture:)];
    
    if ([tapGesture respondsToSelector:@selector(locationInView:)]) {
        [self.view addGestureRecognizer:tapGesture];
    }
    
    [tapGesture release];


    self.mapView.delegate = self;
    self.mapView.hidden = YES;
    
    self.reverseGeocodedAddressLabel.text = nil;
    self.reverseGeocodedAddressLabel.hidden = YES;
    [self.view sendSubviewToBack:self.reverseGeocodedAddressLabel];
    
    self.addressTextView.delegate = self;
    self.addressTextView.returnKeyType = UIReturnKeyDone;
    self.addressTextView.enablesReturnKeyAutomatically = YES;
    self.addressTextView.keyboardType = UIKeyboardTypeASCIICapable;
    
    self.addressTextView.textColor = [UIColor darkTextColor];
    self.addressTextView.text = [self defaultTextMessage];
    
    [self.goThereButton.titleLabel setText:@"Go There Now"];
    self.goThereButton.hidden = NO;
    [self.view bringSubviewToFront:self.goThereButton];
    
    [self.correctButton.titleLabel setText:@"Correct"];
    self.correctButton.hidden = YES;
    [self.view sendSubviewToBack:self.correctButton];
    
    [self.doOverButton.titleLabel setText:@"Do Over"];
    self.doOverButton.hidden = YES;
    [self.view sendSubviewToBack:self.doOverButton];
    
    self.distancePicker.delegate = self;
    self.distancePicker.dataSource = self;
    self.distancePicker.hidden = NO;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.reverseGeocodedAddressLabel.text = nil;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self logObjectVariables:@"viewDidUnload"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

    goThereButton = nil;
    correctButton = nil;
    doOverButton = nil;
    
    reverseGeocodedAddressLabel = nil;
    
    addressTextView = nil;
    mapView = nil;
    distancePicker = nil;
    geocoder = nil;
    location = nil;

}

- (void)dealloc
{
    [self logObjectVariables:@"dealloc"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];

    [goThereButton release];
    [correctButton release];
    [doOverButton release];
    
    [reverseGeocodedAddressLabel release];
    
    [addressTextView release];
    [mapView release];
    [distancePicker release];
    [geocoder release];
    [location release];
    [super dealloc];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
