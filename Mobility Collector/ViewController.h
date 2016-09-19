//
//  ViewController.h
//  Mobility Collector
//
//  Created by Adrian Corneliu Prelipcean on 24/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *loginTxtUser;
@property (weak, nonatomic) IBOutlet UITextField *loginTxtPassword;

- (IBAction)loginButton:(id)sender;
- (IBAction)registerButton:(id)sender;

/* Localization properties */

@property (weak, nonatomic) IBOutlet UITextView *loginAboutText;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) IBOutlet UIView *scrollView;

@end
