//
//  ViewController.h
//  YOMESSAGE
//
//  Created by Dylan Eirinberg on 7/28/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>


@property (nonatomic, retain) UIButton *shareButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UITextField *sendToField;
@property (nonatomic, retain) UITextField *messageField;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSArray *blockedMessages;
@property (nonatomic) int keyboardHeight;
@property (nonatomic) int numYos;


-(IBAction)shareSelected:(id)sender;
-(IBAction)sendSelected:(id)sender;

@end
