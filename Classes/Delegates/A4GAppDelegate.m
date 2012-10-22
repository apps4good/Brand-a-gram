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

@property (nonatomic, retain) Facebook *facebook;

@end

@implementation A4GAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;
@synthesize cameraViewController = _cameraViewController;
@synthesize previewViewController = _previewViewController;
@synthesize aboutViewController = _aboutViewController;

- (void)dealloc {
    [_window release];
    [_facebook release];
    [_cameraViewController release];
    [_previewViewController release];
    [_aboutViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.facebook = [[Facebook alloc] initWithAppId:[A4GSettings facebookAppID] andDelegate:self];
    self.facebook.accessToken = [A4GSettings facebookTokenKey];
    self.facebook.expirationDate = [A4GSettings facebookDateKey];
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"");
}

#pragma mark - FBConnect

- (void)fbDidLogin {
    DLog(@"%@ : %@", [self.facebook accessToken], [self.facebook expirationDate]);
    [A4GSettings setFacebookTokenKey:[self.facebook accessToken]];
    [A4GSettings setFacebookDateKey:[self.facebook expirationDate]];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    DLog(@"");
    [A4GSettings setFacebookTokenKey:nil];
    [A4GSettings setFacebookDateKey:nil];  
}

- (void) fbDidLogout {
    DLog(@"");
    [A4GSettings setFacebookTokenKey:nil];
    [A4GSettings setFacebookDateKey:nil];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    DLog(@"%@ : %@", accessToken, expiresAt);
    [A4GSettings setFacebookTokenKey:accessToken];
    [A4GSettings setFacebookDateKey:expiresAt];
}

- (void)fbSessionInvalidated {
    DLog(@"");
    [A4GSettings setFacebookTokenKey:nil];
    [A4GSettings setFacebookDateKey:nil];
}

@end
