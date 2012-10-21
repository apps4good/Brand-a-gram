//
//  A4GCameraViewController.h
//  Brandagram
//
//  Created by Dale Zak on 12-10-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A4GPreviewViewController;
@class A4GAboutViewController;

@interface A4GCameraViewController : UIViewController<UINavigationControllerDelegate,
                                                      UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet A4GPreviewViewController *previewViewController;
@property (strong, nonatomic) IBOutlet A4GAboutViewController *aboutViewController;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *overlayView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *containerView;

- (IBAction)previous:(id)sender event:(UIEvent*)event;
- (IBAction)next:(id)sender event:(UIEvent*)event;

@end
