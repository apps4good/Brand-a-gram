//
//  A4GCameraViewController.m
//  Brandagram
//
//  Created by Dale Zak on 12-10-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "A4GCameraViewController.h"
#import "A4GPreviewViewController.h"
#import "A4GAboutViewController.h"

@interface A4GCameraViewController ()

@end

@implementation A4GCameraViewController

@synthesize previewViewController = _previewViewController;
@synthesize aboutViewController = _aboutViewController;

#pragma mark - IBActions

- (IBAction)previous:(id)sender event:(UIEvent*)event {
    DLog(@"");
}

- (IBAction)next:(id)sender event:(UIEvent*)event {
    DLog(@"");    
}

#pragma mark - UIViewController

- (void)dealloc {
    [_previewViewController release];
    [_aboutViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    DLog(@"");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLog(@"");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DLog(@"");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];    
    DLog(@"");
}

@end
