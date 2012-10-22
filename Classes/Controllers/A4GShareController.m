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

#import "A4GShareController.h"
#import "A4GSettings.h"
#import "UIAlertView+A4G.h"
#import "UIViewController+A4G.h"
#import "A4GLoadingView.h"
#import "A4GDevice.h"
#import "A4GTwitterViewController.h"

@interface A4GShareController ()

@property (strong, nonatomic) UIViewController<A4GShareControllerDelegate> *controller;
@property (strong, nonatomic) NSString *textShareSMS;
@property (strong, nonatomic) NSString *textShareEmail;
@property (strong, nonatomic) NSString *textCopyClipboard;
@property (strong, nonatomic) NSString *textShareTwitter;
@property (strong, nonatomic) NSString *textPrintDetails;
@property (strong, nonatomic) NSString *textCancelAction;
@property (strong, nonatomic) NSString *textShareFacebook;
@property (strong, nonatomic) NSString *textOpenIn;
@property (strong, nonatomic) A4GLoadingView *loadingView;
@property (strong, nonatomic) Facebook *facebook;
@property (assign, nonatomic) CGRect touch;

@end

@implementation A4GShareController

@synthesize controller = _controller;
@synthesize textShareSMS = _textShareSMS;
@synthesize textShareEmail = _textShareEmail;
@synthesize textCopyClipboard = _textCopyClipboard;
@synthesize textShareTwitter = _textShareTwitter;
@synthesize textPrintDetails = _textPrintDetails;
@synthesize textCancelAction = _textCancelAction;
@synthesize textShareFacebook = _textShareFacebook;
@synthesize textOpenIn = _textOpenIn;
@synthesize loadingView = _loadingView;
@synthesize facebook = _facebook;
@synthesize touch = _touch;

typedef enum {
    AlertViewError,
    AlertViewWebsite
} AlertView;

#pragma mark - NSObject

- (id) initWithController:(UIViewController<A4GShareControllerDelegate>*)controller {
    if (self = [super init]) {
        self.controller = controller;
        self.loadingView = [A4GLoadingView initWithController:controller];
        self.textShareEmail = NSLocalizedString(@"Share via Email", nil);
        self.textShareSMS = NSLocalizedString(@"Share via SMS", nil);
        self.textShareTwitter = NSLocalizedString(@"Share via Twitter", nil);
        self.textShareFacebook = NSLocalizedString(@"Share via Facebook", nil);
        self.textPrintDetails = NSLocalizedString(@"Print Information", nil);
        self.textCopyClipboard = NSLocalizedString(@"Copy to Clipboard", nil);
        self.textOpenIn = NSLocalizedString(@"Open In...", nil);
        self.textCancelAction = NSLocalizedString(@"Cancel", nil);
        self.facebook = [[Facebook alloc] initWithAppId:[A4GSettings facebookAppID] andDelegate:self];
        self.facebook.accessToken = [A4GSettings facebookTokenKey];
        self.facebook.expirationDate = [A4GSettings facebookDateKey];
    }
    return self;
}

- (void)dealloc {
    [_controller release];
    [_loadingView release];
    [_textShareTwitter release];
    [_textShareSMS release];
    [_textPrintDetails release];
    [_textCancelAction release];
    [_textCopyClipboard release];
    [_textShareFacebook release];
    [_facebook release];
    [super dealloc];
}

#pragma mark - UIActionSheetDelegate

- (void) shareForEvent:(UIEvent*)event open:(BOOL)open print:(BOOL)print copy:(BOOL)copy sms:(BOOL)sms email:(BOOL)email twitter:(BOOL)twitter facebook:(bool)facebook {
    DLog(@"open:%d print:%d copy:%d sms:%d email:%d twitter:%d facebook:%d", open, print, copy, sms, email, twitter, facebook);
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil] autorelease];
    if (open) {
        DLog(@"canOpenURL");
        [actionSheet addButtonWithTitle:self.textOpenIn];
    }
    if (print && [self canPrintText]) {
        DLog(@"canPrintText");
        [actionSheet addButtonWithTitle:self.textPrintDetails];
    }
    if (copy && [self canCopyText]) {
        DLog(@"canCopyText");
        [actionSheet addButtonWithTitle:self.textCopyClipboard];
    }
    if (email && [self canSendEmail]) {
        DLog(@"canSendMail");
        [actionSheet addButtonWithTitle:self.textShareEmail];
    }
    if (sms && [self canSendSMS]) {
        DLog(@"canSendSMS");
        [actionSheet addButtonWithTitle:self.textShareSMS];
    }
    if (twitter && [self canSendTweet]) {
        DLog(@"canSendTweet");
        [actionSheet addButtonWithTitle:self.textShareTwitter];
    }
    if (facebook) {
        DLog(@"canShareFacebook");
        [actionSheet addButtonWithTitle:self.textShareFacebook];
    }
    self.touch = [self.controller touchForEvent:event];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:self.textCancelAction];
    [actionSheet showFromRect:self.touch inView:self.controller.view animated:YES]; 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareSMS]) {
        if ([self.controller respondsToSelector:@selector(shareSendSMS:)]) {
            [self.controller shareSendSMS:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareEmail]) {
        if ([self.controller respondsToSelector:@selector(shareSendEmail:)]) {
            [self.controller shareSendEmail:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareTwitter]) {
        if ([self.controller respondsToSelector:@selector(shareSendTweet:)]) {
            [self.controller shareSendTweet:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textPrintDetails]) {
        if ([self.controller respondsToSelector:@selector(sharePrintText:)]) {
            [self.controller sharePrintText:self];
        }
    } 
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textCopyClipboard]) {
        if ([self.controller respondsToSelector:@selector(shareCopyText:)]) {
            [self.controller shareCopyText:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareFacebook]) {
        if ([self.controller respondsToSelector:@selector(sharePostFacebook:)]) {
            [self.controller sharePostFacebook:self];
        }
    }
}

#pragma mark - Call Number

- (BOOL) canCallNumber:(NSString*)number {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
    return [[UIApplication sharedApplication] canOpenURL:url];
}


- (void) callNumber:(NSString *)number {
    DLog(@"Number:%@", number);
    if ([self canCallNumber:number]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
        [[UIApplication sharedApplication] openURL:url];    
    }
}

#pragma mark - Open URL

- (BOOL) canOpenURL:(NSString*)url {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

- (void) openURL:(NSString *)url {
    DLog(@"URL:%@", url);
    if ([self canOpenURL:url]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Open in Safari?", nil) 
                           message:url 
                          delegate:self 
                               tag:AlertViewWebsite 
                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    }
}

#pragma mark - UIPasteboard

- (BOOL) canCopyText {
    return NSClassFromString(@"UIPasteboard") != nil;
}

- (void) copyText:(NSString *)string {
    DLog(@"Text:%@", string);
    if ([self canCopyText]) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.persistent = YES;
        pasteBoard.string = string;
        [self.loadingView showWithMessage:NSLocalizedString(@"Copied", nil)];
        [self.loadingView hideAfterDelay:2.0];
    }
}

#pragma mark - TWTweetComposeViewController

- (BOOL) canSendTweet {
    return YES;
}

- (void) sendTweet:(NSString*)tweet withURL:(NSString*)url {
    DLog(@"Tweet:%@ URL:%@", tweet, url);
    if ([TWTweetComposeViewController class] != nil && [TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *twitterController = [[TWTweetComposeViewController alloc] init];
        if (tweet != nil) {
            [twitterController setInitialText:tweet];
        }
        if (url != nil) {
            [twitterController addURL:[NSURL URLWithString:url]];
        }
        [self.controller presentModalViewController:twitterController animated:YES];
        [twitterController release];
    }
    else {
        NSString *nibName = [A4GDevice isIPad] ? @"A4GTwitterViewController_iPad" : @"A4GTwitterViewController_iPhone";
        A4GTwitterViewController *twitterController = [[A4GTwitterViewController alloc] initWithNibName:nibName bundle:nil];
        twitterController.url = url;
        twitterController.name = tweet;
        twitterController.modalPresentationStyle = UIModalPresentationFormSheet;
        twitterController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentModalViewController:twitterController animated:YES];  
    }
}

- (void) sendTweet:(NSString*)tweet withImage:(UIImage*)image {
    DLog(@"Tweet:%@ Image", tweet);
    if ([TWTweetComposeViewController class] != nil && [TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *twitterController = [[TWTweetComposeViewController alloc] init];
        if (tweet != nil) {
            [twitterController setInitialText:tweet];
        }
        if (image != nil) {
            [twitterController addImage:image];
        }
        [self.controller presentModalViewController:twitterController animated:YES];
        [twitterController release];
    }
    else {
        NSString *nibName = [A4GDevice isIPad] ? @"A4GTwitterViewController_iPad" : @"A4GTwitterViewController_iPhone";
        A4GTwitterViewController *twitterController = [[A4GTwitterViewController alloc] initWithNibName:nibName bundle:nil];
        twitterController.name = tweet;
        twitterController.image = image;
        twitterController.modalPresentationStyle = UIModalPresentationFormSheet;
        twitterController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentModalViewController:twitterController animated:YES];  
    }
}

#pragma mark - MFMailComposeViewController

- (BOOL) canSendEmail {
    return [MFMailComposeViewController canSendMail];
}

- (void) sendEmail:(NSString*)message withSubject:(NSString *)subject addAttachment:(NSData*)attachment fileName:(NSString*)fileName toRecipient:(NSString*)recipient {
    NSArray *recipients = recipient != nil ? [NSArray arrayWithObject:recipient] : nil;
    [self sendEmail:message withSubject:subject addAttachment:attachment fileName:fileName toRecipients:recipients];   
}

- (void) sendEmail:(NSString*)message withSubject:(NSString *)subject addAttachment:(NSData*)attachment fileName:(NSString*)fileName toRecipients:(NSArray*)recipients {
    DLog(@"Message:%@ Subject:%@", message, subject);
    if ([self canSendEmail]) {
        MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
        mailController.navigationBar.tintColor = [A4GSettings navBarColor];
        mailController.mailComposeDelegate = self;
        if (subject != nil) {
            [mailController setSubject:subject];
        }
        if (message != nil) {
            [mailController setMessageBody:message isHTML:YES]; 
        }
        if (recipients != nil) {
            [mailController setToRecipients:recipients];
        }
        if (attachment != nil) {
            NSString *mimeType = @"application/octet-stream";
            [mailController addAttachmentData:attachment mimeType:mimeType fileName:fileName];
        }
        mailController.modalPresentationStyle = UIModalPresentationFormSheet;
        mailController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentModalViewController:mailController animated:YES]; 
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultSent) {
        DLog(@"MFMailComposeResultSent");
        [self.controller dismissModalViewControllerAnimated:YES];
        [self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
        [self.loadingView hideAfterDelay:2.0];
    }
    else if (result == MFMailComposeResultFailed) {
        DLog(@"MFMailComposeResultFailed");
        [self.controller dismissModalViewControllerAnimated:YES];
        [UIAlertView showWithTitle:NSLocalizedString(@"Email Error", nil) 
                           message:[error localizedDescription] 
                          delegate:self 
                               tag:AlertViewError 
                 cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                 otherButtonTitles:nil];
    }
    else if (result == MFMailComposeResultCancelled) {
        DLog(@"MFMailComposeResultCancelled");
        [self.controller dismissModalViewControllerAnimated:YES];
    } 
    else {
        [self.controller dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - UIPrintInteractionController

- (BOOL) canPrintText {
    return [UIPrintInteractionController isPrintingAvailable];
}

- (void) printData:(NSData*)data withTitle:(NSString*)title {
    if ([self canPrintText]) {
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        if (printController && [UIPrintInteractionController canPrintData:data]) {
            printController.delegate = self;
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.jobName = title;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printController.printInfo = printInfo;
            printController.showsPageRange = YES;
            printController.printingItem = data;
            void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = 
            ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
                if (completed && !error) {
                    [self.loadingView showWithMessage:NSLocalizedString(@"Printed", nil)];
                    [self.loadingView hideAfterDelay:2.0];
                }
                else if (!completed && error) {
                    DLog(@"Error:%@ Domain:%@ Code:%u", error, error.domain, error.code);
                    [UIAlertView showWithTitle:NSLocalizedString(@"Print Error", nil) 
                                       message:[error localizedDescription]
                                      delegate:self 
                                           tag:AlertViewError 
                             cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                             otherButtonTitles:nil];
                }
            };
            if ([A4GDevice isIPad]) {
                [printController presentFromRect:self.touch inView:self.controller.view animated:YES completionHandler:completionHandler];
            }
            else {
                [printController presentAnimated:YES completionHandler:completionHandler];    
            }
        }
    }    
}

- (void) printText:(NSString*)text withTitle:(NSString*)title {
    DLog(@"Text:%@ Title:%@", text, title);
    if (text != nil) {
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        [self printData:data withTitle:title];   
    }
}

#pragma mark - UIDocumentInteractionController

- (BOOL) canOpenIn:(NSString *)url {
    if (url != nil) {
        return [self canOpenInWithUrl:[NSURL URLWithString:url]];
    }
    return NO;
}

- (BOOL) canOpenInWithUrl:(NSURL *)url {
    BOOL canOpen = NO;
    if (url != nil) {
        UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        if (docController) {
            docController.delegate = self;
            canOpen = [docController presentOpenInMenuFromRect:CGRectZero inView:self.controller.view animated:NO];                   
            [docController dismissMenuAnimated:NO];
        }   
    }
    return canOpen;
}

- (void) showOpenInWithUrl:(NSString*)url {
    if (url != nil) {
        UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL URLWithString:url]];
        docController.delegate = self;
        [docController presentOpenInMenuFromRect:self.touch inView:self.controller.view animated:YES];
        [docController retain];
    }
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    DLog(@"");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    DLog(@"");
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    DLog(@"");
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    [controller autorelease];
}

#pragma mark - MFMessageComposeViewController

- (BOOL) canSendSMS {
    return [MFMessageComposeViewController canSendText];
}

- (void) sendSMS:(NSString *)message {
    DLog(@"Message:%@", message);
    if ([self canSendSMS]) {
        MFMessageComposeViewController *smsController = [[[MFMessageComposeViewController alloc] init] autorelease];
        smsController.navigationBar.tintColor = [A4GSettings navBarColor];
        smsController.messageComposeDelegate = self;
        if (message != nil) {
            smsController.body = message;    
        }
        smsController.modalPresentationStyle = UIModalPresentationFormSheet;
        smsController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentModalViewController:smsController animated:YES];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent) {
        DLog(@"MessageComposeResultSent");
        [self.controller dismissModalViewControllerAnimated:YES];
        [self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
        [self.loadingView hideAfterDelay:2.0];
    }
    else if (result == MessageComposeResultFailed) {
        DLog(@"MessageComposeResultFailed");
        [self.controller dismissModalViewControllerAnimated:YES];
        [UIAlertView showWithTitle:NSLocalizedString(@"SMS Error", nil) 
                           message:NSLocalizedString(@"There was a problem sending SMS message.", nil) 
                          delegate:self 
                               tag:AlertViewError 
                 cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                 otherButtonTitles:nil];
    }
    else if (result == MessageComposeResultCancelled) {
        DLog(@"MessageComposeResultCancelled");
        [self.controller dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.controller dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - FBDialogDelegate

- (void) shareFacebook:(NSString *)name caption:(NSString*)caption description:(NSString *)description link:(NSString*)link {
    if ([self.facebook isSessionValid]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (name != nil) {
            [params setObject:name forKey:@"name"];
        }
        if (caption != nil) {
            [params setObject:caption forKey:@"caption"];
        }
        if (description != nil) {
            [params setObject:description forKey:@"description"];
        }
        if (link != nil) {
            [params setObject:name forKey:@"link"];
        }
        [self.facebook dialog:@"feed" andParams:params andDelegate:self];
    }
    else {
        [A4GSettings setFacebookAuthorizing:YES];
        [self.facebook authorize:nil];
    }    
}

- (void)dialogDidComplete:(FBDialog *)dialog {
    DLog(@"");
    [self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
    [self.loadingView hideAfterDelay:2.0];
}

- (void)dialogCompleteWithUrl:(NSURL *)url {
    DLog(@"URL:%@", url);
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
    DLog(@"URL:%@", url);
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    DLog(@"");
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    DLog(@"Error: %@", [error description]);
    [UIAlertView showWithTitle:NSLocalizedString(@"Facebook Error", nil) 
                       message:[error localizedDescription] 
                      delegate:self 
                           tag:AlertViewError 
             cancelButtonTitle:NSLocalizedString(@"OK", nil) 
             otherButtonTitles:nil];
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewWebsite) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.message]];
        }
    }
}

@end