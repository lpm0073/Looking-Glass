//
//  LGMessageBoxView.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGMessageBoxView.h"
#import <QuartzCore/QuartzCore.h>


@implementation LGMessageBoxView

@synthesize textLabel = _textLabel;
@synthesize isDisplaying = _isDisplaying;


-(void)text:(NSString *)newText
{
    _textLabel.text = [newText copy];
    [_textLabel setNeedsDisplay];
}


- (void)show:(NSString *)message
{
//    if (OBJECT_DEBUG) [self logObjectVariables:@"showMessageBox()"];
    
    if (self.isDisplaying) return;
    _isDisplaying = YES;
    
        self.textLabel.text  = [message copy];
        self.alpha           = 1;
        
        CGRect startFrame           = self.frame;      //this sets the message box coordinates off-screen (eg, above the viewable bounds
        startFrame.origin.x         = 3;
        startFrame.origin.y         = [UIScreen mainScreen].applicationFrame.size.height + 20;
        self.frame       = startFrame;
        self.hidden      = NO;
        
        [UIView animateWithDuration:1.5 animations:^{
            CGRect newFrame = self.frame;
            newFrame.origin.y = newFrame.origin.y - 33.0;
            self.frame = newFrame;
        }
                         completion:^ (BOOL finished) {
                             if (finished) {
                                 // Revert view to original offscreen location.
                                 sleep(1.5);
                                 [UIView animateWithDuration:1.5 animations:^{
                                     CGRect newFrame = self.frame;
                                     newFrame.origin.y = newFrame.origin.y + 33.0;
                                     self.frame = newFrame;
                                 }];  
                                 
                             }  
                         }];        
    _isDisplaying = NO;
}


-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self != nil)
	{
		//self.backgroundColor = [UIColor blackColor];
		self.opaque = NO;
        self.alpha = 1.0;
		self.clearsContextBeforeDrawing = YES;
        self.layer.cornerRadius = 7.5;
        [self.layer setMasksToBounds:YES];
        self.clipsToBounds = YES;
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.userInteractionEnabled = NO;
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _textLabel.tag = 1000;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.backgroundColor = [UIColor blackColor];
        _textLabel.opaque = NO;
        _textLabel.alpha = .35;
        _textLabel.font = [UIFont boldSystemFontOfSize:12];
        _textLabel.textAlignment = UITextAlignmentCenter;
        _textLabel.layer.cornerRadius = self.layer.cornerRadius;
        [_textLabel.layer setMasksToBounds:YES];
        
        [self addSubview:_textLabel];
        self.hidden = YES;
    }
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [_textLabel release];
    [super dealloc];
}
@end
