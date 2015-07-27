//
//  LGAppIntegratorAddressBook.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGAppDataFeed.h"
#import <AddressBook/AddressBook.h>

@interface LGAppIntegratorAddressBook : LGAppDataFeed <LGAppDataFeed>


- (void)authorizeAddressBook;

+ (NSDictionary *)addressDictionaryForID:(NSString *)person_id;
+ (NSDictionary *)addressDictionaryForID:(NSString *)person_id atIndex:(CFIndex)addressIndex;

@end
