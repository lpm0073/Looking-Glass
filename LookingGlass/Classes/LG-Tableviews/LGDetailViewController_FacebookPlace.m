//
//  LGDetailViewController_FacebookPlace.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGDetailViewController_FacebookPlace.h"
#import "LGAppIntegratorFacebook.h"

@interface LGDetailViewController_FacebookPlace()
{
    NSInteger  queryNumber;
}

@property (nonatomic, retain) NSDictionary *fbDictionary;
@property (nonatomic, retain, readonly) NSMutableArray *infoArray;


- (void)QueryNumberOne;
- (void)QueryNumberTwo;
- (void)QueryNumberThree;
- (void)QueryNumberFour;
- (void)queryProcessorWithSelectClause:(NSString *)querySelectClause;

- (void)processQueryResultOne;
- (void)processQueryResultTwo;
- (void)processQueryResultThree;
- (void)processQueryResultFour;

@end


@implementation LGDetailViewController_FacebookPlace

@synthesize fbDictionary;
@synthesize tableview;
@synthesize infoArray;

//query #1
@synthesize nameLabel;
@synthesize phoneLabel;
@synthesize websiteLabel;
@synthesize type;

//query #2

//query #3

//query #4
@synthesize picImageView;
@synthesize imageURLString;

#pragma mark - Setters and Getters
- (NSMutableArray *)infoArray
{
    if (!infoArray) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"infoArray()"];

        infoArray = [[[NSMutableArray alloc] init] retain];
    }
    return infoArray;
}


#pragma mark - FBRequestDelegate
//==========================================================================================================================================================
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"request:didFailWithError()"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"error: %@", [error description]);
    
    [self cancelAllRequests];
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"request:didReceiveResponse()"];
    
    if (self.isCancelled) {
        [request.connection cancel];
    }
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"request:didLoad()"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.progressView setProgress:100];
    [self.progressView setHidden:YES];
    
    if (self.isCancelled) {
        [request.connection cancel];
        return;
    }
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        self.fbDictionary = [[result objectForKey:@"data"] objectAtIndex:0];
    } else return;

    
    if (queryNumber == 1) {
        [self QueryNumberTwo];
        [self processQueryResultOne];
        return;
    }
    
    if (queryNumber == 2) {
        [self QueryNumberThree];
        [self processQueryResultTwo];
        return;
    }
    
    if (queryNumber == 3) {
        [self QueryNumberFour];
        [self processQueryResultThree];
        return;
    }
    
    if (queryNumber == 4) {
        [self processQueryResultFour];
        return;
    }
    
    
    /*
    if (YES == NO) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            self.fbDictionary = (NSDictionary *)result;
            
            
            [self QueryNumberTwo];
        }
    }
     */
    
  
    
}

#pragma mark - Custom Queries

//==========================================================================================================================================================
- (void)queryProcessorWithSelectClause:(NSString *)querySelectClause
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"queryProcessorWithSelectClause()"];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *fql = [NSString stringWithFormat:@"%@ FROM page WHERE page_id = %@", querySelectClause, self.mapItem.unique_id];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        fql, @"q",
                                        nil] retain];
    
    [self.integratorFacebook executeGraphRequest:@"fql" Parameters:parameters Delegate:self];
    [parameters release];
    
}

//==========================================================================================================================================================
//
// Query #1
//
//==========================================================================================================================================================
- (void)processQueryResultOne
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processQueryResultOne()"];

    self.nameLabel.text = [self.fbDictionary valueForKey:@"name"];
    self.phoneLabel.text = [self.fbDictionary valueForKey:@"phone"];
    self.websiteLabel.text = [self.fbDictionary valueForKey:@"website"];
    if (!self.websiteLabel.text) [self.websiteLabel setText:[self.fbDictionary valueForKey:@"page_url"]];
    
    self.type.text = [[self.fbDictionary valueForKey:@"type"] capitalizedString];
    
}

- (void)QueryNumberOne
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"QueryNumberOne()"];

    //basic info
    queryNumber = 1;
    NSString *select = @"SELECT name, type, phone, website, page_url";
    [self queryProcessorWithSelectClause:select];
    
}

//==========================================================================================================================================================
//
// Query #2
//
//==========================================================================================================================================================

- (void)processQueryResultTwo
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processQueryResultTwo()"];
    
    NSString *s = nil;
    NSDictionary *dict = nil;
    NSArray *arr = nil;
    NSInteger num;
    
    //location
    dict = [self.fbDictionary objectForKey:@"location"];
    if (dict && ![dict isKindOfClass:[NSNull class]] && dict.count > 0) {
        NSString *street = [dict objectForKey:@"street"];
        
        if (street && ![street isKindOfClass:[NSNull class]] && street.length > 0) {
            street = [street capitalizedString];
            [self.infoArray addObject:[NSString stringWithFormat:@"Address: %@", street]];
        }
    }
    
    //description
    s = [self.fbDictionary objectForKey:@"description"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:s];

    //categories
    arr = [self.fbDictionary objectForKey:@"categories"];
    if (arr && ![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
        s = [self arrayOfDictionariesToString:arr KeyValue:@"name"];
        if (s.length > 0) {
            //to add to table view
            //[self.infoArray addObject:s];
            
            //to add to view header
            self.type.text = s;
        }
    }
    
    //fan_count
    num = [[self.fbDictionary objectForKey:@"fan_count"] integerValue];
    if (num > 0) [self.infoArray addObject:[NSString stringWithFormat:@"%d fans", num]];
    
    //general_info
    s = [self.fbDictionary objectForKey:@"general_info"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"General Information: %@", s]];
    
    //checkins
    num = [[self.fbDictionary objectForKey:@"checkins"] integerValue];
    if (num > 0) [self.infoArray addObject:[NSString stringWithFormat:@"%d Checkins", num]];
    
    //founded
    s = [[self.fbDictionary objectForKey:@"founded"] description];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"founded: %@", s]];
    
    //company_overview
    s = [self.fbDictionary objectForKey:@"company_overview"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Company Overview: %@", s]];
    
    //mission
    s = [self.fbDictionary objectForKey:@"mission"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Mission Statement: %@", s]];
    
    //products
    s = [self.fbDictionary objectForKey:@"products"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Products: %@", s]];
    
    
    [self.tableview reloadData];
    
}

- (void)QueryNumberTwo
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"QueryNumberTwo()"];

    //descriptive info
    queryNumber = 2;
    NSString *select = @"SELECT description, categories, fan_count, general_info, checkins, founded, company_overview, mission, products, location";
    [self queryProcessorWithSelectClause:select];

}
//==========================================================================================================================================================
//
// Query #3
//
//==========================================================================================================================================================
- (void)processQueryResultThree
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processQueryResultThree()"];
    
    NSString *s = nil;
    NSDictionary *dict = nil;

    //parking
    dict = [self.fbDictionary objectForKey:@"parking"];
    if (dict && ![dict isKindOfClass:[NSNull class]] && dict.count > 0) {
        s = [self dictWithFlagsToString:dict];
        if (s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Parking: %@", s]];
    }

    //hours
    dict = [self.fbDictionary objectForKey:@"hours"];
    if (dict && ![dict isKindOfClass:[NSNull class]] && dict.count > 0) {
        s = [self hoursDictionaryToString:dict];
        if (s.length > 0) [self.infoArray addObject:s];
    }
    
    //public_transit
    s = [self.fbDictionary objectForKey:@"public_transit"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Public Transit: %@", s]];
    
    //attire
    s = [self.fbDictionary objectForKey:@"attire"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Attire: %@", s]];
    
    //payment_options
    dict = [self.fbDictionary objectForKey:@"payment_options"];
    if (dict && ![dict isKindOfClass:[NSNull class]] && dict.count > 0) {
        s = [self dictWithFlagsToString:dict];
        if (s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Accepts %@", s]];
    }
    
    //culinary_team
    s = [self.fbDictionary objectForKey:@"culinary_team"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Culinary Team: %@", s]];
    
    //general_manager
    s = [self.fbDictionary objectForKey:@"general_manager"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"General Manager: %@", s]];
    
    //price_range
    s = [self.fbDictionary objectForKey:@"price_range"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"price_range: %@", s]];
    
    //restaurant_services
    dict = [self.fbDictionary objectForKey:@"restaurant_services"];
    if (dict && ![dict isKindOfClass:[NSNull class]] && dict.count > 0) {
        s = [self dictWithFlagsToString:dict];
        if (s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Services: %@", s]];
    }
    
    //restaurant_specialties
    dict = [self.fbDictionary objectForKey:@"restaurant_specialties"];
    if (dict && ![dict isKindOfClass:[NSNull class]] && dict.count > 0) {
        s = [self dictWithFlagsToString:dict];
        if (s.length > 0) [self.infoArray addObject:s];
    }
    
    [self.tableview reloadData];

}


- (void)QueryNumberThree
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"QueryNumberThree()"];
    
    //restaurant specific info
    queryNumber = 3;
    NSString *select = @"SELECT parking, hours, public_transit, attire, payment_options, culinary_team, general_manager, price_range, restaurant_services, restaurant_specialties";
    [self queryProcessorWithSelectClause:select];
    
}

//==========================================================================================================================================================
//
// Query #4
//
//==========================================================================================================================================================

- (void)processQueryResultFour
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processQueryResultFour()"];
    
    self.imageURLString = [self.fbDictionary objectForKey:@"pic"];

    dispatch_queue_t myQueue = dispatch_queue_create("my queue", NULL);
    dispatch_async(myQueue, ^
                   {
                       self.picImageView.image = [LGAppDataFeed Image:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURLString]]] Pixels:100];
                       [self.picImageView setNeedsDisplay];
                   });
    dispatch_release(myQueue);

}

- (void)QueryNumberFour
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"QueryNumberFour()"];

    //downloadable image
    queryNumber = 4;
    NSString *select = @"SELECT pic";
    [self queryProcessorWithSelectClause:select];
    
}


#pragma mark - UITableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableView:cellForRowAtIndexPath()"];

    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mytableviewcell"] autorelease];
    
    cell.textLabel.text = [self.infoArray objectAtIndex:[indexPath indexAtPosition:1]];
    cell.imageView.image = nil;  //[LGAppDataFeed imageForDataFeedTypeLarge:LGDataFeedTypeFaceBook];
    
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;                       //in theory this causes number of lines to be calculated automatically
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    [cell.textLabel sizeToFit];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.imageView.backgroundColor = [UIColor clearColor];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = YES;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableView:numberOfRowsInSection()"];

    return self.infoArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"numberOfSectionsInTableView()"];
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"About this place:";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"I am a table footer";
}


#pragma mark - UITableViewDelegate Protocol
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableView:heightForRowAtIndexPath()"];
    NSString *Text = [self.infoArray objectAtIndex:[indexPath indexAtPosition:1]];
    
    UIFont *cellFont = [UIFont systemFontOfSize:14];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [Text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return fmaxf(labelSize.height + 15, 44.0f);
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableView:didSelectRowAtIndexPath()"];

    return;
    
}
- (UIView *)tableView:(UITableView *)thisTableView viewForHeaderInSection:(NSInteger)section
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableView:viewForHeaderInSection()"];
    if ([self.searchDisplayController.searchBar isFirstResponder]) return nil;
    
    UILabel *l          = [[[UILabel alloc] initWithFrame:[self.tableview rectForHeaderInSection:section]] autorelease];
    l.backgroundColor   = [UIColor clearColor];
    l.font              = [UIFont boldSystemFontOfSize:20];
    l.textColor         = [UIColor lightGrayColor];
    l.text              = [self tableView:thisTableView titleForHeaderInSection:section];
    [l sizeToFit];
    
    return l;
    
}
- (UIView *)tableView:(UITableView *)thisTableView viewForFooterInSection:(NSInteger)section
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableView:viewForFooterInSection()"];

    UILabel *l          = [[[UILabel alloc] initWithFrame:[self.tableview rectForHeaderInSection:section]] autorelease];
    l.backgroundColor   = [UIColor clearColor];
    l.font              = [UIFont boldSystemFontOfSize:15];
    l.textColor         = [UIColor lightGrayColor];
    l.text              = [self tableView:thisTableView titleForFooterInSection:section];
    l.textAlignment     = UITextAlignmentRight;
    
    return l;
}


#pragma mark - View lifecycle
//==========================================================================================================================================================

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initwithPerson:(Person *)person
{
    if (self = [super initWithNibName:@"LGDetailViewController_FacebookPlace" bundle:nil]) {
        self.person = person;
    }
    return self;
}
- (id)initWithCheckin:(Checkin *)checkin
{
    if (self = [super initWithNibName:@"LGDetailViewController_FacebookPlace" bundle:nil]) {
        self.checkin = checkin;
    }
    return self;
}
- (id)initWithMapItem:(MapItem *)mapItem
{
    if (self = [super initWithNibName:@"LGDetailViewController_FacebookPlace" bundle:nil]) {
        self.mapItem = mapItem;
    }
    return self;
}

- (void)viewDidLoad
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidLoad()"];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.mapItem) self.nameLabel.text = self.mapItem.title;
    else if (self.checkin) self.nameLabel.text = self.checkin.checkin_Mapitem.title;
    else if (self.person) self.nameLabel.text = self.person.name;
    
    [self QueryNumberOne];

    
}

- (void)viewDidUnload
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload()"];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    fbDictionary = nil;
    tableview = nil;
    infoArray = nil;
    
    //query #1
    nameLabel = nil;
    phoneLabel = nil;
    websiteLabel = nil;
    type = nil;
    
    //query #2
    //query #3
    
    //query #4
    picImageView = nil;
    imageURLString = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    [tableview release];

    //query #1
    [nameLabel release];
    [phoneLabel release];
    [websiteLabel release];
    [type release];
    
    //query #2
    //query #3
    
    //query #4
    [picImageView release];
    [imageURLString release];
    
    //private declarations
    [fbDictionary release];
    [infoArray release];
    
    [super dealloc];
}
@end
