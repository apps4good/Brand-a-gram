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

#import "A4GLocator.h"
#import "NSObject+A4G.h"
#import "NSString+A4G.h"
#import "NSError+A4G.h"
#import "SBJson.h"

@interface A4GLocator ()

@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) CLGeocoder *geoCoder;
@property(nonatomic, retain) NSObject<A4GLocatorDelegate> *delegate;

@end

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(A4GLocator);

@implementation A4GLocator

SYNTHESIZE_SINGLETON_FOR_CLASS(A4GLocator);

@synthesize delegate = _delegate;
@synthesize locationManager = _locationManager;
@synthesize geoCoder = _geoCoder;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize address = _address;

- (id) init {
	if ((self = [super init])) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.geoCoder = [[CLGeocoder alloc] init];
	}
	return self;
}

- (void)dealloc {
	[_delegate release];
	[_locationManager release];
	[_geoCoder release];
	[_latitude release];
	[_longitude release];
    [_address release];
	[super dealloc];
}

- (BOOL) hasLocation {
	return self.latitude != nil && self.longitude != nil;
}

- (BOOL) hasAddress {
	return [NSString isNilOrEmpty:self.address] == NO;
}

- (void)locateForDelegate:(id<A4GLocatorDelegate>)delegate {
	DLog(@"");
	self.delegate = delegate;
	[self.locationManager startUpdatingLocation];
}

- (void)lookupForDelegate:(id<A4GLocatorDelegate>)delegate {
	DLog(@"latitude:%@ longitude:%@", self.latitude, self.longitude);
	self.delegate = delegate;
    [self.geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler: 
     ^(NSArray *placemarks, NSError *error) {
         if (error) {
             [self.delegate performSelectorOnMainThread:@selector(lookupFailed:error:) 
                                          waitUntilDone:YES 
                                            withObjects:self, error, nil];
         }
         else {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             DLog(@"Placemark:%@", placemark);
             NSMutableArray *items = [NSMutableArray array];
             if ([NSString isNilOrEmpty:placemark.name] == NO) {
                 [items addObject:placemark.name];
             }
             if ([NSString isNilOrEmpty:placemark.locality] == NO) {
                 [items addObject:placemark.locality];
             }
             if ([NSString isNilOrEmpty:placemark.administrativeArea] == NO) {
                 [items addObject:placemark.administrativeArea];
             }
             if ([NSString isNilOrEmpty:placemark.country] == NO) {
                 [items addObject:placemark.country];
             }
             self.address = [items componentsJoinedByString:@", "];
             [self.delegate performSelectorOnMainThread:@selector(lookupFinished:address:) 
                                          waitUntilDone:YES 
                                            withObjects:self, self.address, nil];
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    DLog(@"%@", newLocation);
	if (newLocation != nil && abs([newLocation.timestamp timeIntervalSinceNow]) < 15.0) {
		self.latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
        self.longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
        [self.delegate performSelectorOnMainThread:@selector(locateFinished:latitude:longitude:) 
                                     waitUntilDone:YES 
                                       withObjects:self, self.latitude, self.longitude, nil];
		[self.locationManager stopUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	DLog(@"Error: %@", [error localizedDescription]);
	[self.locationManager stopUpdatingLocation];
    [self.delegate performSelectorOnMainThread:@selector(locateFailed:error:) 
                                 waitUntilDone:YES 
                                   withObjects:self, error, nil];
}

@end
