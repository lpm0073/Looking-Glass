//
//  LGAppIntegratorLinkedIn.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


/*====================================================================================================
 Your LinkedIn APP Id must be set before running this example
 See https://www.linkedin.com/secure/developer                                      -- Home page
     https://developer.linkedin.com/forum/getting-started-linkedin-api-read-first   -- Geting Started Guide
     http://developer.linkedinlabs.com/rest-console/                                -- to test url and OAuth schemes
     https://developer.linkedin.com/documents/oauth-overview                        -- API documentation
 
 
 
 About LinkedIn's implementation of OAuth Authentication Flow (based on version v1.0a):
 =====================================================================================================
 The OAuth Flow
 
 We follow the OAuth 1.0a flow:
 
 You, the developer (aka the "consumer") requests an API (or consumer) key from us, LinkedIn (aka the "provider")
 A. When your application needs to authenticate the member (aka the "user"), your application makes a call to LinkedIn to ask for a request token
 B. LinkedIn replies with a request token. Request tokens are used to ask for user approval to the API.
 C. Your application redirects the member to LinkedIn to sign-in and authorize your application to make API calls on their behalf. You provide us with a URL where we should send them afterward (aka the "callback")
 D. If the member agrees, LinkedIn returns them to the location specified in the callback
 E. Your application then makes another OAuth call to LinkedIn to retrieve an access token for the member
 F. LinkedIn returns an access token, which has two parts: the oauth_token and oauth_token_secret.
 G. After retrieving the access token, you can make API calls, signing them with the consumer key and access token
 More information about the OAuth flow can be found on the OAuth standards site at http://www.oauth.org
 
 This diagram, by LinkedIn member Idan Gazit, details the OAuth 1.0a flow: https://developer.linkedin.com/sites/default/files/Oauth_diagram.png
 
 
 
 The site: https://api.linkedin.com.
 Request token path: /uas/oauth/requestToken
 Access token path: /uas/oauth/accessToken
 SSL is required for all authentication steps.
 
 1. Standard Authorization Path: https://www.linkedin.com/uas/oauth/authorize
 
 Getting an OAuth Token: 
  - Request a requestToken: https://api.linkedin.com/uas/oauth/requestToken
  - Redirect the Member to our Authorization Server
  - Request the Access Token: https://api.linkedin.com/uas/oauth/accessToken
  - As a response to your request for an accessToken, your accessToken will be in the "oauth_token" field and an oauth_token_secret.
    Example Response:
 
 
 Getting your response in XML or JSON
 By default, the LinkedIn REST APIs return XML. For a JSON response there are two different methods you can use:
 
 The preferred method is setting the "x-li-format" HTTP header to "json".
 The second method is appending ?format=json to the request URL. This is sometimes easier, but may cause issues with certain types of requests.
 
 PHP sample: response = make_request(client,"http://api.linkedin.com/v1/people/~",{"x-li-format":'json'})
 
 
 About the specific open-source OAuth library used in Looking Glass:
 ===================================================================
 additional info about these two values: https://www.linkedin.com/secure/developer
 as well as: http://www.whitneyland.com/2011/03/iphone-oauth.html
 and sample project: OAuthStarterKit

 If you have feedback it's welcome.
 You can contact me via whitneyland.com (it may redirect to lee.hdgreetings.com).
 I can also be contacted via the public LinkedIn web site (Lee Whitney).
 
 Credits:
 
 The OAuth library used is derived from the OAuthConsumer project.
 Some changes were made but it's mostly intact.
 http://code.google.com/p/oauthconsumer/wiki/UsingOAuthConsumer
 
 The JSON library used is JSONKit by John Engelhart.
 https://github.com/johnezang/JSONKit
 
 Icons are from Eran Hammer-Lahav's site at http://hueniverse.com/oauth.
 

 
 *===============================================================================================*/
#import <Foundation/NSNotificationQueue.h>
#import "LGAppIntegratorLinkedIn.h"
#import "Person.h"
#import "MapItem.h"
#import "Checkin.h"
#import "OAuthLoginViewLinkedIn.h"          // LinkedIn authentication

#define kIMPORT_BATCH_LIMIT 100

static NSString* kLIAPIKey = @"1aoizcjiws7b";
static NSString* kLISecretKey = @"qvlvN76lECqBMaMe";

@interface LGAppIntegratorLinkedIn()

@property (nonatomic, retain) OAuthLoginViewLinkedIn *linkedInOAuthLoginView;

@end

@implementation LGAppIntegratorLinkedIn

@synthesize dictLinkedIn;
@synthesize accessToken;
@synthesize consumer;
@synthesize linkedInOAuthLoginView;

- (void)executeLinkedInQuery:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeLinkedInQuery:didFinish"];
    [self setBusy:NO];

    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    self.dictLinkedIn = [responseBody objectFromJSONString];
    self.dictLinkedIn = [self.dictLinkedIn objectForKey:@"values"];
    
    [responseBody release];
    
    dispatch_queue_t myQueue = dispatch_queue_create("my queue", NULL);
    dispatch_barrier_async(myQueue, ^
                   {
                       [self.appDelegate.managedObjectContext lock];
                       [self processLinkedInConnectionsDictionary];
                       [self.appDelegate.managedObjectContext unlock];
                   });
    dispatch_release(myQueue);
    

    
}

- (void)executeLinkedInQuery:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeLinkedInQuery:didFail"];
    [self setBusy:NO];

    NSLog(@"%@",[error description]);
}


- (void)executeLinkedInQuery:(NSURL *)url delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"executeLinkedInQuery()"];
    [self setBusy:YES];

    if (!aDelegate) aDelegate = self;
    if (!finishSelector) finishSelector = @selector(executeLinkedInQuery:didFinish:);
    if (!failSelector) failSelector = @selector(executeLinkedInQuery:didFail:);
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:self.accessToken
                                                                   callback:nil
                                                          signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:aDelegate
                didFinishSelector:finishSelector
                  didFailSelector:failSelector
     ];
    
    [request release];
}

/*
- (NSOperation *)processLinkedInConnectionsDictionaryOperation
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processLinkedInConnectionsDictionaryOperation()"];

    NSInvocationOperation *theOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(processLinkedInConnectionsDictionary) object:nil] autorelease];
    return theOp;
}
*/

- (void)processLinkedInConnectionsDictionary
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"processLinkedInConnectionsDictionary()"];

    if (!dictLinkedIn) return;
    
    float results = dictLinkedIn.count;
    float i = 0;
    NSInteger iBatchCount = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setBusy:YES];
    });


    for (NSDictionary *connection in dictLinkedIn) {
        if (!self.didCancelRequest) {
            i++;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:i / results];
            });

            NSString *linkedInID = [[connection objectForKey:@"id"] copy];
            
            if (![[linkedInID lowercaseString] isEqual:@"private"]) {
                
                //see Core Data Programming Guide page 152 for details on this pattern. this is intended to reduce the memory footprint of large imports
                if (iBatchCount == kIMPORT_BATCH_LIMIT) {
                    [self.appDelegate saveContext];
                    
                    [pool drain];
                    pool = [[NSAutoreleasePool alloc] init];
                    
                    iBatchCount = 0;
                }

                //==============================================================================================
                // Person
                //==============================================================================================
                Person *thisPerson          = [[self PersonForPersonID:linkedInID] retain];
                thisPerson.datafeedtype_id  = [NSNumber numberWithInt:self.dataFeedType];
                thisPerson.isfacebookfriend = NO;
                thisPerson.first_name       = [connection objectForKey:@"firstName"];
                thisPerson.last_name        = [connection objectForKey:@"lastName"];
                thisPerson.name             = [NSString stringWithFormat:@"%@ %@", thisPerson.first_name, thisPerson.last_name];
                thisPerson.thumbnailurl     = [connection objectForKey:@"pictureUrl"];
                thisPerson.title            = [connection objectForKey:@"headline"];
                
                thisPerson.name              = [NSString stringWithFormat:@"%@ %@", thisPerson.first_name, thisPerson.last_name];
                thisPerson.tableCellTitle    = thisPerson.name;
                thisPerson.tableCellSubTitle = thisPerson.title;
                
                
                //==============================================================================================
                // MapItem
                //==============================================================================================
                MapItem *mapItem            = [[self MapItemForMapItemID:thisPerson.unique_id] retain];
                mapItem.datafeedtype_id     = [NSNumber numberWithInt:self.dataFeedType];
                mapItem.timestamp           = [NSDate date];
                mapItem.title               = thisPerson.name;
                mapItem.geocodeaccuracy     = [NSNumber numberWithInt:LGMapItemGeocodeAccuracy_None];
                mapItem.thumbnailurl        = thisPerson.thumbnailurl;
                
                NSDictionary *locationDictionary = [[connection objectForKey:@"location"] retain];
                
                NSString *locationString = [locationDictionary objectForKey:@"name"];
                locationString = [locationString stringByReplacingOccurrencesOfString:@" Area" withString:@""];
                locationString = [locationString stringByReplacingOccurrencesOfString:@"Greater " withString:@""];
                
                mapItem.city                = [locationString uppercaseString];
                mapItem.country             = [[[locationDictionary objectForKey:@"country"] objectForKey:@"code"] uppercaseString];
                
                [locationDictionary release];
                
                //==============================================================================================
                // Checkin
                //==============================================================================================
                Checkin *checkin          = [[self CheckinForCheckinID:thisPerson.unique_id] retain];
                checkin.comment           = nil;
                checkin.create_date       = [NSDate date];
                checkin.datafeedtype_id   = [NSNumber numberWithInt:self.dataFeedType];
                checkin.thumbnailurl      = thisPerson.thumbnailurl;
                
                //relationships....
                checkin.Checkin_Person    = thisPerson;        
                checkin.Checkin_Mapitem   = mapItem;
                
                [checkin release];
                [thisPerson release];
                [mapItem release];
            }
            
            //[linkedInID release];            
        } else break;        
    }

    //memory management stuff.
    [self.appDelegate saveContext];
    [pool drain];

    if (!self.didCancelRequest) {
        self.getPeopleTimeStamp = [NSDate date];
        
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(didGetPeople)]) {
                
                [self.delegate didGetPeople];
                
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setBusy:NO];
    });

}


-(void) linkedInloginViewDidFinish:(NSNotification*)notification
{
    [self.appDelegate.navigationController dismissViewControllerAnimated:YES completion:^(void) {
        [self.linkedInOAuthLoginView release];
        self.linkedInOAuthLoginView = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }];
}




#pragma mark - LGAppDataFeed Protocol
/*
- (void)EnableDataFeed
{
    [super EnableDataFeed];
    
}
- (void)DisableDataFeed
{
    [super DisableDataFeed];
    
}
*/


- (BOOL)getPeoplewithCycleTest:(BOOL)test
{
    if (!self.canProcessRequest) return NO;
    if ([super getPeoplewithCycleTest:test]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"getPeoplewithCycleTest()"];
        
        NSNumber *num =  [NSNumber numberWithLongLong: fmaxl(0, 1000 * [self.getPeopleTimeStamp timeIntervalSince1970])];
        
        NSString *predicate = [NSString stringWithFormat:@"?modified-since=%@", [num stringValue]];  //convert time interval from seconds to miliseconds
        NSString *urlString = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,location:(name,country:(code)),headline,main-address,picture-url)%@", predicate];

        [self executeLinkedInQuery:[NSURL URLWithString:urlString] delegate:nil didFinishSelector:nil didFailSelector:nil];
        
        return YES;
    }
    return NO;
}


#pragma mark - object lifecycle

- (void)authorizeLinkedIn
{
    self.linkedInOAuthLoginView = [[OAuthLoginViewLinkedIn alloc] initWithNibName:nil bundle:nil];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(linkedInloginViewDidFinish:) 
                                                 name:@"linkedInDidLogin" 
                                               object:self.linkedInOAuthLoginView];
    
    [self.appDelegate.navigationController presentModalViewController:self.linkedInOAuthLoginView animated:YES];
    
}

- (LGAppIntegratorLinkedIn *)init
{
    if (self = [super initWithDataFeedType:LGDataFeedTypeLinkedIn]) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"init()"];

        
        self.consumer = [[OAConsumer alloc] initWithKey:kLIAPIKey
                                            secret:kLISecretKey
                                             realm:@"http://api.linkedin.com/"];
        
        NSString *token;
        NSString *secret; 
        NSUserDefaults *defaults = [[NSUserDefaults standardUserDefaults] retain];
        if ([defaults objectForKey:@"LIAccessTokenKey"] && [defaults objectForKey:@"LIAccessTokenSecret"]) {
            token = [defaults objectForKey:@"LIAccessTokenKey"];
            secret = [defaults objectForKey:@"LIAccessTokenSecret"]; 
            self.accessToken = [[OAToken alloc] initWithKey:token secret:secret];
        } else {
            [self authorizeLinkedIn];
        }
        [defaults release];

    }
    return self;
}

- (void)dealloc
{
    [dictLinkedIn release];
    [accessToken release];
    [consumer release];
    if (linkedInOAuthLoginView) [linkedInOAuthLoginView release];
    
    [super dealloc];
    
}

@end
