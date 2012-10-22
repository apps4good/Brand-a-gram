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

#import "A4GTwitterViewController.h"
#import "A4GSettings.h"
#import "A4GDevice.h"

@interface A4GTwitterViewController ()

@property (strong, nonatomic) A4GLoadingView *loadingView;
@property (strong, nonatomic) NSString *javascript;

@end

@implementation A4GTwitterViewController

@synthesize loadingView = _loadingView;
@synthesize webView = _webView;
@synthesize navBar = _navBar;
@synthesize url = _url;
@synthesize name = _name;
@synthesize summary = _summary;
@synthesize javascript = _javascript;
@synthesize image = _image;

#pragma mark - Handlers

- (IBAction)cancel:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIViewController

- (void)dealloc {
    [_webView release];
    [_navBar release];
    [_name release];
    [_url release];
    [_javascript release];
    [_image release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBar.tintColor = [A4GSettings navBarColor];
    self.navBar.topItem.title = NSLocalizedString(@"Twitter", nil);
    self.loadingView = [A4GLoadingView initWithController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *path = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?url=%@&text=%@", 
                      self.url, [self.name stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    DLog(@"URL:%@", path);
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request]; 
    if ([A4GDevice isIPad]) {
        CGRect frame = self.view.superview.frame;
        frame.size.width = 500;
        frame.size.height = 400;
        self.view.superview.frame = frame;   
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.loadingView centerView];
    self.view.superview.center = self.view.superview.superview.center;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIWebViewController

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    if (navigationType == UIWebViewNavigationTypeFormResubmitted) {
        DLog(@"FormResubmitted %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        DLog(@"FormSubmitted %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeBackForward) {
        DLog(@"BackForward %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        DLog(@"LinkClicked %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeOther) {
        DLog(@"Other %@", url);    
    }
    else if (navigationType == UIWebViewNavigationTypeReload) {
        DLog(@"Reload %@", url);    
    }
    else {
        DLog(@"%d %@", navigationType, url);
    }
    if ([url isEqualToString:@"https://mobile.twitter.com/"]) {
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    if ([url isEqualToString:@"https://mobile.twitter.com/signup"]) {
        if ([A4GDevice isIPad]) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.superview.frame;
            frame.size.width = 700;
            frame.size.height = 615;
            self.view.superview.frame = frame;
            self.view.superview.center = self.view.superview.superview.center;
            [UIView commitAnimations];
        }
    }
    if ([url hasPrefix:@"https://twitter.com/intent/tweet?url="]) {
        if ([A4GDevice isIPad]) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.superview.frame;
            frame.size.width = 500;
            frame.size.height = 350;
            self.view.superview.frame = frame;
            [UIView commitAnimations];
        }
    }   
    if ([url isEqualToString:@"https://twitter.com/intent/tweet/update"]) {
        [self.loadingView showWithMessage:@"Sending..."];
    }
    if ([url hasPrefix:@"https://twitter.com/intent/tweet/complete"]) {
        [self.loadingView showWithMessage:@"Sent!"];
        [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:1.5];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    DLog(@"%@", [[webView request] URL]);
    NSString *url = [[[webView request] URL] absoluteString];
    if ([url isEqualToString:@"https://twitter.com/intent/tweet/update"]) {
        [self.loadingView showWithMessage:@"Sending..."];
    }
    else {
        [self.loadingView show];   
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    DLog(@"%@", [[webView request] URL]);
    NSString *url = [[[webView request] URL] absoluteString];
    if ([url hasPrefix:@"https://twitter.com/intent/tweet?url="]) {
        [self.loadingView hide];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"Error:%@", [error description]);
}

@end
