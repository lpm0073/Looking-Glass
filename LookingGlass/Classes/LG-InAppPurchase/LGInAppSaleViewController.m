//
//  LGInAppSaleViewController.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGInAppSaleViewController.h"
#import "LGTVCPeople.h"
#import "LGAppDelegate.h"
#import "LGInAppCheckoutViewController.h"
#import <QuartzCore/QuartzCore.h>


#define reflectionFraction .35
#define reflectionOpacity .5

#define ICON_WIDTH 150
#define ICON_HEIGHT 150

@interface LGInAppSaleViewController()
{
    LGAppDelegate *appDelegate;
}

@property (nonatomic) BOOL isShoppingCartDisplaying;
@property (nonatomic, retain) LGAppDelegate *appDelegate;
@property (nonatomic, retain) AVAudioPlayer *cashRegisterAudioPlayer;

- (void)logObjectVariables:(NSString *)suffix;
- (void)doGoToCheckout;
- (void)doAddToCartButton;
- (void)doRemoveFromCartButton;
- (void)showAnimatedShoppingCart;

//- (NSString *)priceTextForDataFeedType;
- (NSString *)advertLabelTextForDataFeedTypeId;


@end


@implementation LGInAppSaleViewController

@synthesize isShoppingCartDisplaying;
@synthesize cashRegisterAudioPlayer;

@synthesize goToCheckoutButton;
@synthesize addToCartButton;
@synthesize removeFromCartButton;

@synthesize priceLable;
@synthesize advertLabel;

@synthesize shoppingCartImageView;
@synthesize iconImageView; 
@synthesize reflectionView; 
@synthesize dataFeedType;
@synthesize appDelegate;

#pragma mark - Setters and Getters
- (AVAudioPlayer *)cashRegisterAudioPlayer
{
    if (!cashRegisterAudioPlayer) {
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        resourcePath = [resourcePath stringByAppendingString:@"/cash_register.wav"];
        NSError* err;
        
        //Initialize our player pointing to the path to our resource
        cashRegisterAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:resourcePath] error:&err] retain];
        cashRegisterAudioPlayer.delegate = self;
        cashRegisterAudioPlayer.volume = 0.50f;
    }
    return cashRegisterAudioPlayer;
    
}

- (UIImageView *)shoppingCartImageView
{
    if (!shoppingCartImageView) {
        [self logObjectVariables:@"shoppingCartImageView()"];

        //running_man
        shoppingCartImageView = [[[UIImageView alloc] initWithImage:[LGAppDataFeed Image:[UIImage imageNamed:@"shopping-cart.png"] Pixels:75]] retain];
        [self.view addSubview:shoppingCartImageView];
        
    }
    return shoppingCartImageView;
}



- (void)showAnimatedShoppingCart
{
    [self logObjectVariables:@"showAnimatedShoppingCart()"];
    
    if (self.isShoppingCartDisplaying) return;
    isShoppingCartDisplaying = YES;
    [self.cashRegisterAudioPlayer prepareToPlay];   //buffer our cash register sound
    
    float timeFactor = 1.0f;                // for debugging. use this factor to increase the duration of all animations in this method.
    float iconImageShrinkFactor = 0.25f;    // overall reduction to size of data feed icon while slingshotting.
    

    [self.reflectionView removeFromSuperview];  // we're finished with data feed icon image reflection, so remove from the view.
    
    //move shopping cart from off-screen on the right-hand side, to the center of the screen -- sliding just above the toolbar.
    CGRect startFrame                   = self.shoppingCartImageView.frame;      //this sets the message box coordinates off-screen (eg, above the viewable bounds
    startFrame.origin.x                 = self.view.frame.size.width;           //cart is initially off screen, on the right-hand side.
    startFrame.origin.y                 = self.view.frame.size.height - self.shoppingCartImageView.frame.size.height;
    self.shoppingCartImageView.frame    = startFrame;
    
    
    CGRect newFrame = self.shoppingCartImageView.frame;
    newFrame.origin.x = (self.view.frame.size.width - self.shoppingCartImageView.frame.size.width) * 0.5f;

    [self.cashRegisterAudioPlayer play];       //play the cash register sound.
    
    //Animation set #1 causes data feed icon to pulse 1 time.
    [UIView animateWithDuration:0.25f animations:^{
     
        self.iconImageView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25f animations:^{
            
            self.iconImageView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
        
        
            //================================================================================================================================================
            // Animation set #2, shrinks the data feed icon image. runs concurrent with animation set #3.
            //================================================================================================================================================
            [UIView animateWithDuration:1.0 * timeFactor animations:^{
                //Reduce the size of the data feed image
                self.iconImageView.transform = CGAffineTransformMakeScale(iconImageShrinkFactor, iconImageShrinkFactor);
            }];

            
            //================================================================================================================================================
            //Animation set #3 to move shopping cart across the screen, right to left, with a brief pause to catch the data feed icon before finally moving offscreen
            //This is a 4.5 second cycle in total
            //================================================================================================================================================
            [UIView animateWithDuration:0.75 * timeFactor animations:^{
                self.shoppingCartImageView.frame = newFrame;
            }
                             completion:^ (BOOL finished) {
                                 if (finished) {
                                     
                                     [self.iconImageView removeFromSuperview];  //we're done with the data feed icon, so remove from view.

                                     //pause for effect
                                     sleep(0.5 * timeFactor);
                                     
                                     
                                     [UIView animateWithDuration:0.25 * timeFactor animations:^{
                                         
                                         // push shopping cart off the screen entirely.
                                         CGRect newFrame = self.shoppingCartImageView.frame;
                                         newFrame.origin.x = 0 - self.shoppingCartImageView.frame.size.width;
                                         self.shoppingCartImageView.frame = newFrame;
                                         
                                     } completion:^(BOOL finished) {
                                         sleep(0.75f * timeFactor);
                                         [self.cashRegisterAudioPlayer stop];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     } 
                                      ];  
                                     
                                 }  
                             }
             ];
            //================================================================================================================================================
            //================================= END OF ANIMATAION SET #3                                ======================================================
            //================================================================================================================================================
            
            //================================================================================================================================================
            // Animation set #4, slingshot the data feed icon into the shopping cart.
            //================================================================================================================================================
            /*================================================================================================================================================
             The extra points are the bezier control points for the curve out of the source (current) point and the curve into the target point. 
             The line currentX,currentY - cp1x,cp1y is the vector 'out' of the current point and cp2x,cp2y - x,y is the vector 'in' to the final point.
             
             A reasonable way to produce a smooth curve from p1 to p2 (assuming 4 points p0,p1,p2,p3) is:
             
             v = (strength of curve from 0.0 to 1.0)
             
             cp1x = p1.x + v * (p1.x - p0.x)
             cp1y = p1.y + v * (p1.y - p0.y)
             cp2x = p2.x - v * (p3.x - p2.x)
             cp2y = p2.y - v * (p3.y - p2.y)
             
             For the starting point, set cp1x,cp1y to the starting x,y and for the ending point set cp2x,cp2y to the ending x,y.
             
             ================================================================================================================================================*/
            CGFloat v = 1.0;   // value 0 to 1.0
            
            //current data feed icon position
            CGPoint p0 = self.iconImageView.layer.position;
            
            //point to move towards (when initially moving away from p0)
            CGPoint p1 = CGPointMake(p0.x - 100, p0.y - 100);
            
            //point to move towards (as an approach to final position)
            CGPoint p2 = CGPointMake(p0.x + 200, p0.y + 75);
            
            //final destination
            CGPoint p3 = CGPointMake(
                                     self.shoppingCartImageView.center.x - (self.iconImageView.frame.size.width * iconImageShrinkFactor)/2,
                                     self.shoppingCartImageView.center.y - (self.iconImageView.frame.size.height * iconImageShrinkFactor)/2
                                     );
            
            
            CGPoint cp1 = CGPointMake(p1.x + v*(p1.x - p0.x), p1.y+v*(p1.y-p0.y));
            CGPoint cp2 = CGPointMake(p2.x-v*(p3.x-p2.x), p2.y-v*(p3.y-p2.y));
            
            CGMutablePathRef thePath = CGPathCreateMutable();
            CGPathMoveToPoint(thePath, NULL, p0.x, p0.y);
            CGPathAddCurveToPoint(thePath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, p3.x, p3.y);
            
            CAKeyframeAnimation *animation  = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.duration              = 0.75f * timeFactor;
            animation.path                  = thePath;
            animation.calculationMode       = kCAAnimationPaced;
            
            // Important: you must actually set the layer's position! Otherwise the animation will put it back at the start when the animation ends.  
            // You should set the layer's final position, then add the animation.
            //self.iconImageView.layer.position = position;
            self.iconImageView.layer.position = p3;
            [self.iconImageView.layer addAnimation:animation forKey:@"position"];
            //================================================================================================================================================
            //============================================ END OF ANIMATION SET #4 ===========================================================================
            //================================================================================================================================================
        
        }
         ];
        
    }
     ];



    isShoppingCartDisplaying = NO;
}


#pragma mark - IB Outlets and Actions
- (void)doGoToCheckout
{
    [self logObjectVariables:@"doGoToCheckout()"];
    
    LGInAppCheckoutViewController *vc = [[LGInAppCheckoutViewController alloc] initWithNibName:@"LGInAppCheckoutViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}

- (void)doAddToCartButton
{
    
    [self logObjectVariables:@"doAddToCartButton()"];
    if ([LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType])  return;
    
    [LGAppDataFeed addToCartDataFeedType:self.dataFeedType];
    [self showAnimatedShoppingCart];
    
}
- (void)doRemoveFromCartButton
{
    
    [self logObjectVariables:@"doRemoveFromCartButton()"];
    if ([LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType])  return;
    
    [LGAppDataFeed removeFromCartDataFeedType:self.dataFeedType];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

#pragma mark - View lifecycle

- (void)loadView {	
    
    [super loadView];
    
    [self logObjectVariables:@"loadView()"];
    
    iconImageView                   = nil;
    reflectionView                  = nil;
    self.hidesBottomBarWhenPushed   = YES;
    self.appDelegate                = (LGAppDelegate *)[UIApplication sharedApplication].delegate;

    self.title = [LGAppDataFeed nameForDataFeedType:self.dataFeedType];

	if (self.dataFeedType) {

        //note: view object is now being initialized from the xib file
        //self.view                               = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        //self.view.backgroundColor               = [UIColor blackColor];
        
        //place an icon image for the data service that we're attempting to sell.
        //we're doing this in code rather than the xib file for two reasons:
        //  a) the icon image is parameterized
        //  b) we want to add a an inverted reflection to the bottom of the image for added visual pazzaz.
        
        UIImage *iconImage                     = [LGAppDataFeed Image:[LGAppDataFeed imageForDataFeedTypeLarge:self.dataFeedType] Pixels:ICON_WIDTH];
        CGRect iconImageRect                    = CGRectMake(0, 0, iconImage.size.width, iconImage.size.height);
        
        self.iconImageView                      = [[LGReflectedImageView alloc] initWithFrame:iconImageRect];
        self.iconImageView.image                = iconImage;
        self.iconImageView.center               = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 35);
        
        [self.view addSubview:self.iconImageView];
        [iconImage release];
        
        
        // create the reflection view
        CGRect reflectionRect                   = iconImageRect;
        reflectionRect.size.height              = iconImageRect.size.height * reflectionFraction;
        reflectionRect                          = CGRectOffset(reflectionRect, 0, iconImageRect.size.height);
        
        NSUInteger reflectionHeight             = self.iconImageView.bounds.size.height * reflectionFraction;
        
        self.reflectionView                     = [[UIImageView alloc] initWithFrame:reflectionRect];
        self.reflectionView.image               = [self.iconImageView reflectedImageRepresentationWithHeight:reflectionHeight];
        self.reflectionView.alpha               = reflectionOpacity;
        self.reflectionView.center              = CGPointMake(self.iconImageView.center.x, self.iconImageView.center.y + (ICON_HEIGHT * (1 + reflectionFraction)) / 2);
        
        
        [self.view addSubview:reflectionView];
        
        
        
        self.navigationController.navigationBar.translucent      = NO;
        self.navigationController.navigationBar.tintColor        = [LGAppDeclarations colorForNavigationBar];
        self.navigationController.navigationBar.alpha            = 1;
        
        
        NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
        
        self.priceLable.text = [LGAppDataFeed priceTextForDataFeedTypeAsLocalizedString:self.dataFeedType];
        
        if (![LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType] && [LGAppDataFeed getCartQtyForDataFeedType:self.dataFeedType] == 0) {
            self.addToCartButton           = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"addToCartButton", @"Add To Cart")
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(doAddToCartButton)
                                              ];
            
            [toolbarButtons addObject:self.addToCartButton];
        }
        
        if (![LGAppDataFeed isUnlockedDataFeedType:self.dataFeedType] && [LGAppDataFeed getCartQtyForDataFeedType:self.dataFeedType] > 0) {
            self.removeFromCartButton           = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"removeFromCartButton", @"Remove From Cart") 
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(doRemoveFromCartButton)
                                              ];
            
            [toolbarButtons addObject:self.removeFromCartButton];
        }
        
        if ([LGAppDataFeed getCartQtyTotal] > 0) {
            self.goToCheckoutButton        = [[UIBarButtonItem alloc] 
                                              initWithTitle:NSLocalizedString(@"goToCheckoutButton", @"Go To Checkout") 
                                              style:UIBarButtonItemStyleBordered 
                                              target:self 
                                              action:@selector(doGoToCheckout)
                                              ];
            
            [toolbarButtons addObject:self.goToCheckoutButton];
        }
        
        [self setToolbarItems:toolbarButtons];
        [toolbarButtons release];
        
        self.advertLabel.text = [self advertLabelTextForDataFeedTypeId];

        
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self logObjectVariables:@"didReceiveMemoryWarning()"];
    // Release any cached data, images, etc that aren't in use.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self logObjectVariables:@"viewDidUnload()"];
    
    cashRegisterAudioPlayer = nil;
    goToCheckoutButton = nil;
    addToCartButton = nil;
    removeFromCartButton = nil;
    
    priceLable = nil;
    advertLabel = nil;
    
    shoppingCartImageView = nil;
    iconImageView = nil;
    reflectionView = nil;
    
    appDelegate = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    [self logObjectVariables:@"shouldAutorotateToInterfaceOrientation()"];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc
{
    [cashRegisterAudioPlayer release];
    [goToCheckoutButton release];
    [addToCartButton release];
    [removeFromCartButton release];
    
    [priceLable release];
    [advertLabel release];
    
    [shoppingCartImageView release];
    [iconImageView release];
    [reflectionView release];
    [appDelegate release];

    [super dealloc];
}


#pragma mark - Utility Methods

- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) NSLog(@"LGInAppSaleViewController.%@", suffix);
}



- (NSString *)advertLabelTextForDataFeedTypeId
{
    [self logObjectVariables:@"advertLabelTextForDataFeedTypeId()"];
    
    NSString *key = [NSString stringWithFormat:@"Pitch_%@", [LGAppDataFeed keyForDataFeedType:self.dataFeedType]];
    return NSLocalizedString(key, @"pitch for access to ...");

}

@end
