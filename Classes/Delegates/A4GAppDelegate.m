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
#import "A4GSettings.h"

@interface A4GAppDelegate ()

@end

@implementation A4GAppDelegate

@synthesize window = _window;
@synthesize cameraViewController = _cameraViewController;
@synthesize previewViewController = _previewViewController;
@synthesize aboutViewController = _aboutViewController;

#pragma mark - FBSession

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark - UIApplicationDelegate

- (void)dealloc {
    [_window release];
    [_cameraViewController release];
    [_previewViewController release];
    [_aboutViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FBProfilePictureView class];
    if (self.window == nil) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    DLog(@"");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"");  
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    DLog(@"");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DLog(@"");
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"");
    [FBSession.activeSession close];
}

@end
