//
//  A4GCameraViewController.h
//  Brandagram
//
//  Created by Dale Zak on 12-10-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@class A4GPreviewViewController;
@class A4GAboutViewController;

@interface A4GCameraViewController : UIViewController

@property (strong, nonatomic) IBOutlet A4GPreviewViewController *previewViewController;
@property (strong, nonatomic) IBOutlet A4GAboutViewController *aboutViewController;

- (IBAction)previous:(id)sender event:(UIEvent*)event;
- (IBAction)next:(id)sender event:(UIEvent*)event;

@end
