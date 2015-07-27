//
//  LGMessageBoxView.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGMessageBoxView : UIView

@property (retain, readonly) UILabel *textLabel;
@property (nonatomic, readonly) BOOL isDisplaying;

- (void)show:(NSString *)message;

@end
