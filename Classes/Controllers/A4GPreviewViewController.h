//
//  A4GPreviewViewController.h
//  Brandagram
//
//  Created by Dale Zak on 12-10-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A4GViewController.h"
#import "A4GShareController.h"

@interface A4GPreviewViewController : A4GViewController<A4GShareControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

- (IBAction)twitter:(id)sender event:(UIEvent*)event;
- (IBAction)facebook:(id)sender event:(UIEvent*)event;
- (IBAction)email:(id)sender event:(UIEvent*)event;
- (IBAction)sms:(id)sender event:(UIEvent*)event;
- (IBAction)save:(id)sender event:(UIEvent*)event;

@end
