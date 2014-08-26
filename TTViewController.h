//
//  TTViewController.h
//  transformableTest
//
//  Created by Lei on 4/10/14.
//  Copyright (c) 2014 Lei. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@interface TTViewController : UIViewController<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *title_input;
@property (weak, nonatomic) IBOutlet UITextField *title_output;
@property (weak, nonatomic) IBOutlet UITextField *location_input;
@property (weak, nonatomic) IBOutlet UITextField *location_output;
@property (weak, nonatomic) IBOutlet UITextView *string_input;
@property (weak, nonatomic) IBOutlet UITextView *string_output;
- (IBAction)save:(id)sender;
- (IBAction)load:(id)sender;
@end
