//
//  LGMapItemAnnotationView.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LGAppDeclarations.h"
#import "LGMapItemAnnotationView.h"
#import "MapItem.h"

@interface LGMapItemAnnotationView()
{
    float width;
    float height;
}

@property (nonatomic, retain, readonly) MapItem *mapItem;
@property (nonatomic, retain, readonly) UIImageView *rowNumberImageView;
@property (nonatomic, retain, readonly) UILabel *rowNumberViewTextLabel;
@property (nonatomic, retain, readonly) UIImage *dataFeedImage;

- (void)logObjectVariables:(NSString *)suffix;
- (void)reset;

@end


@implementation LGMapItemAnnotationView

@synthesize mapItem;
@synthesize rowNumberImageView;
@synthesize rowNumberViewTextLabel;
@synthesize rowNumber;
@synthesize dataFeedImage;

#pragma mark - Setters and Getters
- (MapItem *)mapItem
{
    if (![self.annotation isKindOfClass:([MapItem class])]) return nil;
    if (!mapItem) {
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"mapItem()"];

        mapItem = [(MapItem *)self.annotation retain];
        self.rowNumber = mapItem.rowNumber;
    }
    return mapItem;
}

- (UIImage *)dataFeedImage
{
    if (!dataFeedImage) {
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"dataFeedImage()"];
        dataFeedImage = [[LGAppDataFeed imageForDataFeedTypeLarge:self.mapItem.dataFeedType] retain];
    }
    return dataFeedImage;
}

- (UILabel *)rowNumberViewTextLabel
{
    if (!rowNumberViewTextLabel) {
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"rowNumberViewTextLabel()"];
        
        rowNumberViewTextLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, rowNumberImageView.bounds.size.width, rowNumberImageView.bounds.size.height)] retain];
        rowNumberViewTextLabel.backgroundColor  = [UIColor clearColor];
        rowNumberViewTextLabel.opaque           = YES;
        rowNumberViewTextLabel.font             = [UIFont systemFontOfSize:10];
        rowNumberViewTextLabel.textColor        = [UIColor whiteColor];
        rowNumberViewTextLabel.textAlignment    = UITextAlignmentCenter;
        rowNumberViewTextLabel.text             = [NSString stringWithFormat:@"%d", self.rowNumber];
    }
    return rowNumberViewTextLabel;
}

- (void)setRowNumber:(NSInteger)newRowNumber
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"setRowNumber()"];

    rowNumber = newRowNumber;
    if (rowNumber > 0) {
        if (!rowNumberImageView) {
            rowNumberImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 16, 16)] retain];
            rowNumberImageView.image = [UIImage imageNamed:@"LGTableViewCell_RedCircle16x16"];
            
            rowNumberImageView.opaque                       = YES;
            rowNumberImageView.clearsContextBeforeDrawing   = YES;
            rowNumberImageView.clipsToBounds                = YES;
            rowNumberImageView.autoresizesSubviews          = YES;
            rowNumberImageView.autoresizingMask             = UIViewAutoresizingFlexibleWidth;
            rowNumberImageView.userInteractionEnabled       = NO;
            
            [rowNumberImageView addSubview:self.rowNumberViewTextLabel];
            [self addSubview:rowNumberImageView];
            [rowNumberImageView setNeedsDisplay];
        }
    }
}





#pragma mark - object lifecycle

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"initWithAnnotation()"];

        width = 40.0;
        height = 40.0;
        
        CGRect frame            = self.frame;
        frame.size              = CGSizeMake(width, height);
        self.frame              = frame;
        self.backgroundColor    = [UIColor clearColor];
        self.centerOffset       = CGPointMake(width/2, height/2);
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"setAnnotation()"];

    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"drawRect()"];

    if (self.mapItem)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);

        [self.dataFeedImage drawInRect:CGRectMake(0, 0, width, height)];
        
    }
}
- (void)reset
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"reset()"];
    
    rowNumber = 0;
    
    if (mapItem) {
        [mapItem release];
        mapItem = nil;
    }
    
    if (dataFeedImage) {
        [dataFeedImage release];
        dataFeedImage = nil;
    }
    
    if (rowNumberViewTextLabel) {
        [rowNumberViewTextLabel removeFromSuperview];
        rowNumberViewTextLabel.text = nil;
        [rowNumberViewTextLabel release];
        rowNumberViewTextLabel = nil;
    }
    
    if (rowNumberImageView) {
        [rowNumberImageView removeFromSuperview];
        rowNumberImageView.image = nil;
        [rowNumberImageView release];
        rowNumberImageView = nil;
    }
    
}

- (void)prepareForReuse
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"prepareForReuse()"];
    [self reset];
}

- (void)dealloc
{
    if (OBJECT_DEBUG_VERBOSE) [self logObjectVariables:@"dealloc()"];

    [self reset];
    [super dealloc];
}

#pragma mark - Utility Methods
- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
        //
        // object instance variables go here
        //
    }
    if (OBJECT_DEBUG) {
        NSLog(@"%@.%@",[[self class] description], suffix);
    }
}

@end
