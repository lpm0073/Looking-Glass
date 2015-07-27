//
//  LGTableViewCell.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <UIKit/UIKit.h>
#import "LGAppDeclarations.h"
#import "Person.h"
#import "Checkin.h"
#import "MapItem.h"


@interface LGTableViewCell : UITableViewCell <LGDataModelManagedObjectDelegate>
{
    Person *_person;
    Checkin *_checkin;
    MapItem *_mapItem;
}

@property BOOL needsProfilePic;

@property (retain) Person *person;
@property (retain) Checkin *checkin;
@property (retain) MapItem *mapItem;
@property (nonatomic, retain) UILabel *lgTextLabel;
@property (nonatomic, retain) UILabel *lgDetailTextLable;

@property (nonatomic, retain, readonly) UIImageView *geocodeStatusImageView;
@property (nonatomic, retain, readonly) UIImageView *dataFeedImageView;
@property (nonatomic) NSInteger rowNumber;

- (void)reset;
- (void)doHousekeeping;

@end


