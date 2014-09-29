//
//  ViewController.m
//  YOMESSAGE
//
//  Created by Dylan Eirinberg on 7/28/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screen = [UIScreen mainScreen].bounds;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
        
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(screen.size.width - 48, 26, 44, 44)];
    self.shareButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.shareButton setImage:[UIImage imageNamed:@"ShareButton.png"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"YOMESSAGE";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:21];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(screen.size.width/2, screen.size.height*0.2);
    [self.view addSubview:self.titleLabel];
    
    self.sendToField = [[UITextField alloc] initWithFrame:CGRectMake(0, screen.size.height*0.4, screen.size.width, 60)];
    self.sendToField.placeholder = NSLocalizedString(@"SEND TO", nil);
    [self formatKeyboard:self.sendToField];
    
    self.messageField = [[UITextField alloc] initWithFrame:CGRectMake(0, screen.size.height*0.6, screen.size.width, 60)];
    self.messageField.placeholder = NSLocalizedString(@"MESSAGE", nil);
    [self formatKeyboard:self.messageField];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, screen.size.height - 60, screen.size.width, 60)];
    self.sendButton.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:0.1];
    [self.sendButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.hidden = YES;
    
    self.blockedMessages = @[@"red alert", @"missle alert", @"bomb alert", @"terror alert", @"redalert", @"missle warning", @"bomb warning", @"terror warning"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)formatKeyboard:(UITextField *)textField {
    textField.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:0.1];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.borderStyle = UITextBorderStyleNone;
    textField.textColor = [UIColor whiteColor];
    textField.returnKeyType = UIReturnKeyNext;
    textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
    textField.delegate = self;
    [self.view addSubview:textField];
    
    [self formatTextFieldFont:textField];
}

- (void)formatTextFieldFont:(UITextField *)textField {
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    
    [self shiftFieldsUp];
}

- (void)shiftFieldsUp {
    CGRect screen = [UIScreen mainScreen].bounds;
    
    if(self.messageField.isEditing){
        CGFloat fieldOriginY = screen.size.height - self.keyboardHeight - self.messageField.frame.size.height;
        
        [UIView beginAnimations:@"moveFieldsUp" context:nil];
        [UIView setAnimationDuration:0.15];
        
        CGRect newShareFrame = [self.shareButton frame];
        newShareFrame.origin.y = -self.shareButton.frame.size.height;
        self.shareButton.frame = newShareFrame;
        
        CGRect newTitleFrame = [self.titleLabel frame];
        newTitleFrame.origin.y = -self.titleLabel.frame.size.height;
        self.titleLabel.frame = newTitleFrame;
        
        CGRect newSendFrame = [self.sendToField frame];
        newSendFrame.origin.y  = self.sendToField.frame.origin.y - (self.messageField.frame.origin.y - fieldOriginY);
        self.sendToField.frame = newSendFrame;
        
        CGRect newMessageFrame = [self.messageField frame];
        newMessageFrame = [self.messageField frame];
        newMessageFrame.origin.y  = fieldOriginY;
        self.messageField.frame = newMessageFrame;
        [UIView commitAnimations];
    }
}

- (IBAction)shareSelected:(id)sender {
    NSString *text = NSLocalizedString(@"SocialText", nil);
    NSURL *url = [NSURL URLWithString:@"http://itunes.com/apps/YoMessage"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url]
     applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypeMail,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self presentViewController:controller animated:YES completion:nil];
}


- (IBAction)sendSelected:(id)sender {
    if([self.sendToField text].length <= 0 && [self.messageField text].length <= 0) {
        [self showAlert:NSLocalizedString(@"NoUserMessage", nil) withMessage:@""];
    }
    else if([self.sendToField text].length <= 0) {
        [self showAlert:NSLocalizedString(@"NoUser", nil) withMessage:@""];
    }
    else if([self.messageField text].length <= 0) {
        [self showAlert:NSLocalizedString(@"NoMessage", nil) withMessage:@""];
    }
    else if([[self.sendToField text] rangeOfString:@" "].location != NSNotFound){
        [self showAlert:NSLocalizedString(@"Spaces", nil) withMessage:@""];
    }
    else {
        NSString *blockedMessage;
        for(NSString *message in self.blockedMessages) {
            if([[self.messageField.text lowercaseString] rangeOfString:message].location != NSNotFound){
                blockedMessage = message;
            }
        }
        if(blockedMessage) {
            [self showAlert:NSLocalizedString(@"Cannot send YoMessage!", nil) withMessage:[NSString stringWithFormat:NSLocalizedString(@"Restricted", nil), blockedMessage]];
        }
        else {
            [self sendYo];
        }
    }
}

- (void)sendYo {
    NSString *messageText = [NSString stringWithFormat:@"_%@", self.messageField.text];
    messageText = [messageText stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *yoURL = [NSString stringWithFormat:@"http://yofor.me/%@/%@", self.sendToField.text, messageText];
    
    self.activityIndicator.hidden = false;
    self.activityIndicator.center = CGPointMake(self.sendButton.center.x, self.sendButton.center.y);
    [self.activityIndicator startAnimating];
    [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:yoURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:4.0];
    req.HTTPMethod = @"POST";
    
    self.numYos++;
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *username = self.sendToField.text;
        self.sendToField.text = @"";
        self.sendToField.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
        self.messageField.text = @"";
        self.messageField.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
        self.activityIndicator.hidden = true;
        [self.activityIndicator stopAnimating];
        
        if(error) {
            self.numYos = 0;
            [self.sendButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
            NSLog(@"%@", error);
            
            if([error code] == NSURLErrorNotConnectedToInternet || [error code] == NSURLErrorNetworkConnectionLost) {
                [self showAlert:NSLocalizedString(@"Cannot send YoMessage!", nil) withMessage:NSLocalizedString(@"No internet", nil)];
            }
            else {
                [self showAlert:NSLocalizedString(@"YoMessage is down", nil) withMessage:NSLocalizedString(@"Try again later", nil)];
            }
        }
        else {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"%@", responseDictionary);
            
            if(responseDictionary && [responseDictionary objectForKey:@"status"] && [[responseDictionary objectForKey:@"status"]  isEqual: @"OK"]) {
                self.numYos--;
                
                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSendText) userInfo:nil repeats:false];
                [self.sendButton setTitle:NSLocalizedString(@"SENT YO!", nil) forState:UIControlStateNormal];
            }
            else {
                self.numYos = 0;
                
                if([responseDictionary objectForKey:@"message"] &&[[responseDictionary objectForKey:@"message"]  isEqual: @"BLOCKED"]) {
                    [self.sendButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
                    [self showAlert:NSLocalizedString(@"Cannot send YoMessage!", nil) withMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is blocked", nil), username]];
                }
                else if([responseDictionary objectForKey:@"message"] &&[[responseDictionary objectForKey:@"message"]  isEqual: @"NO SUCH USER"]) {
                    [self.sendButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
                    [self showAlert:NSLocalizedString(@"Cannot send YoMessage!", nil) withMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ isn't a user", nil), username]];
                }
                else {
                    [self.sendButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
                    [self showAlert:NSLocalizedString(@"YoMessage is down", nil) withMessage:NSLocalizedString(@"Try again later", nil)];
                }
            }
        }
    }];
}

- (void)updateSendText {
    if(self.numYos == 0) {
        [self.sendButton setTitle:NSLocalizedString(@"SEND", nil) forState:UIControlStateNormal];
    }
    else {
        self.activityIndicator.hidden = false;
        self.activityIndicator.center = CGPointMake(self.sendButton.center.x, self.sendButton.center.y);
        [self.activityIndicator startAnimating];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if(range.length == 0) {
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
        set = [set invertedSet];
        if([string rangeOfCharacterFromSet:set].location != NSNotFound){
            return false;
        }
        if(textField == self.sendToField && [self.sendToField.text length] == 42) {
            return false;
        }
        else if(textField == self.messageField && [self.messageField.text length] == 41) {
            return false;
        }
        else {
            textField.text = [newText uppercaseString];
            return false;
        }
    }

    
    return true;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.sendToField) {
        if(self.messageField.text.length > 0) {
            textField.returnKeyType = UIReturnKeyDone;
        }
        else {
            textField.returnKeyType = UIReturnKeyNext;
        }
        self.sendToField.placeholder = nil;
    }
    else if (textField == self.messageField) {
        if(self.sendToField.text.length > 0) {
            textField.returnKeyType = UIReturnKeyDone;
        }
        else {
            textField.returnKeyType = UIReturnKeyNext;
        }
        self.messageField.placeholder = nil;
    }
    
    textField.font = [UIFont fontWithName:@"Montserrat-Regular" size:24];
    return true;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    CGRect screen = [UIScreen mainScreen].bounds;
    
    self.sendToField.placeholder = NSLocalizedString(@"SEND TO", nil);
    [self formatTextFieldFont:self.sendToField];
    
    if(self.sendToField.text.length == 0) {
        self.sendToField.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
    }
    
    self.messageField.placeholder = NSLocalizedString(@"MESSAGE", nil);
    [self formatTextFieldFont:self.messageField];
    
    if(self.messageField.text.length == 0) {
        self.messageField.font = [UIFont fontWithName:@"Montserrat-Regular" size:18];
    }
    
    if(textField == self.messageField) {
        [UIView beginAnimations:@"moveFieldsDown" context:nil];
        [UIView setAnimationDuration:0.15];
        
        self.shareButton.frame = CGRectMake(screen.size.width - 48, 26, 44, 44);
        self.titleLabel.center = CGPointMake(screen.size.width/2, screen.size.height*0.2);
        self.sendToField.frame = CGRectMake(0, screen.size.height*0.4, screen.size.width, 60);
        self.messageField.frame = CGRectMake(0, screen.size.height*0.6, screen.size.width, 60);
        
        [UIView commitAnimations];
    }
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.returnKeyType == UIReturnKeyNext && textField.text.length > 0) {
        if(textField == self.sendToField){
            [self.messageField becomeFirstResponder];
            [self textFieldShouldBeginEditing:self.messageField];
            [self shiftFieldsUp];
        }
        else {
            [self.sendToField becomeFirstResponder];
            [self textFieldShouldBeginEditing:self.sendToField];
        }
    }
    
    [textField resignFirstResponder];
    
    return true;
}

- (void)showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
