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
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol A4GShareControllerDelegate;

@interface A4GShareController : NSObject<UIAlertViewDelegate,
                                         UIActionSheetDelegate,
                                         UIPrintInteractionControllerDelegate,
                                         UIDocumentInteractionControllerDelegate,
                                         MFMailComposeViewControllerDelegate,
                                         MFMessageComposeViewControllerDelegate,
                                         FBLoginViewDelegate>

- (id) initWithController:(UIViewController<A4GShareControllerDelegate>*)controller;

- (void) shareForEvent:(UIEvent*)event 
                  open:(BOOL)open
                 print:(BOOL)print 
                  copy:(BOOL)copy 
                   sms:(BOOL)sms
                 email:(BOOL)email
               twitter:(BOOL)twitter
              facebook:(bool)facebook;

- (BOOL) canCallNumber:(NSString*)number;
- (void) callNumber:(NSString *)number;

- (BOOL) canPrintText;
- (void) printData:(NSData*)data title:(NSString*)title;
- (void) printText:(NSString*)text title:(NSString*)title;

- (BOOL) canCopyText;
- (void) copyText:(NSString *)string;

- (BOOL) canSendSMS;
- (void) sendSMS:(NSString *)message;

- (BOOL) canSendEmail;
- (void) sendEmail:(NSString*)message subject:(NSString *)subject attachment:(NSData*)attachment fileName:(NSString*)fileName recipient:(NSString*)recipient;
- (void) sendEmail:(NSString*)message subject:(NSString *)subject attachment:(NSData*)attachment fileName:(NSString*)fileName recipients:(NSArray*)recipients;

- (BOOL) canSendTweet;
- (void) sendTweet:(NSString*)tweet url:(NSString*)url;
- (void) sendTweet:(NSString*)tweet url:(NSString*)url image:(UIImage*)image;

- (BOOL) canOpenURL:(NSString*)url;
- (void) openURL:(NSString *)url;

- (BOOL) canOpenIn:(NSString *)url;
- (BOOL) canOpenInWithUrl:(NSURL *)url;
- (void) showOpenInWithUrl:(NSString*)url;

- (void) postFacebook:(NSString*)text url:(NSString*)url;
- (void) postFacebook:(NSString*)text url:(NSString*)url image:(UIImage*)image;

@end

@protocol A4GShareControllerDelegate <NSObject>

@optional

- (void) shareOpenIn:(A4GShareController*)share;
- (void) shareOpenURL:(A4GShareController*)share;
- (void) sharePrintText:(A4GShareController*)share;
- (void) shareCopyText:(A4GShareController*)share;
- (void) shareSendSMS:(A4GShareController*)share;
- (void) shareSendEmail:(A4GShareController*)share;
- (void) shareSendTweet:(A4GShareController*)share;
- (void) sharePostFacebook:(A4GShareController*)share;
- (void) shareShowQRCode:(A4GShareController*)share;

@end
