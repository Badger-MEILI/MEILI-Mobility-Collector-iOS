//
//  aboutViewController.h
//  
//
//  Created by Adrian Corneliu Prelipcean on 27/07/15.
//
//

#import <UIKit/UIKit.h>

@interface aboutViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

/*localize*/
@property (weak, nonatomic) IBOutlet UILabel *versionText;
@property (weak, nonatomic) IBOutlet UITextView *creditsText;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)closeMe:(id)sender;

@end
