//
//  A4GAppDelegate.h
//  Brandagram
//
//  Created by Dale Zak on 12-10-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A4GCameraViewController;
@class A4GPreviewViewController;
@class A4GAboutViewController;

@interface A4GAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet A4GCameraViewController *cameraViewController;
@property (strong, nonatomic) IBOutlet A4GPreviewViewController *previewViewController;
@property (strong, nonatomic) IBOutlet A4GAboutViewController *aboutViewController;

@end
