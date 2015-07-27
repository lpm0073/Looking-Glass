//
//  LGAppIntegratorFacebook.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGAppDataFeed.h"
#import "FBConnect.h"



@interface LGAppIntegratorFacebook: LGAppDataFeed <LGAppDataFeed, FBRequestDelegate, FBSessionDelegate>

@property (nonatomic, retain) Facebook *facebook;

- (BOOL)executeGraphRequest:(NSString *)graphPath Parameters:(NSMutableDictionary *)parameters Delegate:(id<FBRequestDelegate>)delegate;
- (void)authorizeFacebook;

@end

