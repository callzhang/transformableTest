//
//  News.h
//  transformableTest
//
//  Created by Lei on 4/10/14.
//  Copyright (c) 2014 Lei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface News : NSManagedObject

@property (nonatomic, retain) id preference;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) id location;

@end
