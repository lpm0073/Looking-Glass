//
//  LGTVCCheckinsByPerson.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGCoreDataTVC.h"
#import "Person.h"

@interface LGTVCCheckinsByPerson : LGCoreDataTVC <LGDataModelManagedObjectDelegate>

@property (nonatomic, retain) Person *person;

- (LGTVCCheckinsByPerson *)initWithPerson:(Person *)thisPerson;


@end
