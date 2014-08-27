//
//  News.h
//  transformableTest
//
//  Created by Lei on 4/10/14.
//  Copyright (c) 2014 Lei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import CoreLocation;

@interface News : NSManagedObject

@property (nonatomic, retain) NSDictionary *preference;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) CLLocation *location;

@end
