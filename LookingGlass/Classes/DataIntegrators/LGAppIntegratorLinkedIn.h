//
//  LGAppIntegratorLinkedIn.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGAppDataFeed.h"
#import "JSONKit.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"


@interface LGAppIntegratorLinkedIn : LGAppDataFeed <LGAppDataFeed>

@property (nonatomic, retain) OAToken *accessToken;
@property (nonatomic, retain) OAConsumer *consumer;
@property (nonatomic, retain) NSDictionary *dictLinkedIn;

- (void)executeLinkedInQuery:(NSURL *)url delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
//- (NSOperation *)processLinkedInConnectionsDictionaryOperation;
- (void)processLinkedInConnectionsDictionary;

- (void)authorizeLinkedIn;

@end
