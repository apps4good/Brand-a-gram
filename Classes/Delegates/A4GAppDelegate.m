//
//  A4GAppDelegate.m
//  Brandagram
//
//  Created by Dale Zak on 12-10-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "A4GAppDelegate.h"
#import "A4GCameraViewController.h"
#import "A4GPreviewViewController.h"
#import "A4GAboutViewController.h"

@implementation A4GAppDelegate

@synthesize window = _window;
@synthesize cameraViewController = _cameraViewController;
@synthesize previewViewController = _previewViewController;
@synthesize aboutViewController = _aboutViewController;

- (void)dealloc {
    [_window release];
    [_cameraViewController release];
    [_previewViewController release];
    [_aboutViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (self.window == nil) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  }

- (void)applicationWillEnterForeground:(UIApplication *)application {
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
   
}

@end
