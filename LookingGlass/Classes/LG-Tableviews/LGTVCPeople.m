//
//  LGTVCPeople.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGTVCPeople.h"
#import "LGTVCCheckinsByPerson.h"
#import "LGDetailViewController_LinkedIn.h"


@interface LGTVCPeople()
{
    NSInteger distanceForQuery;
}

@end


@implementation LGTVCPeople

@synthesize location;

/*=====================================================================================================================================================
 *
 * setters and getters
 *
 *=====================================================================================================================================================*/



#pragma mark - ManagedObject
/*=====================================================================================================================================================
 *
 * Managed Object
 *
 *=====================================================================================================================================================*/
- (LGTableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"tableView:cellForManagedObject()"];
    
    LGTableViewCell *cell = [super tableView:tableView cellForManagedObject:managedObject];
    cell.person           = (Person *)managedObject;
    
    return cell;
}



#pragma mark - Core Data stack
/*=====================================================================================================================================================
 *
 * Managed Object Delegate
 *
 *=====================================================================================================================================================*/

/*
- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"managedObjectSelected()"];
    
    
}
*/


#pragma mark - ViewController life cycle
- (void)doRefresh:(id)sender
{
    [super doRefresh:sender];
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"doRefresh:sender()"];
    
}

- (void)doPushNextView
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"doPushNextView()"];
    if (!self.person) return;

    [super doPushNextView];
    
    switch (self.person.dataFeedType) {
        case LGDataFeedTypeLinkedIn:
        {
            LGDetailViewController_LinkedIn *vc = [[LGDetailViewController_LinkedIn alloc] initwithPerson:self.person];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            break;
        }
            
        default:
        {
            LGTVCCheckinsByPerson *cbptvc = [[LGTVCCheckinsByPerson alloc] initWithPerson:self.person];
            cbptvc.title                  = self.person.name;
            
            [self.navigationController pushViewController:cbptvc animated:YES];
            [cbptvc release];
            break;
        }
    }
    
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (OBJECT_DEBUG) [self logObjectVariables:@"viewDidLoad()"];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.title = NSLocalizedString(@"LGTVCPeople_Title", @"People");
    
    self.titleKey       = @"tableCellTitle";
    self.subtitleKey    = @"tableCellSubTitle";
    self.searchKey      = @"name";
    
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    self.fetchedResultsController   = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES
                                                                                      selector:@selector(caseInsensitiveCompare:)]];
    
    request.fetchBatchSize = 50;
    
    if (!self.location) {
        request.predicate = [NSPredicate predicateWithFormat:@"((isfacebookfriend == 1) OR (datafeedtype_id != 1))"];
    } else {
        if (distanceForQuery == 0) distanceForQuery = kLGNEARBYPLACES_QUERY_RANGE;
        request.predicate = [NSPredicate predicateWithFormat:@"distancefromlastlocation >= 0 AND distancefromlastlocation <= %d", distanceForQuery];
    }
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:self.context
                                     sectionNameKeyPath:@"firstLetterOfName"
                                     cacheName:nil];
    
    [request release];

    
}

- (void)viewDidUnload
{
    location = nil;
    
    [super viewDidUnload];
}


- (id)init
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"init()"];
	}
	return self;
}

-(void)dealloc
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"dealloc()"];
    
    [location release];
    
    [super dealloc];
}



@end
