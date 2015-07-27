//
//  OAuthLoginViewLinkedIn.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"



@interface OAuthLoginViewLinkedIn : UIViewController
{
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITextField *addressBar;
    
    OAToken *requestToken;
    OAToken *accessToken;
    
    NSDictionary *profile;
    
    // Theses ivars could be made into a provider class
    // Then you could pass in different providers for Twitter, LinkedIn, etc
    NSString *apikey;
    NSString *secretkey;
    NSString *requestTokenURLString;
    NSURL *requestTokenURL;
    NSString *accessTokenURLString;
    NSURL *accessTokenURL;
    NSString *userLoginURLString;
    NSURL *userLoginURL;
    NSString *linkedInCallbackURL;
    OAConsumer *consumer;
}

@property(nonatomic, retain) OAToken *requestToken;
@property(nonatomic, retain) OAToken *accessToken;
//@property(nonatomic, retain) NSDictionary *dictLinkedIn;
@property (nonatomic, assign) id delegate;



- (void)initLinkedInApi;
- (void)requestTokenFromProvider;
- (void)allowUserToLogin;
- (void)accessTokenFromProvider;

@end
