//
//  LGDetailViewController_LinkedIn.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGDetailViewController_LinkedIn.h"

@interface LGDetailViewController_LinkedIn()

@property (nonatomic, copy) NSString *linkedInID;
@property (nonatomic, readonly) NSString *cachePath;
@property (nonatomic, readonly) NSString *baseURL;
@property (nonatomic, readonly) NSDictionary *cachedResultsDictionary;
@property (nonatomic, retain, readonly) NSMutableArray *infoArray;


- (void)executeLinkedInQuery:(OAServiceTicket *)ticket didFinish:(NSData *)data;
- (void)executeLinkedInQuery:(OAServiceTicket *)ticket didFail:(NSData *)error;
- (void)executeLinkedInQuery:(NSString *)query;

- (void)linkedInQuery;

- (void)linkedInResults_01:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_02:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_03:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_04:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_05:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_06:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_07:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_08:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_09:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_10:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_11:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_12:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_13:(NSDictionary *)resultsDictionary;
- (void)linkedInResults_14:(NSDictionary *)resultsDictionary;


@end


@implementation LGDetailViewController_LinkedIn

@synthesize linkedInID;
@synthesize cachedResultsDictionary;
@synthesize infoArray;
@synthesize tableview;
@synthesize nameLabel;
@synthesize headlineLabel;
@synthesize imageURLString;
@synthesize imageView;

#pragma mark - Setters and Getters
- (NSMutableArray *)infoArray
{
    if (!infoArray) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"infoArray()"];
        
        infoArray = [[[NSMutableArray alloc] init] retain];
    }
    return infoArray;
}

- (NSString *)cachePath
{
    return [[NSString stringWithFormat:@"%@%@_%@", NSTemporaryDirectory(), [[self class] description], self.linkedInID] copy];
    
}

- (NSString *)baseURL
{
    return [[NSString stringWithFormat:@"http://api.linkedin.com/v1/people/id=%@", self.linkedInID] copy];
}

- (NSDictionary *)cachedResultsDictionary
{
    if (!cachedResultsDictionary) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"cachedResultsDictionary()"];

        cachedResultsDictionary = [[[NSDictionary alloc] initWithContentsOfFile:self.cachePath] retain];
    }
    return cachedResultsDictionary;
}

#pragma mark - Object API methods
- (IBAction)doRefresh:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doRefresh:sender"];

    [super doRefresh:sender];
    [self linkedInQuery];
    
}

- (IBAction)doBackButton:(id)sender
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"doBackButton:sender"];

    [super doBackButton:sender];
    NSLog(@"doBackButton - LGDetailViewController_LinkedIn");

}

#pragma mark - LinkedIn API
- (void)linkedInQuery
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInQuery_01"];

    NSString *q = [NSString stringWithFormat:@"%@:(", [self.baseURL copy]];
    q = [NSString stringWithFormat:@"%@first-name,last-name,main-address,headline", q];
    q = [NSString stringWithFormat:@"%@,location:(name),industry,distance,last-modified-timestamp,num-connections,summary", q];
    q = [NSString stringWithFormat:@"%@,phone-numbers,im-accounts,twitter-accounts,group-memberships", q];
  //q = [NSString stringWithFormat:@"%@,picture-url", q];
    q = [NSString stringWithFormat:@"%@,num-recommenders,specialties,proposal-comments,associations,honors,interests", q];
    q = [NSString stringWithFormat:@"%@,positions:(company:(name),title,start-date,end-date)", q];
    q = [NSString stringWithFormat:@"%@,publications", q];
    q = [NSString stringWithFormat:@"%@,patents", q];
    q = [NSString stringWithFormat:@"%@,languages", q];
    q = [NSString stringWithFormat:@"%@,skills", q];
    q = [NSString stringWithFormat:@"%@,certifications", q];
    q = [NSString stringWithFormat:@"%@,educations", q];
    q = [NSString stringWithFormat:@"%@,courses", q];
    q = [NSString stringWithFormat:@"%@,volunteer", q];
    q = [NSString stringWithFormat:@"%@)", q];
    
    [self executeLinkedInQuery:q];
    
}

- (void)linkedInProcessDictionaryResults
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInProcessDictionaryResults()"];
    
    //NSLog(@"%@", self.cachedResultsDictionary);
    
    [self linkedInResults_01:self.cachedResultsDictionary];
    [self linkedInResults_02:self.cachedResultsDictionary];
    [self linkedInResults_03:self.cachedResultsDictionary];
    [self linkedInResults_04:self.cachedResultsDictionary];
    [self linkedInResults_05:self.cachedResultsDictionary];
    [self linkedInResults_06:self.cachedResultsDictionary];
    [self linkedInResults_07:self.cachedResultsDictionary];
    [self linkedInResults_08:self.cachedResultsDictionary];
    [self linkedInResults_09:self.cachedResultsDictionary];
    [self linkedInResults_10:self.cachedResultsDictionary];
    [self linkedInResults_11:self.cachedResultsDictionary];
    [self linkedInResults_12:self.cachedResultsDictionary];
    [self linkedInResults_13:self.cachedResultsDictionary];
    [self linkedInResults_14:self.cachedResultsDictionary];

    [self.tableview reloadData];

}

- (void)linkedInResults_01:(NSDictionary *)resultsDictionary
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_01:resultsDictionary"];
    NSString *s;
    
    s = [resultsDictionary objectForKey:@"firstName"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) nameLabel.text = s;

    s = [resultsDictionary objectForKey:@"lastName"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) nameLabel.text = [NSString stringWithFormat:@"%@ %@", nameLabel.text, s];
    
    s = [resultsDictionary objectForKey:@"headline"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) headlineLabel.text = s;
    
}
- (void)linkedInResults_02:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_02:resultsDictionary"];
    
    //location,industry,distance,last-modified-timestamp,network,num-connections,summary
    NSString *s;
    NSDictionary *dict = nil;
    NSInteger num;

    
    //summary
    s = [resultsDictionary objectForKey:@"summary"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Summary: %@", s]];
    
    //distance
    num = [[resultsDictionary objectForKey:@"distance"] integerValue];
    if (num > 0) [self.infoArray addObject:[NSString stringWithFormat:@"%d degree connection", num]];

    //connections
    num = [[resultsDictionary objectForKey:@"numConnections"] integerValue];
    if (num > 0) [self.infoArray addObject:[NSString stringWithFormat:@"%d connections", num]];

    //industry
    s = [resultsDictionary objectForKey:@"industry"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Industry: %@", s]];

    //location
    dict = [resultsDictionary objectForKey:@"location"];
    if ([self isValidDictionary:dict]) {
        NSString *locationName = [dict objectForKey:@"name"];
        
        if (locationName && ![locationName isKindOfClass:[NSNull class]] && locationName.length > 0) {
            locationName = [locationName capitalizedString];
            [self.infoArray addObject:[NSString stringWithFormat:@"Location: %@", locationName]];
        }
    }
    
}
- (void)linkedInResults_03:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_03:resultsDictionary"];
    
    //phone-numbers,im-accounts,twitter-accounts,group-memberships
    NSString *s;
    NSDictionary *dict = nil;
    NSArray *arr = nil;

    //IM Accounts
    dict = [resultsDictionary objectForKey:@"imAccounts"];
    if ([self isValidDictionary:dict]) {
        arr = [dict objectForKey:@"values"];
        for (NSInteger i = 0; i < arr.count; i++) {
            
            dict = [arr objectAtIndex:i];
            NSString *accountName = [dict objectForKey:@"imAccountName"];
            NSString *accountType = [dict objectForKey:@"imAccountType"];
            
            if (accountName != nil && accountType != nil) [self.infoArray addObject:[NSString stringWithFormat:@"%@: %@", accountType, accountName]];
        }
    }
    
    //phone numbers
    dict = [resultsDictionary objectForKey:@"phoneNumbers"];
    if ([self isValidDictionary:dict]) {
        arr = [dict objectForKey:@"values"];
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [arr objectAtIndex:i];
            NSString *phoneNumber = [dict objectForKey:@"phoneNumber"];
            NSString *phoneType = [dict objectForKey:@"phoneType"];
            
            if (phoneNumber != nil && phoneType !=nil) [self.infoArray addObject:[NSString stringWithFormat:@"%@: %@", phoneType, phoneNumber]];
            else if (phoneNumber !=nil) [self.infoArray addObject:phoneNumber];
        }
    }

    //twitter accounts
    dict = [resultsDictionary objectForKey:@"twitterAccounts"];
    if ([self isValidDictionary:dict]) {
        arr = [dict objectForKey:@"values"];
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [arr objectAtIndex:i];
            NSString *accountName = [dict objectForKey:@"providerAccountName"];
            
            if (accountName !=nil) [self.infoArray addObject:[NSString stringWithFormat:@"Twitter: %@", accountName]];
        }
    }

    //group memberships
    dict = [resultsDictionary objectForKey:@"groupMemberships"];
    if ([self isValidDictionary:dict]) {
        s = [dict description];
        if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) {
            [self.infoArray addObject:[NSString stringWithFormat:@"Group Memberships: %@", s]];
        }
    }

    
}
- (void)linkedInResults_04:(NSDictionary *)resultsDictionary
{
    
    //DEPRECATED
    return;
    
}

- (void)linkedInResults_05:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_05:resultsDictionary"];
    
    //num-recommenders,specialties,proposal-comments,associations,honors,interests
    NSDictionary *dict = nil;
    NSString *s = nil;;
    NSInteger num;
    
    //num-recommenders
    num = [[resultsDictionary objectForKey:@"numRecommenders"] integerValue];
    if (num > 0) [self.infoArray addObject:[NSString stringWithFormat:@"%d recommendations", num]];
    
    //specialties
    s = [resultsDictionary objectForKey:@"specialties"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Specialties: %@", s]];
    
    //proposal-comments
    s = [resultsDictionary objectForKey:@"proposalComments"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Proposal Comments: %@", s]];
    
    //associations
    dict = [resultsDictionary objectForKey:@"associations"];
    if ([self isValidDictionary:dict]) [self.infoArray addObject:[NSString stringWithFormat:@"Associations: %@", s]];
    
    //honors
    s = [resultsDictionary objectForKey:@"honors"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Honors: %@", s]];
    
    //interests
    s = [resultsDictionary objectForKey:@"interests"];
    if (s && ![s isKindOfClass:[NSNull class]] && s.length > 0) [self.infoArray addObject:[NSString stringWithFormat:@"Interests: %@", s]];
    
}
- (void)linkedInResults_06:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_06:resultsDictionary"];
    
    //positions:(company:(name), title, start-date, end-date)
    NSDictionary *dict = nil;
    NSArray *arr = nil;
    //NSInteger num = 0;

    dict = [resultsDictionary objectForKey:@"positions"];
    if ([self isValidDictionary:dict]) {
        arr = [dict objectForKey:@"values"];
        
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [arr objectAtIndex:i];
            if ([self isValidDictionary:dict]) {
                NSInteger startYear = [[[dict objectForKey:@"startDate"] objectForKey:@"year"] integerValue];
                NSString *title = [dict objectForKey:@"title"];
                NSString *company = [[dict objectForKey:@"company"] objectForKey:@"name"];
                
                if (startYear > 0) [self.infoArray addObject:[NSString stringWithFormat:@"%d: %@, %@", startYear, title, company]];
                else [self.infoArray addObject:[NSString stringWithFormat:@"%@, %@", title, company]];
            }
        }
    }
    
}
- (void)linkedInResults_07:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_07:resultsDictionary"];
    
    //publications
    NSDictionary *dict = [resultsDictionary objectForKey:@"publications"];
    if ([self isValidDictionary:dict]) {
        NSArray *arr = [dict objectForKey:@"values"];
        
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [[arr objectAtIndex:i] objectForKey:@"publication"];
            if ([self isValidDictionary:dict]) {
                NSString *s = [dict objectForKey:@"name"];
                if (s != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Publications: %@", s]];
            }
        }
    }
}

- (void)linkedInResults_08:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_08:resultsDictionary"];
    
    //patents
    NSDictionary *dict = [resultsDictionary objectForKey:@"patents"];
    if ([self isValidDictionary:dict]) {
        NSArray *arr = [dict objectForKey:@"values"];
        
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [[arr objectAtIndex:i] objectForKey:@"patent"];
            if ([self isValidDictionary:dict]) {
                NSString *s = [dict objectForKey:@"name"];
                if (s != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Patent: %@", s]];
            }
        }
    }
    
}
- (void)linkedInResults_09:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_09:resultsDictionary"];
    
    //languages
    NSDictionary *dict = [resultsDictionary objectForKey:@"languages"];
    if ([self isValidDictionary:dict]) {
        NSArray *arr = [dict objectForKey:@"values"];
        
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [[arr objectAtIndex:i] objectForKey:@"language"];
            if ([self isValidDictionary:dict]) {
                NSString *s = [dict objectForKey:@"name"];
                if (s != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Language: %@", s]];
            }
        }
    }
    
}
- (void)linkedInResults_10:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_10:resultsDictionary"];
    
    //skills
    NSDictionary *dict = [resultsDictionary objectForKey:@"skills"];
    if ([self isValidDictionary:dict]) {
        NSArray *arr = [dict objectForKey:@"values"];
        
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [[arr objectAtIndex:i] objectForKey:@"skill"];
            if ([self isValidDictionary:dict]) {
                NSString *s = [dict objectForKey:@"name"];
                if (s != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Skill: %@", s]];
            }
        }
    }
    
}
- (void)linkedInResults_11:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_11:resultsDictionary"];
    
    //certifications
    NSDictionary *dict = [resultsDictionary objectForKey:@"certifications"];
    if ([self isValidDictionary:dict]) {
        NSArray *arr = nil;
        
        arr = [dict objectForKey:@"values"];
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [arr objectAtIndex:i];
            if ([self isValidDictionary:dict]) {
                NSString *associationName = [dict objectForKey:@"name"];
                if (associationName != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Association: %@", associationName]];
            }
        }
    }
}
- (void)linkedInResults_12:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_12:resultsDictionary"];
    
    //educations
    NSDictionary *dict = [resultsDictionary objectForKey:@"educations"];
    NSArray *arr = nil;
    
    if ([self isValidDictionary:dict]) {
        arr = [dict objectForKey:@"values"];
        
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [arr objectAtIndex:i];
            if ([self isValidDictionary:dict]) {
                NSString *school = [dict objectForKey:@"schoolName"];
                if (school != nil) {
                    NSString *degree = [dict objectForKey:@"degree"];
                    NSString *field = [dict  objectForKey:@"fieldOfStudy"];
                    NSString *education = nil;
                    
                    //format the education string
                    if (degree != nil) {
                        if (field != nil) education = [NSString stringWithFormat:@"%@ %@, ", degree, field];
                        else education = [NSString stringWithFormat:@"%@, ", degree];
                    }
                    if (education != nil) education = [education stringByAppendingString:school];
                    else education = school;
                    
                    
                    //format date string
                    NSInteger startYear = 0;
                    NSDictionary *startDict = [dict objectForKey:@"startDate"];
                    if ([self isValidDictionary:startDict]) {
                        startYear = [[startDict objectForKey:@"year"] integerValue];
                    }
                    
                    NSInteger endYear = 0;
                    NSDictionary *endDict  = [dict objectForKey:@"endDate"];
                    if ([self isValidDictionary:endDict]) {
                        endYear = [[endDict objectForKey:@"year"] integerValue];
                    }
                    NSString *dateString = nil;
                    
                    if (startYear > 0 && endYear > 0) dateString = [NSString stringWithFormat:@"%d - %d:", startYear, endYear];
                    else {
                        if (startYear > 0) dateString = [NSString stringWithFormat:@"%d - ????:", startYear];
                        if (endYear > 0) dateString =  [NSString stringWithFormat:@"%d:", endYear];
                    }
                    
                    
                    //final formatted education text string
                    if (dateString != nil && education != nil) [self.infoArray addObject:[NSString stringWithFormat:@"%@ %@", dateString, education]];
                    else if (education != nil) [self.infoArray addObject:education];
                    
                }
            }
        }
    }
    
}
- (void)linkedInResults_13:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_13:resultsDictionary"];
    
    //courses
    NSDictionary *dict = [resultsDictionary objectForKey:@"courses"];
    if ([self isValidDictionary:dict]) {
        NSArray *arr = [dict objectForKey:@"values"];
        
        for (NSInteger i = 0; i < arr.count; i++) {
            dict = [[arr objectAtIndex:i] objectForKey:@"course"];
            if ([self isValidDictionary:dict]) {
                NSString *s = [dict objectForKey:@"name"];
                
                if (s != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Course: %@", s]];
            }
        }
    }
    
}
- (void)linkedInResults_14:(NSDictionary *)resultsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"linkedInResults_14:resultsDictionary"];
    
    //volunteer
    NSDictionary *dict = [resultsDictionary objectForKey:@"volunteer"];
    if ([self isValidDictionary:dict]) {
        NSArray *arr = nil;
        
        NSDictionary *causesDict = [dict objectForKey:@"causes"];
        NSDictionary *experiencesDict = [dict objectForKey:@"volunteerExperiences"];

        if ([self isValidDictionary:causesDict]) {
            arr = [causesDict objectForKey:@"values"];
            for (NSInteger i = 0; i < arr.count; i++) {
                dict = [arr objectAtIndex:i];
                if ([self isValidDictionary:dict]) {
                    NSString *s = [dict objectForKey:@"name"];
                    if (s != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Volunteer Causes: %@", s]];
                }
            }
        }
        
        
        if ([self isValidDictionary:experiencesDict]) {
            arr = [experiencesDict objectForKey:@"values"];
            for (NSInteger i = 0; i < arr.count; i++) {
                dict = [arr objectAtIndex:i];
                if ([self isValidDictionary:dict]) {
                    NSDictionary *organizationDict = [dict objectForKey:@"organization"];
                    NSString *organization = nil;
                    if ([self isValidDictionary:organizationDict]) {
                        organization = [organizationDict objectForKey:@"name"];
                    }
                    NSString *role = [dict objectForKey:@"role"];
                    if (organization != nil && role != nil) [self.infoArray addObject:[NSString stringWithFormat:@"Volunteer Experience: %@, %@", role, organization]];
                    else if (organization != nil) [self.infoArray addObject:organization];
                }
            }
        }
    }
}

#pragma mark - LinkedIn Delegate

- (void)executeLinkedInQuery:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeLinkedInQuery:didFinish"];
    [self.integratorLinkedIn setBusy:NO];
    
    if (cachedResultsDictionary) {
        [cachedResultsDictionary release];
        cachedResultsDictionary = nil;
    }
    if (infoArray) {
        [infoArray release];
        infoArray = nil;
    }
    cachedResultsDictionary = [[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] objectFromJSONString] retain];
    [cachedResultsDictionary writeToFile:self.cachePath atomically:YES];
    
    [self linkedInProcessDictionaryResults];
    
}

- (void)executeLinkedInQuery:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeLinkedInQuery:didFail"];
    [self.integratorLinkedIn setBusy:NO];
    
    NSLog(@"%@",[error description]);
}

- (void)executeLinkedInQuery:(NSString *)query
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeLinkedInQuery:query"];
    
    [self.integratorLinkedIn executeLinkedInQuery:[NSURL URLWithString:query] delegate:self didFinishSelector:@selector(executeLinkedInQuery:didFinish:) didFailSelector:@selector(executeLinkedInQuery:didFail:)];
    
}

#pragma mark - LGDataModelManagedObjectDelegate
/*=====================================================================================================================================================
 *
 * LGDataModelManagedObjectDelegate: called by our person object when an image is ready to be displayed
 *
 *=====================================================================================================================================================*/
- (void)thumbnailImageDidLoad:(UIImage *)thumbnailImage
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"thumbnailImageDidLoad()"];
    
    self.imageView.image = thumbnailImage;
    [self.imageView setNeedsDisplay];
    
    if (self.person) [self.person resetIntegrators];
    if (self.checkin) [self.checkin resetIntegrators];
    if (self.mapItem) [self.mapItem resetIntegrators];
    
}



#pragma mark - UITableViewDataSource Protocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableView:cellForRowAtIndexPath()"];
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mytableviewcell"] autorelease];
    
    cell.textLabel.text = [self.infoArray objectAtIndex:[indexPath indexAtPosition:1]];
    cell.imageView.image = nil;
    
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;                       //this causes number of lines to be calculated automatically
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
    return @"About this LinkedIn Contact:";
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
- (void)viewDidLoad
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidAppear()"];
    
    if (self.person) self.imageView.image = self.person.thumbnailImage;
    if (self.checkin) self.imageView.image = self.checkin.thumbnailImage;
    if (self.mapItem) self.imageView.image = self.mapItem.thumbnailImage;
    if (self.imageView.image == nil) self.imageView.image = [LGAppDataFeed imageForDataFeedTypeLarge:LGDataFeedTypeLinkedIn];

    if (self.cachedResultsDictionary == nil) [self linkedInQuery];
    else [self linkedInProcessDictionaryResults];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithNibName:nibNameOrNil()"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    if (OBJECT_DEBUG) [self logObjectVariables:@"didReceiveMemoryWarning()"];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initwithPerson:(Person *)person
{
    if (self = [super initWithNibName:@"LGDetailViewController_LinkedIn" bundle:nil]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initwithPerson()"];
        self.person = person;
        self.person.delegate = self;
        self.linkedInID = self.person.unique_id;
        nameLabel.text = self.person.name;

    }
    return self;
}
- (id)initWithCheckin:(Checkin *)checkin
{
    if (self = [super initWithNibName:@"LGDetailViewController_LinkedIn" bundle:nil]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithCheckin()"];
        self.checkin = checkin;
        self.checkin.delegate = self;
        self.linkedInID = self.checkin.unique_id;
    }
    return self;
}
- (id)initWithMapItem:(MapItem *)mapItem
{
    if (self = [super initWithNibName:@"LGDetailViewController_LinkedIn" bundle:nil]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithMapItem()"];
        self.mapItem = mapItem;
        self.mapItem.delegate = self;
        self.linkedInID = self.mapItem.unique_id;
    }
    return self;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidUnload()"];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    linkedInID = nil;
    cachedResultsDictionary = nil;
    infoArray = nil;
    tableview = nil;
    nameLabel = nil;
    headlineLabel = nil;
    imageURLString = nil;
    imageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];

    [linkedInID release];
    [cachedResultsDictionary release];
    [infoArray release];
    [tableview release];
    [nameLabel release];
    [headlineLabel release];
    [imageURLString release];
    [imageView release];

    [super dealloc];
    
}
@end
