//
//  A4GPreviewViewController.m
//  Brandagram
//
//  Created by Dale Zak on 12-10-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "A4GPreviewViewController.h"

@interface A4GPreviewViewController ()

@property (strong, nonatomic) A4GShareController *shareController;

@end

@implementation A4GPreviewViewController

@synthesize imageView = _imageView;
@synthesize image = _image;
@synthesize shareController = _shareController;

#pragma mark - IBActions

- (IBAction)twitter:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self.shareController sendTweet:@"Brandagram" withImage:self.image];
}

- (IBAction)facebook:(id)sender event:(UIEvent*)event {
    DLog(@"");
}

- (IBAction)email:(id)sender event:(UIEvent*)event {
    DLog(@"");
}

- (IBAction)sms:(id)sender event:(UIEvent*)event {
    DLog(@""); 
}

- (IBAction)save:(id)sender event:(UIEvent*)event {
    DLog(@"");
}

#pragma mark - UIViewController

- (void)dealloc {
    [_image release];
    [_imageView release];
    [_shareController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareController = [[A4GShareController alloc] initWithController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

@end
