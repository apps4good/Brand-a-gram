// ##########################################################################################
// 
// Copyright (c) 2012, Apps4Good. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are 
// permitted provided that the following conditions are met:
// 
// 1) Redistributions of source code must retain the above copyright notice, this list of 
//    conditions and the following disclaimer.
// 2) Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
// 3) Neither the name of the Apps4Good nor the names of its contributors may be used to 
//    endorse or promote products derived from this software without specific prior written 
//    permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// ##########################################################################################

#import "A4GCameraViewController.h"
#import "A4GPreviewViewController.h"
#import "A4GAboutViewController.h"
#import "A4GSettings.h"
#import "UIColor+A4G.h"
#import "UIAlertView+A4G.h"

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
@synthesize containerView = _containerView;
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
    if (videoConnection != nil) {
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
            DLog(@"");
//            CFDictionaryRef exif = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
//            if (exif) {
//                DLog(@"EXIF: %@", exif);
//            }
//            else
//                DLog(@"No EXIF");
//            }
            if (error) {
                DLog(@"Error:%@", [error description]);
            }
            else {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];
                UIImage *overlay = self.overlayView.image;
                self.previewViewController.image = [self mergeImage:image withImage:overlay];
                DLog(@"Size:%@", NSStringFromCGSize(self.previewViewController.image.size));
//                [UIAlertView showWithTitle:@"Merged Size" 
//                                   message:NSStringFromCGSize(self.previewViewController.image.size) 
//                                  delegate:self 
//                                       tag:0 
//                         cancelButtonTitle:@"OK" 
//                         otherButtonTitles:nil];
                [self.navigationController pushViewController:self.previewViewController animated:YES];            
            }
         }];
    }
    else {
        self.previewViewController.image = nil;
        [self.navigationController pushViewController:self.previewViewController animated:YES]; 
    }
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
    [_containerView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"");
    
    UIImage *title = [UIImage imageNamed:@"title.png"];
    if (title != nil) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:title];
    }
    else {
        self.navigationItem.title = [A4GSettings appName];
    }
    
    CGRect frame = self.containerView.frame;
    frame.size.height = frame.size.width;
    frame.origin.y = (self.view.frame.size.height - frame.size.height) / 2;
    self.containerView.frame = frame;
    
    self.overlays = [A4GSettings overlays];
    self.overlayView.image = [UIImage imageNamed:[self.overlays objectAtIndex:0]];
    self.pageControl.numberOfPages = self.overlays.count;
    
    self.cameraView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = self.cameraView.frame;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
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
    CGSize mergedSize = CGSizeMake(second.size.width, second.size.height);
    UIGraphicsBeginImageContext(mergedSize);
    
    [first drawInRect:CGRectMake(0, 0, mergedSize.width, mergedSize.height)];
    [second drawInRect:CGRectMake(0, 0, mergedSize.width, mergedSize.height)]; 
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
