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

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation A4GCameraViewController

@synthesize previewViewController = _previewViewController;
@synthesize aboutViewController = _aboutViewController;
@synthesize backgroundView = _backgroundView;
@synthesize overlayView = _overlayView;
@synthesize pageControl = _pageControl;
@synthesize imagePicker = _imagePicker;
@synthesize containerView = _containerView;

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
    [_backgroundView release];
    [_overlayView release];
    [_pageControl release];
    [_imagePicker release];
    [_containerView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"");

    self.imagePicker = [[UIImagePickerController alloc] init];
    //self.imagePicker.delegate = self;
    
    self.imagePicker.navigationBarHidden = NO;
    self.imagePicker.toolbarHidden = YES;
    self.imagePicker.wantsFullScreenLayout = NO;
    [self.containerView addSubview:self.imagePicker.view];
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

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}
@end
