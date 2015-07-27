//
//  LGActivityIndicatorView.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGActivityIndicatorView : UIActivityIndicatorView

@property (readonly) BOOL isBusy;

- (void)startWithMessage:(NSString *)message;
- (void)stop;

@end
