//
//  LGActivityIndicatorView.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>


@implementation LGActivityIndicatorView

@synthesize isBusy = _isBusy;


-(void)startWithMessage:(NSString *)message
{
//    if (OBJECT_DEBUG) [self logObjectVariables:@"indicatorStartWithMessage()"];
    
    if (self.isBusy) [self stop];
    
    _isBusy = YES;
    
    UILabel *indicatorTitle         = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, self.bounds.size.width-6, 15)];
    indicatorTitle.tag              = 1000;
    indicatorTitle.textColor        = [UIColor whiteColor];
    indicatorTitle.backgroundColor  = [UIColor blackColor];
    indicatorTitle.opaque           = YES;
    indicatorTitle.font             = [UIFont boldSystemFontOfSize:12];
    indicatorTitle.textAlignment    = UITextAlignmentCenter;
    indicatorTitle.text             = [message copy];
    
    [self addSubview:indicatorTitle];
    [indicatorTitle release];
    
    if (self.isAnimating) [self stopAnimating];
    [self startAnimating];
    self.hidden = NO;
    
}

-(void)stop
{
//    if (OBJECT_DEBUG) [self logObjectVariables:@"indicatorStop()"];
    
    if (self.isAnimating) [self stopAnimating];
    if (!self.isBusy) return;
    
    for (UIView *view in self.subviews) {
        if ([view respondsToSelector:@selector(tag)]) {
            if (view.tag == 1000) [view removeFromSuperview];
        }
    }
    _isBusy = NO;
    
}

-(id)init
{
	self = [super initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	if(self != nil)
	{
        self.frame                = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50, [UIScreen mainScreen].bounds.size.height/2 - 50, 100, 100);
        self.backgroundColor      = [UIColor blackColor];
        self.opaque               = NO;
        self.alpha                = .4;
        self.tag                  = 1;
        self.hidesWhenStopped     = YES;
        self.layer.cornerRadius   = 7.5;
        [self.layer setMasksToBounds:YES];
        self.hidden               = YES;
        
        _isBusy                   = NO;
    
    }
	return self;
}


@end
