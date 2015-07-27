//
//  LGAppDeclarations.h
//  LookingGlass
//
//  Created by Lawrence McDaniel on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef LookingGlass_LGAppDeclarations_h
#define LookingGlass_LGAppDeclarations_h
#import <UIKit/UIKit.h>

#define OBJECT_DEBUG NO
#define OBJECT_DEBUG_VERBOSE NO

#define kLGNEARBYPLACES_QUERY_RANGE 1600                   //meters
#define kLGNEARBYPLACES_MAXRECORDS 99
#define kLGNEARBYPLACES_MIN_REQUERY_DISTANCE 200            //meters

#define kLGMAPITEM_DISTANCEUPDATE_MIN_LOCATION_CHANGE 75   //meters

#define kLGFRIENDS_MIN_HOURS_TO_REQUERY_LIST_WIFI 12
#define kLGFRIENDS_MIN_HOURS_TO_REQUERY_LIST_WWAN 24
#define kLGCACHE_DAYS_TO_KEEP_OBJECTS 90



typedef enum _LGDataFeedType {
    LGDataFeedTypeBeacon        = 1,
    LGDataFeedTypeAddressBook,
    LGDataFeedTypeCalendar,
    
    LGDataFeedTypeFaceBookFriend,
    LGDataFeedTypeFaceBookCheckin,
    LGDataFeedTypeFaceBookPlace,
    
    LGDataFeedTypeFourSquare,
    LGDataFeedTypeGooglePlaces,
    LGDataFeedTypeGooglePlus,
    LGDataFeedTypeGowalla,
    LGDataFeedTypeGroupon,
    LGDataFeedTypeJive,
    LGDataFeedTypeLinkedIn,
    LGDataFeedTypeLOCKERZ,
    LGDataFeedTypeMySpace,
    LGDataFeedTypeOutlook,
    LGDataFeedTypeSkype,
    LGDataFeedTypeTwitter
} LGDataFeedType;

typedef enum _LGMapItemGeocodeAccuracy {
    LGMapItemGeocodeAccuracy_BadAddress     = -1,
    LGMapItemGeocodeAccuracy_None           = 0,
    LGMapItemGeocodeAccuracy_Country        = 1,
    LGMapItemGeocodeAccuracy_State          = 2,
    LGMapItemGeocodeAccuracy_City           = 3, 
    LGMapItemGeocodeAccuracy_Municipality   = 4,
    LGMapItemGeocodeAccuracy_PostalCode     = 5,
    LGMapItemGeocodeAccuracy_Street         = 10
} LGMapItemGeocodeAccuracy;


typedef enum _LGQueryType {
    LGQueryTypePlace              = 0,
    LGQueryTypePeople             = 1,
    LGQueryTypePeopleAndPlaces    = 2
} LGQueryType;



@interface LGAppDeclarations

+ (UIColor *)colorForNavigationBar;
+ (UIColor *)colorForToolbar;
+ (UIColor *)LGTVC_backgroundColor;
+ (UIColor *)LGTVC_Seperator_backgroundColor;
+ (UIColor *)LGTVC_SearchbarColor;
+ (UIColor *)LGTableViewCell_backgroundColor;
+ (UIColor *)LGTableViewCell_TextColor;
+ (float)alphaForNavigationBar;
+ (UIFont *)LGTableViewCellTitle_Font;
+ (UIFont *)LGTableViewCellSubitle_Font;


@end
#endif
