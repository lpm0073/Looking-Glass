/*
 
 */

#import <UIKit/UIKit.h>

@interface LGReflectedImageView : UIView {
    UIImage *image;
}

@property (nonatomic, retain) UIImage *image;

- (UIImage *)reflectedImageRepresentationWithHeight:(NSUInteger)height;
@end
