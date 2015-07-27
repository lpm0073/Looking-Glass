//
//  LGInAppSaleViewController_Authorize.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGInAppSaleViewController_Authorize.h"
#import "LGAppDataFeed.h"
#import "LGAppIntegratorLinkedIn.h"
#import "LGAppIntegratorAddressBook.h"
#import "LGAppIntegratorFacebook.h"



@implementation LGInAppSaleViewController_Authorize

@synthesize successLabel;
@synthesize authorizeDataSourceButton; 
@synthesize progressView;
@synthesize imageView;
@synthesize dataFeedType;


- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) NSLog(@"LGInAppSaleViewController_Success.%@", suffix);
}



- (IBAction)authorizeDataSourceButtonClicked: (id) sender
{
    [self logObjectVariables:@"synchNowButtonClicked()"];
    
    
    switch (self.dataFeedType)
    {
        case LGDataFeedTypeAddressBook:
        {
            LGAppIntegratorAddressBook *integratorAddressBook = [[[LGAppIntegratorAddressBook alloc] init] retain];
            [integratorAddressBook release];
            break;
        }
        case LGDataFeedTypeFaceBookFriend:
        {
            LGAppIntegratorFacebook *integratorFacebook = [[[LGAppIntegratorFacebook alloc] init] retain];
            [integratorFacebook release];
            break;
        }
        case LGDataFeedTypeFourSquare:
            break;
        case LGDataFeedTypeGooglePlaces:
            break;
        case LGDataFeedTypeGowalla:
            break;
        case LGDataFeedTypeGroupon:
            break;
        case LGDataFeedTypeJive:
            break;
        case LGDataFeedTypeLinkedIn:
        {
            LGAppIntegratorLinkedIn *integratorLinkedIn = [[[LGAppIntegratorLinkedIn alloc] init] retain];
            [integratorLinkedIn release];
            break;
        }
        case LGDataFeedTypeLOCKERZ:
            break;
        case LGDataFeedTypeSkype:
            break;
        case LGDataFeedTypeBeacon:
            break;
        default:
            break;
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self logObjectVariables:@"viewDidLoad()"];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    self.navigationItem.hidesBackButton = YES;
    
    [self.progressView setHidden:YES];
    
    self.authorizeDataSourceButton.titleLabel.font  = [UIFont systemFontOfSize:10];
    self.authorizeDataSourceButton.titleLabel.text  = [NSString stringWithFormat:@"Authorize %@ Now.", [LGAppDataFeed nameForDataFeedType:self.dataFeedType]];
    self.successLabel.text                          = [NSString stringWithFormat:@"Congrulations on your purchase of %@", [LGAppDataFeed nameForDataFeedType:self.dataFeedType]];
    self.imageView.image                            = [LGAppDataFeed imageForDataFeedTypeLarge:self.dataFeedType];
    [self.imageView setNeedsDisplay];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self logObjectVariables:@"viewDidUnload()"];
    successLabel = nil;
    authorizeDataSourceButton = nil;
    progressView = nil;
    imageView = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    [self logObjectVariables:@"shouldAutorotateToInterfaceOrientation()"];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [successLabel release];
    [authorizeDataSourceButton release];
    [progressView release];
    [imageView release];
    
    [super dealloc];
}



@end
