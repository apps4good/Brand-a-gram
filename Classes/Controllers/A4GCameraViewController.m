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
#import "A4GLoadingView.h"

@interface A4GCameraViewController ()

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic) UISwipeGestureRecognizer * swipeLeftRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeRightRecognizer;
@property (strong, nonatomic) NSArray *overlays;

@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer;

- (void) captureImageInBackground;

- (void) processImage:(UIImage*)image;
- (void) processImageInBackground:(UIImage*)image;

- (void) saveImage:(UIImage*)image;
- (void) saveImageInBackground:(UIImage*)image;

- (void)savedImage:(UIImage *)image error:(NSError *)error context:(void *)contextInfo;
- (UIImage*)mergeImage:(UIImage*)image overlay:(UIImage*)overlay description:(NSString*)description latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude;

- (bool) cameraSupportsPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice*) captureDeviceWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice*) initializeCaptureDevice;
- (BOOL) hasWhiteBalance;
- (BOOL) hasFocus;
- (BOOL) hasExposure;

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
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize cameraButton = _cameraButton;
@synthesize flashButton = _flashButton;
@synthesize torchButton = _torchButton;
@synthesize focusButton = _focusButton;
@synthesize exposureButton = _exposureButton;
@synthesize whitebalanceButton = _whitebalanceButton;
@synthesize directionButton = _directionButton;

#pragma mark - IBActions

- (IBAction)about:(id)sender event:(UIEvent*)event {
    DLog(@""); 
    self.aboutViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentModalViewController:self.aboutViewController animated:YES];
}

- (IBAction)camera:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self showLoadingWithMessage:NSLocalizedString(@"Capturing...", nil)];
    [self performSelector:@selector(captureImageInBackground) withObject:nil afterDelay:0.2];
}

- (IBAction)direction:(id)sender event:(UIEvent*)event {
    DLog(@"");
    @try {
        for (AVCaptureDeviceInput *input in self.captureSession.inputs) {
            AVCaptureDevice *device = input.device;
            if ([device hasMediaType:AVMediaTypeVideo] ) {
                AVCaptureDevicePosition position = device.position;
                AVCaptureDevice *captureDevice = nil;
                if (position == AVCaptureDevicePositionFront) {
                    captureDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionBack];
                    [self.directionButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
                }
                else {
                    captureDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionFront];
                    [self.directionButton setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
                }
                 AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
                [self.captureSession beginConfiguration];
                [self.captureSession removeInput:self.deviceInput];
                [self.captureSession addInput:deviceInput];
                [self.captureSession commitConfiguration];
                self.deviceInput = deviceInput;
                break;
            }
        }
    }
    @catch (NSException *exception) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Flash Error", nil)
                           message:exception.description
                          delegate:self
                               tag:0
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil];
    }
}

- (IBAction)flash:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self.captureDevice lockForConfiguration:nil];
    @try {
        if ([self.captureDevice hasFlash]){
            if (self.captureDevice.flashMode == AVCaptureFlashModeOn) {
                self.captureDevice.flashMode = AVCaptureFlashModeOff;
                self.flashButton.image = [UIImage imageNamed:@"flashoff.png"];
            }
            else {
                self.captureDevice.flashMode = AVCaptureFlashModeOn;
                self.flashButton.image = [UIImage imageNamed:@"flashon.png"];
            }
        }
    }
    @catch (NSException *exception) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Flash Error", nil)
                           message:exception.description
                          delegate:self
                               tag:0
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil];
    }
    [self.captureDevice unlockForConfiguration];
}

- (IBAction)torch:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self.captureDevice lockForConfiguration:nil];
    @try {
        if ([self.captureDevice hasTorch]){
            if (self.captureDevice.torchMode == AVCaptureTorchModeOn) {
                self.captureDevice.torchMode = AVCaptureTorchModeOff;
                self.torchButton.image = [UIImage imageNamed:@"torchoff.png"];
            }
            else {
                self.captureDevice.torchMode = AVCaptureTorchModeOn;
                self.torchButton.image = [UIImage imageNamed:@"torchon.png"];
            }
        }
    }
    @catch (NSException *exception) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Torch Error", nil)
                           message:exception.description
                          delegate:self
                               tag:0
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil];
    }
    [self.captureDevice unlockForConfiguration];
}

- (IBAction)focus:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self.captureDevice lockForConfiguration:nil];
    @try {
        if ([self hasFocus]){
            if (self.captureDevice.focusMode == AVCaptureFocusModeAutoFocus ||
                self.captureDevice.focusMode == AVCaptureFocusModeContinuousAutoFocus ) {
                self.captureDevice.focusMode = AVCaptureFocusModeLocked;
                self.focusButton.image = [UIImage imageNamed:@"focusoff.png"];
            }
            else if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                self.captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                self.focusButton.image = [UIImage imageNamed:@"focuson.png"];
            }
            else if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                self.captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
                self.focusButton.image = [UIImage imageNamed:@"focuson.png"];        
            }
        }
    }
    @catch (NSException *exception) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Focus Error", nil) 
                           message:exception.description 
                          delegate:self 
                               tag:0 
                 cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                 otherButtonTitles:nil];
    }
    [self.captureDevice unlockForConfiguration];
}

- (IBAction)whitebalance:(id)sender event:(UIEvent *)event {
    DLog(@"");
    [self.captureDevice lockForConfiguration:nil];
    @try {
        if ([self hasWhiteBalance]){
            if (self.captureDevice.whiteBalanceMode == AVCaptureWhiteBalanceModeAutoWhiteBalance ||
                self.captureDevice.whiteBalanceMode == AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance ) {
                self.captureDevice.whiteBalanceMode = AVCaptureFocusModeLocked;
                self.whitebalanceButton.image = [UIImage imageNamed:@"whitebalanceoff.png"];
            }
            else if ([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                self.captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
                self.whitebalanceButton.image = [UIImage imageNamed:@"whitebalanceon.png"];
            }
            else if ([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                self.captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
                self.whitebalanceButton.image = [UIImage imageNamed:@"whitebalanceon.png"];
            }
        }
    }
    @catch (NSException *exception) {
        [UIAlertView showWithTitle:NSLocalizedString(@"White Balance Error", nil)
                           message:exception.description
                          delegate:self
                               tag:0
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil];
    }
    [self.captureDevice unlockForConfiguration];
}

- (IBAction)exposure:(id)sender event:(UIEvent *)event  {    
    DLog(@"");
    [self.captureDevice lockForConfiguration:nil];
    @try {
        if ([self hasExposure]) {
            if (self.captureDevice.exposureMode == AVCaptureExposureModeAutoExpose ||
                self.captureDevice.exposureMode == AVCaptureExposureModeContinuousAutoExposure) {
                self.captureDevice.exposureMode = AVCaptureExposureModeLocked;
                self.exposureButton.image = [UIImage imageNamed:@"exposureoff.png"];
            }
            else if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                self.captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                self.exposureButton.image = [UIImage imageNamed:@"exposureon.png"];
            }
            else if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                self.captureDevice.exposureMode = AVCaptureExposureModeAutoExpose;
                self.exposureButton.image = [UIImage imageNamed:@"exposureon.png"];
            }
        }        
    }
    @catch (NSException *exception) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Exposure Error", nil) 
                           message:exception.description 
                          delegate:self 
                               tag:0 
                 cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                 otherButtonTitles:nil];
    }
    [self.captureDevice unlockForConfiguration];
}

#pragma mark - AVFoundation

- (AVCaptureDevice*) initializeCaptureDevice {
    DLog(@"Creating AVCaptureSession...");
    [self showLoadingWithMessage:NSLocalizedString(@"Session...", nil)];
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    DLog(@"Creating AVCaptureDevice...");
    [self showLoadingWithMessage:NSLocalizedString(@"Capture...", nil)];
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];  
    if (self.captureDevice.position == AVCaptureDevicePositionFront) {
        [self.directionButton setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
        self.directionButton.enabled = YES;
    }
    else if (self.captureDevice.position == AVCaptureDevicePositionBack) {
        [self.directionButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        self.directionButton.enabled = YES;
    }
    else {
        [self.directionButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        self.directionButton.enabled = NO;
    }
    
    [self showLoadingWithMessage:NSLocalizedString(@"Layers...", nil)];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = self.cameraView.frame;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.cameraView.layer addSublayer:self.previewLayer];   
    
    [self showLoadingWithMessage:NSLocalizedString(@"Input...", nil)];
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, AVVideoScalingModeResizeAspectFill, AVVideoScalingModeKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.captureSession addOutput:self.stillImageOutput];
    
    [self.captureSession beginConfiguration];
    
    NSError *error = nil;
    [self showLoadingWithMessage:NSLocalizedString(@"Camera...", nil)];
	self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
	if (error) {
		DLog(@"Error: %@", error);
        self.flashButton.enabled = NO;
        self.torchButton.enabled = NO;
        self.directionButton.enabled = NO;
        [UIAlertView showWithTitle:NSLocalizedString(@"Camera Error", nil) 
                           message:error.localizedDescription 
                          delegate:self 
                               tag:0 
                 cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                 otherButtonTitles:nil];
	}
    else if ([self.captureSession canAddInput:self.deviceInput]) {
        [self.captureSession addInput:self.deviceInput];
    }
    else {
        DLog(@"Unable to add Input Device");
        self.flashButton.enabled = NO;
        self.torchButton.enabled = NO;
        self.directionButton.enabled = NO;
        [UIAlertView showWithTitle:NSLocalizedString(@"Camera Error", nil) 
                           message:NSLocalizedString(@"Unable to load camera device", nil) 
                          delegate:self tag:0 cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                 otherButtonTitles:nil];
    }
    
    if ([self.captureDevice hasFlash]) {
        if (self.captureDevice.flashMode == AVCaptureFlashModeOn) {
            self.flashButton.image = [UIImage imageNamed:@"flashon.png"];
        }
        else {
            self.flashButton.image = [UIImage imageNamed:@"flashoff.png"];
        }
        self.flashButton.enabled = YES;
    }
    else {
        self.flashButton.image = [UIImage imageNamed:@"flashoff.png"];
        self.flashButton.enabled = NO;
    }
    
    if ([self.captureDevice hasTorch]) {
        if (self.captureDevice.torchMode == AVCaptureTorchModeOn) {
            self.torchButton.image = [UIImage imageNamed:@"torchon.png"];
        }
        else {
            self.torchButton.image = [UIImage imageNamed:@"torchoff.png"];
        }
        self.torchButton.enabled = YES;
    }
    else {
        self.torchButton.image = [UIImage imageNamed:@"torchoff.png"];
        self.torchButton.enabled = NO;
    }
    
    if ([self hasWhiteBalance]) {
        if (self.captureDevice.whiteBalanceMode == AVCaptureWhiteBalanceModeAutoWhiteBalance ||
            self.captureDevice.whiteBalanceMode == AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance) {
            self.whitebalanceButton.image = [UIImage imageNamed:@"whitebalanceon.png"];
        }
        else {
            self.whitebalanceButton.image = [UIImage imageNamed:@"whitebalanceoff.png"];
        }   
        self.whitebalanceButton.enabled = YES;
    }
    else {
        self.whitebalanceButton.enabled = NO;
    }
    
    if ([self hasFocus]) {
        if (self.captureDevice.focusMode == AVCaptureFocusModeAutoFocus||
            self.captureDevice.focusMode == AVCaptureFocusModeContinuousAutoFocus) {
            self.focusButton.image = [UIImage imageNamed:@"focuson.png"];
        }
        else {
            self.focusButton.image = [UIImage imageNamed:@"focusoff.png"];
        }   
        self.focusButton.enabled = YES;
    }
    else {
        self.focusButton.enabled = NO;
    }
    
    if ([self hasExposure]) {
        if (self.captureDevice.exposureMode == AVCaptureExposureModeAutoExpose||
            self.captureDevice.exposureMode == AVCaptureExposureModeContinuousAutoExposure) {
            self.exposureButton.image = [UIImage imageNamed:@"exposureon.png"];
        }
        else {
            self.exposureButton.image = [UIImage imageNamed:@"exposureoff.png"];
        }
        self.exposureButton.enabled = YES;
    }
    else {
        self.exposureButton.enabled = NO;
    }
    
    [self.captureSession commitConfiguration];
    
    [self hideLoading];
    return self.captureDevice;
}

- (BOOL) hasWhiteBalance {
    return  [self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked] ||
            [self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance] || 
            [self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
}

- (BOOL) hasFocus {
    return  [self.captureDevice isFocusModeSupported:AVCaptureFocusModeLocked] ||
            [self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
            [self.captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

- (BOOL) hasExposure {
    return  [self.captureDevice isExposureModeSupported:AVCaptureExposureModeLocked] ||
            [self.captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
            [self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (AVCaptureDevice *) captureDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (bool) cameraSupportsPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return YES;
        }
    }
    return NO;
}

- (void) captureImageInBackground {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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
            if (error) {
                DLog(@"Error:%@", [error description]);
                [self hideLoading];
            }
            else {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];
                [self performSelectorOnMainThread:@selector(processImage:) withObject:image waitUntilDone:YES];
            }
        }];
    }
    [pool release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"running"] ){
        if (self.captureSession.running) {
            [self hideLoading];
        }
        else {
            [self showLoadingWithMessage:NSLocalizedString(@"Loading...", nil)];
        }
    }
}

#pragma mark - UIImage

- (void)processImage:(UIImage*)image {
    [self showLoadingWithMessage:NSLocalizedString(@"Processing...", nil)];
    [self performSelector:@selector(processImageInBackground:) withObject:image afterDelay:0.2];
}

- (void)processImageInBackground:(UIImage*)image {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    DLog(@"Image:%@", NSStringFromCGSize(image.size));
    UIImage *overlay = self.overlayView.image;
    DLog(@"Overlay:%@", NSStringFromCGSize(overlay.size));
    UIImage *merged = [self mergeImage:image 
                               overlay:overlay 
                           description:[A4GSettings appText] 
                              latitude:self.latitude 
                             longitude:self.longitude];
    DLog(@"Merged:%@", NSStringFromCGSize(merged.size));
    [self performSelectorOnMainThread:@selector(saveImage:) withObject:merged waitUntilDone:YES];
    [pool release];
}

- (void) saveImage:(UIImage*)image {
    [self showLoadingWithMessage:NSLocalizedString(@"Saving...", nil)];
    [self performSelector:@selector(saveImageInBackground:) withObject:image afterDelay:0.2];
}

- (void) saveImageInBackground:(UIImage*)image {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedImage:error:context:), image);
    [pool release];
}

- (void)savedImage:(UIImage *)image error:(NSError *)error context:(void *)contextInfo {
    DLog(@"");
    self.previewViewController.image = image;
    [self.navigationController pushViewController:self.previewViewController animated:YES];
    [self hideLoading];
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
    [_cameraButton release];
    [_flashButton release];
    [_torchButton release];
    [_exposureButton release];
    [_directionButton release];
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
    if ([self.cameraButton respondsToSelector:@selector(tintColor)]) {
        self.cameraButton.tintColor = [A4GSettings buttonDoneColor];    
    }
    
    [self initializeCaptureDevice];
    
    [self.captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
     
    self.overlays = [A4GSettings overlays];
    self.overlayView.image = [UIImage imageNamed:[self.overlays objectAtIndex:0]];
    self.pageControl.numberOfPages = self.overlays.count;
    self.cameraView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.swipeLeftRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)] autorelease];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.swipeRightRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)] autorelease];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void) viewDidUnload {
    [super viewDidUnload];
    [self.captureSession removeObserver:self forKeyPath:@"running"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"");
    CGRect frame = self.containerView.frame;
    frame.size.height = frame.size.width;
    frame.origin.y = (self.containerView.superview.frame.size.height - frame.size.height) / 2;
    self.containerView.frame = frame;
    
    [self.view addGestureRecognizer:self.swipeLeftRecognizer];
    [self.view addGestureRecognizer:self.swipeRightRecognizer];
    
    [self.captureSession startRunning]; 
    
    [[A4GLocator sharedInstance] locateForDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DLog(@"");
    [self hideLoading];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];    
    DLog(@"");
    [self.view removeGestureRecognizer:self.swipeLeftRecognizer];
    [self.view removeGestureRecognizer:self.swipeRightRecognizer];
    [self.captureSession stopRunning];
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

- (UIImage*)mergeImage:(UIImage*)image overlay:(UIImage*)overlay description:(NSString*)description latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    UIGraphicsBeginImageContext(overlay.size);
    DLog(@"Image:%f,%f", image.size.width, image.size.height);
    
    CGFloat resizedWidth = overlay.size.width;
    CGFloat resizedHeight = overlay.size.width * image.size.height / image.size.width;
    
    [image drawInRect:CGRectMake(0, 0, resizedWidth, resizedHeight)];
    DLog(@"Resized:%f,%f", resizedWidth, resizedHeight);
    
    [overlay drawInRect:CGRectMake(0, 0, overlay.size.width, overlay.size.height)]; 
    DLog(@"Overlay:%f,%f", overlay.size.width, overlay.size.height);
    
    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *jpeg = UIImageJPEGRepresentation(mergedImage, 1.0);
    CGImageSourceRef  source = CGImageSourceCreateWithData((CFDataRef)jpeg, NULL);
    
    NSDictionary *metadata = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    NSMutableDictionary *metadataAsMutable = [[metadata mutableCopy]autorelease];
    [metadata release];
    
    NSMutableDictionary *gps = [[[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy]autorelease];
    if(!gps) {
        gps = [NSMutableDictionary dictionary];
    }
    [gps setValue:latitude forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [gps setValue:longitude forKey:(NSString*)kCGImagePropertyGPSLongitude];
    
    NSMutableDictionary *exif = [[[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy]autorelease];
    if(!exif) {
        exif = [NSMutableDictionary dictionary];
    }
    [exif setValue:description forKey:(NSString *)kCGImagePropertyExifUserComment];
    
    [metadataAsMutable setObject:exif forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:gps forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    CFStringRef uti = CGImageSourceGetType(source); 
    NSMutableData *data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data,uti,1,NULL);
    if(!destination) {
        DLog(@"***Could not create image destination ***");
    }
    
    CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) metadataAsMutable);
    if(!CGImageDestinationFinalize(destination)) {
        DLog(@"***Could not create data from image destination ***");
    }
    
    CFRelease(destination);
    CFRelease(source);
    
    return mergedImage;
}

#pragma mark - A4GLocator

- (void) locateFinished:(A4GLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    DLog(@"%@,%@", latitude, longitude);
    self.latitude = latitude;
    self.longitude = longitude;
}

- (void) locateFailed:(A4GLocator *)locator error:(NSError *)error {
    DLog(@"Error:%@", [error description]);
}

@end
