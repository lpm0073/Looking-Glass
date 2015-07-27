//
//  LGTableViewCell.m
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGTableViewCell.h"
#import "LGAppDeclarations.h"



@interface BarView : UIView
@end

@implementation BarView

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Drawing lines with a blue stroke color
	CGContextSetRGBStrokeColor(context, 0.0 , 0.0, 1.0, 1.0);

	CGContextSetLineWidth(context, rect.size.width);
	
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextAddLineToPoint(context, 0.0f, rect.size.height);
	CGContextStrokePath(context);
    
}

@end



@interface LGTableViewCell()
{
    LGDataFeedType dataFeedType;
}

@property (nonatomic, retain, readonly) UIImageView *rowNumberImageView;
@property (nonatomic, retain, readonly) UILabel *rowNumberViewTextLabel;

@end


@implementation LGTableViewCell

@synthesize needsProfilePic;

@synthesize lgTextLabel;
@synthesize lgDetailTextLable;
@synthesize dataFeedImageView;
@synthesize geocodeStatusImageView;
@synthesize rowNumberImageView;
@synthesize rowNumberViewTextLabel;
@synthesize rowNumber;


- (void)logObjectVariables:(NSString *)suffix
{
    if (OBJECT_DEBUG && OBJECT_DEBUG_VERBOSE) {
    }
    if (OBJECT_DEBUG) NSLog(@"LGTableViewCell.%@", suffix);
}

#pragma mark - Setters and Getters
- (UIImageView *)geocodeStatusImageView
{
    if (!geocodeStatusImageView) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"geocodeStatusImageView()"];

        geocodeStatusImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(50 - 16, 1, 16, 16)] retain];
        geocodeStatusImageView.opaque = YES;
        [self addSubview:geocodeStatusImageView];
    }
    return geocodeStatusImageView;
}

- (UIImageView *)dataFeedImageView
{
    if (!dataFeedImageView) {
        if (OBJECT_DEBUG) [self logObjectVariables:@"dataFeedImageView()"];
        
        dataFeedImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(50 - 16, self.frame.size.height - 17, 16, 16)] retain];
        dataFeedImageView.opaque = YES;
        [self addSubview:dataFeedImageView];
    }
    return dataFeedImageView;
}

- (UIImageView *)rowNumberImageView
{
    return rowNumberImageView;
}

- (UILabel *)rowNumberViewTextLabel
{
    
    if (!rowNumberViewTextLabel) {
        
        if (OBJECT_DEBUG) [self logObjectVariables:@"rowNumberViewTextLabel()"];

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
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"setRowNumber(%d)", newRowNumber]];

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
        }
    }
     

    
    //if (_person) self.person.rowNumber = newRowNumber;
    //if (_checkin) self.checkin.rowNumber = newRowNumber;
    //if (_mapItem) self.mapItem.rowNumber = newRowNumber;
}



-(Person *)person
{
    return _person;
}
-(void)setPerson:(Person *)person
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"setPerson(%@)", person.unique_id]];
    
    @synchronized(self) {
        [person retain];
        [_person release];
        
        _person = person;
        [_person reset];
        _person.delegate = self;
        //_person.rowNumber = self.rowNumber;
        
        if (_person == nil) {
            self.imageView.image = nil;
        } else {
            dataFeedType = _person.dataFeedType;
            
            if (_person.thumbnailImage != nil) {
                self.imageView.image = _person.thumbnailImage;
            }

            if (!self.imageView.image) {
                self.needsProfilePic = YES;
                self.imageView.image = [LGAppDataFeed imageForDataFeedTypeLarge:_person.dataFeedType];
            } else {
                self.dataFeedImageView.image = [LGAppDataFeed imageForDataFeedTypeSmall:_person.dataFeedType];
                self.needsProfilePic = NO;
            }
        }
        if (_person.geocodeStatusImage) self.geocodeStatusImageView.image = _person.geocodeStatusImage;        
    }
    
}

-(Checkin *)checkin
{
    return _checkin;
}

-(void)setCheckin:(Checkin *)checkin
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"setCheckin()"];
    
    @synchronized(self) {
        [checkin retain];
        [_checkin release];

        _checkin = checkin;
        [_checkin reset];
        _checkin.delegate = self;
        //_checkin.rowNumber = self.rowNumber;
        //if (_checkin.checkin_Mapitem) _checkin.checkin_Mapitem.rowNumber = self.rowNumber;
        
        if (_checkin == nil) {
            self.imageView.image = nil;
        } else {
            dataFeedType = _checkin.dataFeedType;
            
            if (_checkin.thumbnailImage != nil) {
                self.imageView.image = _checkin.thumbnailImage;
            }
            
            if (!self.imageView.image) {
                self.needsProfilePic = YES;
                self.imageView.image = [LGAppDataFeed imageForDataFeedTypeLarge:dataFeedType];
            } else {
                self.dataFeedImageView.image = [LGAppDataFeed imageForDataFeedTypeSmall:dataFeedType];
                self.needsProfilePic = NO;
            }
        }
        if (_checkin.geocodeStatusImage) self.geocodeStatusImageView.image = _checkin.geocodeStatusImage;
    }
}

-(MapItem *)mapItem
{
    return _mapItem;
}
-(void)setMapItem:(MapItem *)mapItem
{
    if (OBJECT_DEBUG) [self logObjectVariables:[NSString stringWithFormat:@"setMapItem(%@)", mapItem.unique_id]];
    
    @synchronized(self) {
        [mapItem retain];
        [_mapItem release];
        
        _mapItem = mapItem;
        [_mapItem reset];
        _mapItem.delegate = self;
        //_mapItem.rowNumber = self.rowNumber;
        
        if (_mapItem == nil) {
            self.imageView.image = nil;
        } else {
            dataFeedType = _mapItem.dataFeedType;

            if (_mapItem.thumbnailImage != nil) {
                self.imageView.image = _mapItem.thumbnailImage;
            }
            
            if (!self.imageView.image) {
                self.needsProfilePic = YES;
                self.imageView.image = [LGAppDataFeed imageForDataFeedTypeLarge:dataFeedType];
            } else {
                self.dataFeedImageView.image = [LGAppDataFeed imageForDataFeedTypeSmall:dataFeedType];
                self.needsProfilePic = NO;
            }
        }
        self.needsProfilePic = NO;
        if (_mapItem.geocodeStatusImage) self.geocodeStatusImageView.image = _mapItem.geocodeStatusImage;
    }
}


#pragma mark - LGDataModelManagedObjectDelegate
/*=====================================================================================================================================================
 *
 * LGDataModelManagedObjectDelegate: called by our person object when an image is ready to be displayed
 *
 *=====================================================================================================================================================*/
- (void)thumbnailImageDidLoad:(UIImage *)thumbnailImage
{
    if (OBJECT_DEBUG) {
        if (self.person) [self logObjectVariables:[NSString stringWithFormat:@"thumbnailImageDidLoad(%@)", self.person.unique_id]];
        else [self logObjectVariables:@"thumbnailImageDidLoad()"];
    }
    
    self.imageView.image = thumbnailImage;
    self.dataFeedImageView.image = [LGAppDataFeed imageForDataFeedTypeSmall:dataFeedType];
    

    [self.imageView setNeedsDisplay];
    [self.dataFeedImageView setNeedsDisplay];
    
    self.needsProfilePic = NO;
    
    if (self.person) [self.person resetIntegrators];
    if (self.checkin) [self.checkin resetIntegrators];
    if (self.mapItem) [self.mapItem resetIntegrators];
    
}

- (void)tableCellTitleTextDidChange:(NSString *)newText
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableCellTitleTextDidChange()"];
    
    self.lgTextLabel.text = newText;
    [self.lgTextLabel setNeedsDisplay];
}

- (void)tableCellSubtitleTextDidChange:(NSString *)newText
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"tableCellSubtitleTextDidChange()"];
    
    self.lgDetailTextLable.text = newText;
    [self.lgDetailTextLable setNeedsDisplay];
}

- (void)coordinatesDidChange:(CLLocation *)location GeocodeAccuracy:(LGMapItemGeocodeAccuracy)geocodeAccuracy
{
    
    if (OBJECT_DEBUG) [self logObjectVariables:@"coordinatesDidChange:GeocodeAccuracy()"];
    
    [dataFeedImageView removeFromSuperview];
    [dataFeedImageView release];
    dataFeedImageView = nil;
    [self.dataFeedImageView setNeedsDisplay];
    
}

#pragma mark - UITableViewCell Delegate
- (void)prepareForReuse
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"prepareForReuse()"];
    
    [super prepareForReuse];
    [self reset];
}

#pragma mark - API methods
- (void)reset
{
    if (OBJECT_DEBUG) [self logObjectVariables:@"reset()"];

    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.imageView.image = nil;

    //Looking glass custom objects
    
    if (_person) {
        [_person reset];
        [_person release];
        _person = nil;
    }
    if (_mapItem) {
        [_mapItem reset];
        [_mapItem release];
        _mapItem = nil;
    }
    if (_checkin) {
        [_checkin reset];
        [_checkin release];
        _checkin = nil;
    }
    
    if (lgTextLabel) {
        lgTextLabel.text = nil;
    }
    
    if (lgDetailTextLable) {
        lgDetailTextLable.text = nil;
    }
    
    if (geocodeStatusImageView) {
        [geocodeStatusImageView removeFromSuperview];
        geocodeStatusImageView.image = nil;
        [geocodeStatusImageView release];
        geocodeStatusImageView = nil;
    }
    
    if (dataFeedImageView) {
        [dataFeedImageView removeFromSuperview];
        dataFeedImageView.image = nil;
        [dataFeedImageView release];
        dataFeedImageView = nil;
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

- (void)doHousekeeping
{

    if (OBJECT_DEBUG) [self logObjectVariables:@"doHousekeeping()"];
    
    
    if (self.needsProfilePic) {
        if (_person) {
            if (_person.thumbnailImage) {
                self.imageView.image = _person.thumbnailImage;
                self.needsProfilePic = NO;
            } else {
                [_person doHousekeeping];
            }
        } 
    }
    
    if (_mapItem) {
        [_mapItem doHousekeeping];
        //if there's a geocode status image on-screen then this means that, upon init, we still
        //didn't have a street-level geocode for this person. however, that might have changed
        //however, it's hard to message person when the mapitem geocode completion handler fires, so, we refresh manually
        //on visible rows.
        if (geocodeStatusImageView && _mapItem.geocodeAccuracy >= LGMapItemGeocodeAccuracy_City) {
            [_mapItem resetGeocodeStatusImage];
            geocodeStatusImageView.image = _mapItem.geocodeStatusImage;   
        }
    }
    
    if (_person) {
        if (geocodeStatusImageView && _person.geocodeAccuracy >= LGMapItemGeocodeAccuracy_City) {
            [_person resetGeocodeStatusImage];
            geocodeStatusImageView.image = _person.geocodeStatusImage;   
        }
    }


}

#pragma mark - Object Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
        if (OBJECT_DEBUG) [self logObjectVariables:@"initWithStyle:reuseIdentifier()"];
        
        //[self reset];
        self.imageView.backgroundColor          = [LGAppDeclarations LGTableViewCell_backgroundColor];
        self.contentView.backgroundColor        = [LGAppDeclarations LGTableViewCell_backgroundColor];
        
        [self setAccessoryType:UITableViewCellAccessoryNone];

        BarView *barView = [[BarView alloc] initWithFrame:CGRectMake(51, 0, 1, self.bounds.size.height)];
        barView.opaque = YES;
        [self addSubview:barView];
        [barView release];
        
        barView = [[BarView alloc] initWithFrame:CGRectMake(54, 0, 1, self.bounds.size.height)];
        barView.opaque = YES;
        [self addSubview:barView];
        [barView release];
        
        
        self.lgTextLabel                            = [[UILabel alloc] initWithFrame:CGRectMake(58, 
                                                                                                0, 
                                                                                                self.bounds.size.width - 55, 
                                                                                                self.bounds.size.height * (2.0f/3.0f)
                                                                                                )
                                                       ];
        
        self.lgTextLabel.opaque                     = YES;
        [self.lgTextLabel setFont:[LGAppDeclarations LGTableViewCellTitle_Font]];
        self.lgTextLabel.backgroundColor            = [LGAppDeclarations LGTableViewCell_backgroundColor];
        self.lgTextLabel.textColor                  = [LGAppDeclarations LGTableViewCell_TextColor];
        [self addSubview:self.lgTextLabel];
        
        self.lgDetailTextLable                      = [[UILabel alloc] initWithFrame:CGRectMake(58, 
                                                                                                self.bounds.size.height * (2.0f/3.0f), 
                                                                                                self.bounds.size.width - 55, 
                                                                                                self.bounds.size.height * (1.0f/3.0f)
                                                                                                )
                                                       ];
        
        self.lgDetailTextLable.opaque               = YES;
        [self.lgDetailTextLable setFont:[LGAppDeclarations LGTableViewCellSubitle_Font]];
        self.lgDetailTextLable.backgroundColor      = [LGAppDeclarations LGTableViewCell_backgroundColor];
        self.lgDetailTextLable.textColor            = [LGAppDeclarations LGTableViewCell_TextColor];
        [self addSubview:self.lgDetailTextLable];

        
        self.needsProfilePic = YES;
        
    }
    return self;
}

- (void)dealloc
{
    [self reset];
    
    [lgTextLabel release];
    [lgDetailTextLable release];
    
    [super dealloc];
}


@end