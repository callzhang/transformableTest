//
//  TTViewController.m
//  transformableTest
//
//  Created by Lei on 4/10/14.
//  Copyright (c) 2014 Lei. All rights reserved.
//

#import "TTViewController.h"
#import "News.h"
#import "MagicalRecord+ChainSave.h"

@interface TTViewController ()
@property (nonatomic) NSManagedObjectContext *context;
@end

@implementation TTViewController{
    CLLocationManager *manager;
    CLLocation *location;
    News *news;
}
@synthesize context;


- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [manager startUpdatingLocation];
    
    [self context];
    
    //data
//    news = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:self.context];
//    news.title = @"new title";
    
    //test for perminent ID
//    NSManagedObjectID *tempID = news.objectID;
//    
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//        News *tempNews = [news MR_inContext:localContext];
//        NSLog(@"Temp News: %@", tempNews.title);
//        
//        //perm
//        __block NSManagedObjectID *permID;
//        [context performBlockAndWait:^{
//            [context obtainPermanentIDsForObjects:@[news] error:nil];
//            permID = news.objectID;
//        }];
//        News *permNews = [localContext objectWithID:permID];
//        NSLog(@"Perm news: %@", permNews.title);
//    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextWillSaveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSManagedObjectContext *localContext = note.object;
        NSSet *inserts = localContext.insertedObjects;
        NSSet *updates = localContext.updatedObjects;
        NSString *thread = localContext == context ? @"Main thread" : @"Background thread";
        for (NSManagedObject *MO in inserts) {
            if (MO.changedValues.allKeys.count) {
                NSLog(@"%@ INSERTED with %@ on %@", MO.entity.name, MO.changedValues, thread);
            }
        }
        for (NSManagedObject *MO in updates) {
            if (MO.changedValues.allKeys.count) {
                NSLog(@"%@ UPDATED with %@ on %@", MO.entity.name, MO.changedValues, thread);
            }
        }
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//        NSManagedObjectContext *localContext = note.object;
//        NSString *thread = localContext == context ? @"Main thread":@"Background thread";
//        NSLog(@"Did save in %@", thread);
//    }];
    
    [self load:nil];
}


- (IBAction)create:(id)sender {
    news = [News MR_createEntity];
    news.title = @"new";
    news.preference = @{@"menu": @{
                                @"id": @"file",
                                @"value": @"File",
                                @"popup": @{@"menuitem": @[
                                                    @{@"value": @"New", @"onclick": @"CreateNewDoc()"},
                                                    @{@"value": @"Open", @"onclick": @"OpenDoc()"},
                                                    @{@"value": @"Close", @"onclick": @"CloseDoc()"}]
                    }}};
    
    [manager startUpdatingLocation];
    [context MR_saveToPersistentStoreAndWait];
    
    [self load:nil];
}

- (IBAction)save:(id)sender {
    [context saveWithBlock:^(NSManagedObjectContext *localContext0) {
        [localContext0 saveWithBlock:^(NSManagedObjectContext *localContext) {
            News *backNews = [news MR_inContext:localContext];
            backNews.title = self.title_input.text;
            backNews.location = location;
            
            NSError *err;
            NSData *prefData = [self.string_input.text dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:prefData options:0 error:&err];
            backNews.preference = dic;
        }];
        
    }];
    
}

- (IBAction)delete:(id)sender {
    [news MR_deleteEntity];
    self.title_input.text = @"";
    self.location_input.text = @"";
    self.string_input.text = @"";
    [context MR_saveToPersistentStoreAndWait];
    news = nil;
}

- (IBAction)load:(id)sender {
    //try to get a news if none
    if (!news) {
        news = [News MR_findFirst];
        if (!news) {
            [[[UIAlertView alloc] initWithTitle:@"No news" message:@"No news found in store, create one first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
    }
    
    self.title_input.text = news.title;
    double lat = news.location.coordinate.latitude;
    double lon = news.location.coordinate.longitude;
    self.location_input.text = [NSString stringWithFormat:@"(%.2f,%.2f)", lat, lon];
    
    NSError *err;
    NSData *prefData = [NSJSONSerialization dataWithJSONObject:news.preference options:NSJSONWritingPrettyPrinted error:&err];
    NSString *prefStr = [[NSString alloc] initWithData:prefData encoding:NSUTF8StringEncoding];
    self.string_input.text = prefStr;
}

- (IBAction)tapped:(id)sender{
    [self.view endEditing:YES];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)m didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    location = newLocation;
    
    if (location != nil && news) {
        self.location_input.text = [NSString stringWithFormat:@"(%.2f,%.2f)", location.coordinate.latitude, location.coordinate.longitude];
        news.location = location;
        [m stopUpdatingLocation];
    }
}

- (NSManagedObjectContext *)context
{
    if (!context) {
        context = [NSManagedObjectContext MR_defaultContext];
    }
    return context;
    
}
@end
