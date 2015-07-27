//
//  LGDetailViewController_FacebookFriend.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGDetailViewController_FacebookFriend.h"

@implementation LGDetailViewController_FacebookFriend

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

#pragma mark - View lifecycle
- (id)initwithPerson:(Person *)person
{
    if (self = [super initWithNibName:@"LGDetailViewController_FacebookFriend" bundle:nil]) {
        self.person = person;
    }
    return self;
}
- (id)initWithCheckin:(Checkin *)checkin
{
    if (self = [super initWithNibName:@"LGDetailViewController_FacebookFriend" bundle:nil]) {
        self.checkin = checkin;
    }
    return self;
}
- (id)initWithMapItem:(MapItem *)mapItem
{
    if (self = [super initWithNibName:@"LGDetailViewController_FacebookFriend" bundle:nil]) {
        self.mapItem = mapItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
