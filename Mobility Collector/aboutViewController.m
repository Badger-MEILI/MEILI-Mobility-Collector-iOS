//
//  aboutViewController.m
//  
//
//  Created by Adrian Corneliu Prelipcean on 27/07/15.
//
//

#import "aboutViewController.h"

@interface aboutViewController ()

@end

@implementation aboutViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    self.contentText.text = NSLocalizedString(@"contentText", "contentText");
    self.creditsText.text = NSLocalizedString(@"subTitleText", "subTitleText");
    self.versionText.text = NSLocalizedString(@"versionText", "versionText");
    
    [self.closeButton setTitle:NSLocalizedString(@"closeButtonText", @"closeButtonText")
                                 forState:UIControlStateNormal];
    
  
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    //    compute the automatic height of contents within the scrollView
    
    [self readjustButtonWithText:self.closeButton text:NSLocalizedString(@"closeButtonText", @"closeButtonText") fontSize:21];
   /* 
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in self.scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    
    [self.scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
    
   // self.scrollView.delegate = self;
    
   

    
    self.scrollView.scrollEnabled = YES;*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) readjustButtonWithText: (UIButton*) button text:(NSString*)text fontSize:(int)fontSize{
    CGPoint position =  button.frame.origin;
    [button removeFromSuperview];
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    CGSize stringsize = [text sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    //or whatever font you're using
    [button setFrame:CGRectMake(position.x
                                          ,position.y,stringsize.width, stringsize.height)];
    [self.scrollView addSubview:button];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"id %@ called me", sender);
}*/


- (IBAction)closeMe:(id)sender {
 
    [self.presentedViewController dismissModalViewControllerAnimated:YES];
    
//    [self dismissViewControllerAnimated:YES completion:nil];

//    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}
@end
