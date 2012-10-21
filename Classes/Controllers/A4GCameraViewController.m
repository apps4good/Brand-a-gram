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
#import "A4GSettings.h"

@interface A4GCameraViewController ()

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeLeftRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeRightRecognizer;
@property (strong, nonatomic) NSArray *overlays;

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer;

@end

@implementation A4GCameraViewController

@synthesize previewViewController = _previewViewController;
@synthesize aboutViewController = _aboutViewController;
@synthesize backgroundView = _backgroundView;
@synthesize overlayView = _overlayView;
@synthesize pageControl = _pageControl;
@synthesize imagePicker = _imagePicker;
@synthesize containerView = _containerView;
@synthesize swipeLeftRecognizer = _swipeLeftRecognizer;
@synthesize swipeRightRecognizer = _swipeRightRecognizer;
@synthesize overlays = _overlays;

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
    [_swipeLeftRecognizer release];
    [_swipeRightRecognizer release];
    [_overlays release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"");
    self.overlays = [A4GSettings overlays];
    self.overlayView.image = [UIImage imageNamed:[self.overlays objectAtIndex:0]];
    self.pageControl.numberOfPages = self.overlays.count;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    self.imagePicker.navigationBarHidden = YES;
    self.imagePicker.toolbarHidden = YES;
    self.imagePicker.wantsFullScreenLayout = NO;
    self.imagePicker.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    CGAffineTransformScale(self.imagePicker.cameraViewTransform, self.containerView.frame.size.width, self.containerView.frame.size.height);

    [self.containerView addSubview:self.imagePicker.view];
    
    [self.containerView bringSubviewToFront:self.overlayView];
    
    self.swipeLeftRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)] autorelease];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.swipeRightRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)] autorelease];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    DLog(@"");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"");
    [self.overlayView addGestureRecognizer:self.swipeLeftRecognizer];
    [self.overlayView addGestureRecognizer:self.swipeRightRecognizer];
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
    [self.overlayView removeGestureRecognizer:self.swipeLeftRecognizer];
    [self.overlayView removeGestureRecognizer:self.swipeRightRecognizer];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DLog(@"");
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DLog(@"");
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer { 
    DLog(@"");
    if (self.pageControl.currentPage > 0) {
        self.pageControl.currentPage -= 1; 
        NSString *image = [self.overlays objectAtIndex:self.pageControl.currentPage];
        self.overlayView.image = [UIImage imageNamed:image];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    DLog(@""); 
    if (self.pageControl.currentPage < self.overlays.count) {
        self.pageControl.currentPage += 1; 
        NSString *image = [self.overlays objectAtIndex:self.pageControl.currentPage];
        self.overlayView.image = [UIImage imageNamed:image];
    }
}

@end
