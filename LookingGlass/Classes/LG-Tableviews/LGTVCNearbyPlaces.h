//
//  LGTVCNearbyPlaces.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LGCoreDataTVC.h"

@interface LGTVCNearbyPlaces : LGCoreDataTVC

@property (nonatomic) LGQueryType queryType;
@property (nonatomic, retain) CLLocation *location;

- (id)initWithLocation:(CLLocation *)myLocation DistanceFromLocation:(NSInteger)distance QueryType:(LGQueryType)queryType;

@end
