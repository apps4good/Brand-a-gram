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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SynthesizeSingleton.h"

@protocol A4GLocatorDelegate;

@interface A4GLocator : NSObject<CLLocationManagerDelegate>

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(A4GLocator);

@property(nonatomic, retain) NSNumber *latitude;
@property(nonatomic, retain) NSNumber *longitude;
@property(nonatomic, retain) NSString *address;

- (void) locateForDelegate:(NSObject<A4GLocatorDelegate>*)delegate;
- (void) lookupForDelegate:(NSObject<A4GLocatorDelegate>*)delegate;

- (BOOL) hasLocation;
- (BOOL) hasAddress;

@end

@protocol A4GLocatorDelegate <NSObject>

@optional

- (void) locateFinished:(A4GLocator *)locator latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;
- (void) locateFailed:(A4GLocator *)locator error:(NSError *)error;

- (void) lookupFinished:(A4GLocator *)locator address:(NSString *)address;
- (void) lookupFailed:(A4GLocator *)locator error:(NSError *)error;

@end
