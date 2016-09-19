//
//  registerViewController.m
//  Mobility Collector
//
//  Created by Adrian Corneliu Prelipcean on 24/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "registerViewController.h"
#import <sys/sysctl.h>
#import "DatabaseHelper.h"
@interface registerViewController (){
    BOOL _unwindExecuted;}

@end

@implementation registerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.userNameLabel.text = NSLocalizedString(@"regularUsernameText", @"user name");
    self.passwordLabel.text = NSLocalizedString(@"regularPasswordText", @"password text");
    self.passwordSecondLabel.text = NSLocalizedString(@"confirmPassword", @"re-type password text");
   // self.contentText.text = NSLocalizedString(@"contentText", @"content text");
    [self.registerAndLoginButton setTitle:NSLocalizedString(@"registerAndLoginButton", @"translation for register button")
                         forState:UIControlStateNormal];
    self.aboutButton.title = NSLocalizedString(@"menuAboutText", @"translation for about button");

    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:nil action:nil];
    /* UIBarButtonItem *customItem1 = [[UIBarButtonItem alloc]
     initWithTitle:@"Tool1" style:UIBarButtonItemStyleBordered
     target:self action:@selector(toolBarItem1:)];*/
    UIBarButtonItem *customItem2 = [[UIBarButtonItem alloc]
                                    initWithTitle:@"About" style:UIBarButtonItemStyleDone
                                    target:self action:@selector(goToAbout:)];
    NSArray *toolbarItems = [NSArray arrayWithObjects: spaceItem, customItem2, nil];
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    [toolbar setBarStyle:UIBarStyleDefault];
    [self.view addSubview:toolbar];
    [toolbar setItems:toolbarItems];
    
    //CGSize stringsize = [NSLocalizedString(@"registerAndLoginButton", @"translation for register button") sizeWithFont:[UIFont systemFontOfSize:21]];
    //or whatever font you're using
    //[self.registerAndLoginButton setFrame:CGRectMake(10,0,stringsize.width, stringsize.height)];
}

-(NSString*) getSystemVersion{
    return [UIDevice currentDevice].systemVersion;
}

-(NSString*) getPhoneModel{
    /*Adapted based on http://stackoverflow.com/questions/1108859/detect-the-specific-iphone-ipod-touch-model*/
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    
    if ([sDeviceModel isEqual:@"i386"])      return @"Simulator";  //iPhone Simulator
    if ([sDeviceModel isEqual:@"iPhone1,1"]) return @"iPhone1G";   //iPhone 1G
    if ([sDeviceModel isEqual:@"iPhone1,2"]) return @"iPhone3G";   //iPhone 3G
    if ([sDeviceModel isEqual:@"iPhone2,1"]) return @"iPhone3GS";  //iPhone 3GS
    if ([sDeviceModel isEqual:@"iPhone3,1"]) return @"iPhone4 AT&T";  //iPhone 4 - AT&T
    if ([sDeviceModel isEqual:@"iPhone3,2"]) return @"iPhone4 Other";  //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone3,3"]) return @"iPhone4";    //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone4,1"]) return @"iPhone4S";   //iPhone 4S
    if ([sDeviceModel isEqual:@"iPhone5,1"]) return @"iPhone5";    //iPhone 5 (GSM)
    if ([sDeviceModel isEqual:@"iPod1,1"])   return @"iPod1stGen"; //iPod Touch 1G
    if ([sDeviceModel isEqual:@"iPod2,1"])   return @"iPod2ndGen"; //iPod Touch 2G
    if ([sDeviceModel isEqual:@"iPod3,1"])   return @"iPod3rdGen"; //iPod Touch 3G
    if ([sDeviceModel isEqual:@"iPod4,1"])   return @"iPod4thGen"; //iPod Touch 4G
    if ([sDeviceModel isEqual:@"iPad1,1"])   return @"iPadWiFi";   //iPad Wifi
    if ([sDeviceModel isEqual:@"iPad1,2"])   return @"iPad3G";     //iPad 3G
    if ([sDeviceModel isEqual:@"iPad2,1"])   return @"iPad2";      //iPad 2 (WiFi)
    if ([sDeviceModel isEqual:@"iPad2,2"])   return @"iPad2";      //iPad 2 (GSM)
    if ([sDeviceModel isEqual:@"iPad2,3"])   return @"iPad2";      //iPad 2 (CDMA)
    
    NSString *aux = [[sDeviceModel componentsSeparatedByString:@","] objectAtIndex:0];
    
    //If a newer version exist
    if ([aux rangeOfString:@"iPhone"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] intValue];
        if (version == 3) return @"iPhone4";
            if (version >= 4) return @"iPhone4s";
        
    }
    if ([aux rangeOfString:@"iPod"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPod" withString:@""] intValue];
        if (version >=4) return @"iPod4thGen";
    }
    if ([aux rangeOfString:@"iPad"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPad" withString:@""] intValue];
        if (version ==1) return @"iPad3G";
        if (version >=2) return @"iPad2";
    }
    //If none was found, send the original string
    return sDeviceModel;
}

-(void)viewDidAppear:(BOOL)animated{
    //compute the automatic height of contents within the scrollView
     
    if ([[DatabaseHelper getInstance] getUserId]!=0)
        [self performSegueWithIdentifier:@"loginSuccess" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) sendRegisterURLRequest: (NSString*)username password:(NSString*)password{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"ENTER_YOUR_HOSTED_MEILI_HTTP_ENDPOINT/users/registerUser"]];
    
    [request setHTTPMethod:@"POST"];
    NSString* phoneModel = [self getPhoneModel];
    NSString* phoneOS = [self getSystemVersion];
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@&phone_model=%@&phone_os=%@", username, password, phoneModel, phoneOS];
 
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    
    __block NSArray *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               NSLog(@"Async JSON: %@", json);
                               
                               NSDictionary* userId = json[0]; // or avatars[0]

                                NSLog(@"%@", userId[@"id"]);
                               
                               if (userId[@"id"]!=NULL) {
                                   DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
                                   [dbHelper setUserId:userId[@"id"] phoneModel:[self getPhoneModel] phoneOS: [self getSystemVersion]];
                            [self performSegueWithIdentifier:@"serviceSegue" sender:self];
                               }
                               else [self alertStatus:@"Error" :NSLocalizedString(@"credentialsMissmatchWarning", "not all fields are filled error") :0];

                           }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)registerAndLoginButton:(id)sender {
    NSString* username =self.registerUsernameText.text;
    NSString* password = self.registerPasswordText.text;
    NSString* rePassword = self.registerRePasswordText.text;

    
    if ([username isEqual:@""]||[password isEqual:@""]||[rePassword isEqual:@""])
    {
        [self alertStatus:@"Error" :NSLocalizedString(@"credentialsMissmatchWarning", "not all fields are filled error") :0];
    }
    else
    {
    if ([self NSStringIsValidEmail:username]){
        if ([password isEqual: rePassword]){
            NSLog(@"Success");
            [self sendRegisterURLRequest:username password:password];
        }
        else{
            [self alertStatus:@"Error" :NSLocalizedString(@"passwordError", "passwords do not match warning") :0];
        }
    }
    else{
        [self alertStatus:@"Error" :NSLocalizedString(@"emailWarning", "invalid password warning") :0];
    }
    }
}



-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqual:@"register_success"]) return YES;
    else return NO;
}

-(IBAction) goToAbout:(id)sender {
    //[self presentModalViewController:aboutViewController animated:YES];
    [self performSegueWithIdentifier:@"aboutSegueFromRegister" sender:sender];
}


@end
