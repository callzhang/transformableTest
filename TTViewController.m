//
//  TTViewController.m
//  transformableTest
//
//  Created by Lei on 4/10/14.
//  Copyright (c) 2014 Lei. All rights reserved.
//

#import "TTViewController.h"
#import "News.h"

@interface TTViewController ()
@property (nonatomic) NSManagedObjectContext *context;
@end

@implementation TTViewController{
    CLLocationManager *manager;
    CLLocation *location;
    News *news;
}
@synthesize context;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [manager startUpdatingLocation];
    
    //data
    news = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:self.context];
    news.title = @"new title";
    
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
    
}

- (IBAction)save:(id)sender {
    news.title = self.title_input.text;
    NSDictionary *loc = @{@"latitude": [NSNumber numberWithDouble:location.coordinate.latitude], @"longitude": [NSNumber numberWithDouble:location.coordinate.longitude]};
    news.location = loc;
    
    NSError *err;
    NSData *prefData = [self.string_input.text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:prefData options:0 error:&err];
    news.preference = dic;//@{@"test": @"hihi", @"echo": @"one"};
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:news.objectID forKey:@"ID"];
//    [defaults synchronize];
}

- (IBAction)load:(id)sender {
//    NSManagedObjectID *ID = [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"];
//    news = (News *)[self.context objectWithID:ID];
    
    self.title_output.text = news.title;
    double lat = [(NSNumber *)news.location[@"latitude"] doubleValue];
    double lon = [(NSNumber *)news.location[@"longitude"] doubleValue];
    self.location_output.text = [NSString stringWithFormat:@"(%.2f,%.2f)", lat, lon];
    
    NSError *err;
    NSData *prefData = [NSJSONSerialization dataWithJSONObject:news.preference options:NSJSONWritingPrettyPrinted error:&err];
    NSString *prefStr = [[NSString alloc] initWithData:prefData encoding:NSUTF8StringEncoding];
    self.string_output.text = prefStr;
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    location = newLocation;
    
    if (location != nil) {
        self.location_input.text = [NSString stringWithFormat:@"(%.2f,%.2f)", location.coordinate.latitude, location.coordinate.longitude];
    }
    
    //[self->manager stopUpdatingLocation];
}

- (NSManagedObjectContext *)context
{
    return [NSManagedObjectContext MR_defaultContext];
    
}
@end
