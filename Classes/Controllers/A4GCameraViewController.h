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

@interface A4GCameraViewController : UIViewController<UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet A4GPreviewViewController *previewViewController;
@property (strong, nonatomic) IBOutlet A4GAboutViewController *aboutViewController;
@property (strong, nonatomic) IBOutlet UIImageView *overlayView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *cameraView;

- (IBAction)camera:(id)sender event:(UIEvent*)event;

@end
