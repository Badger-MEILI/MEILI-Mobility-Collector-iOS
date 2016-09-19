//
//  registerViewController.h
//  Mobility Collector
//
//  Created by Adrian Corneliu Prelipcean on 24/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface registerViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *registerUsernameText;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordText;
@property (weak, nonatomic) IBOutlet UITextField *registerRePasswordText;

- (IBAction)registerAndLoginButton:(id)sender;

/*localized resources */
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordSecondLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerAndLoginButton;
//@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *aboutButton;
@property (strong, nonatomic) IBOutlet UIScrollView*scrollView;

@end
