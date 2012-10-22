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
#import "UIColor+A4G.h"


@interface A4GCameraViewController ()

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic) UISwipeGestureRecognizer * swipeLeftRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeRightRecognizer;
@property (strong, nonatomic) NSArray *overlays;

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer;
- (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second;

@end

@implementation A4GCameraViewController

@synthesize previewViewController = _previewViewController;
@synthesize aboutViewController = _aboutViewController;
@synthesize overlayView = _overlayView;
@synthesize pageControl = _pageControl;
@synthesize cameraView = _cameraView;
@synthesize swipeLeftRecognizer = _swipeLeftRecognizer;
@synthesize swipeRightRecognizer = _swipeRightRecognizer;
@synthesize overlays = _overlays;
@synthesize captureDevice = _captureDevice;
@synthesize deviceInput = _deviceInput;
@synthesize stillImageOutput = _stillImageOutput;

@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;

#pragma mark - IBActions

- (IBAction)about:(id)sender event:(UIEvent*)event {
    DLog(@""); 
    self.aboutViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentModalViewController:self.aboutViewController animated:YES];
}

- (IBAction)camera:(id)sender event:(UIEvent*)event {
    DLog(@"");
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { break; }
	}
	DLog(@"about to request a capture from: %@", self.stillImageOutput);
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
		 //CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
//		 if (exifAttachments) {
//             DLog(@"attachements: %@", exifAttachments);
//		 }
//         else
//             DLog(@"no attachments");
//        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        UIImage *overlay = [UIImage imageNamed:[self.overlays objectAtIndex:self.pageControl.currentPage]];
        self.previewViewController.image = [self mergeImage:image withImage:overlay];
        [self.navigationController pushViewController:self.previewViewController animated:YES];
	 }];
    
}

#pragma mark - UIViewController

- (void)dealloc {
    [_previewViewController release];
    [_aboutViewController release];
    [_overlayView release];
    [_pageControl release];
    [_cameraView release];
    [_swipeLeftRecognizer release];
    [_swipeRightRecognizer release];
    [_overlays release];
    [_captureDevice release];
    [_deviceInput release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"");
    
    UIImage *logo = [UIImage imageNamed:@"logo.png"];
    if (logo != nil) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logo];
    }
    else {
        self.navigationItem.title = [A4GSettings appName];
    }
    
    self.overlays = [A4GSettings overlays];
    self.overlayView.image = [UIImage imageNamed:[self.overlays objectAtIndex:0]];
    self.pageControl.numberOfPages = self.overlays.count;
    
    self.cameraView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = self.cameraView.frame;
    [self.cameraView.layer addSublayer:self.previewLayer];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.captureSession addOutput:self.stillImageOutput];
    
    NSError *error = nil;
	self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
	if (!self.deviceInput) {
		DLog(@"ERROR: %@", error);
	}
	[self.captureSession addInput:self.deviceInput];
    
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
    [self.view addGestureRecognizer:self.swipeLeftRecognizer];
    [self.view addGestureRecognizer:self.swipeRightRecognizer];
    [self.captureSession startRunning]; 
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
    [self.view removeGestureRecognizer:self.swipeLeftRecognizer];
    [self.view removeGestureRecognizer:self.swipeRightRecognizer];
    [self.captureSession stopRunning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - UISwipeGestureRecognizer

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer { 
    DLog(@"");
    if (self.pageControl.currentPage < self.overlays.count) {
        self.pageControl.currentPage += 1; 
        NSString *image = [self.overlays objectAtIndex:self.pageControl.currentPage];
        self.overlayView.image = [UIImage imageNamed:image];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    DLog(@""); 
    if (self.pageControl.currentPage > 0) {
        self.pageControl.currentPage -= 1; 
        NSString *image = [self.overlays objectAtIndex:self.pageControl.currentPage];
        self.overlayView.image = [UIImage imageNamed:image];
    }
}

- (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second {
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    UIGraphicsBeginImageContext(mergedSize);
    
    [first drawInRect:CGRectMake(0, 0, mergedSize.width, mergedSize.height)];
    [second drawInRect:CGRectMake(0, 0, mergedSize.width, mergedSize.height)]; 
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
