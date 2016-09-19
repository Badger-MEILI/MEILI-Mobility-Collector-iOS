//
//  ViewController.m
//  Mobility Collector
//
//  Created by Adrian Corneliu Prelipcean on 24/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseHelper.h"
#import <sys/sysctl.h>

@interface UIScrollView ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
//    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
     
    
    // Do any additional setup after loading the view, typically from a nib.
    self.loginAboutText.text = NSLocalizedString(@"contentText", @"the text associated with login");
    self.userNameLabel.text = NSLocalizedString(@"regularUsernameText", @"translation for user name");
    self.passwordLabel.text = NSLocalizedString(@"regularPasswordText", @"translation for password");
    //self.loginButton.titleLabel.text = NSLocalizedString(@"loginText", "translation for login button");
    [self.loginButton setTitle:NSLocalizedString(@"loginText", @"translation for login button")
                 forState:UIControlStateNormal];
    
    //[self.loginAboutText setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

    
    [self.registerButton setTitle:NSLocalizedString(@"registerNewUserText", @"translation for register button")
                      forState:UIControlStateNormal];
    
    [self.loginButton addTarget:self
                 action:@selector(loginButton)
       forControlEvents:UIControlEventTouchUpInside];
    
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
}

-(void)viewDidAppear:(BOOL)animated{
//    compute the automatic height of contents within the scrollView 
    
    

    //self.scrollView.delegate = self;
   // self.scrollView.scrollEnabled = YES;

    /*BOOL isLoggedIn = true;
    if (isLoggedIn)
    {
        [self performSegueWithIdentifier:@"loginSuccess" sender:self];
    }*/
    if ([[DatabaseHelper getInstance] getUserId]!=0)
        [self performSegueWithIdentifier:@"loginSuccess" sender:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButton:(id)sender {
    // NSInteger success=0;
    
    NSString* enteredUsername = self.loginTxtUser.text;
    NSString* enteredPassword = self.loginTxtPassword.text;
 
    if ([enteredPassword isEqual:@""] || [enteredUsername isEqual:@""]) {
        [self alertStatus:@"Error" :NSLocalizedString(@"credentialsMissmatchWarning", "credentials do not match warning") :0];
    }
    else
    {
        [self sendLoginURLRequest: enteredUsername password:enteredPassword];
    }
    
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqual:@"login_success"]) return YES;
    else return NO;
}

- (IBAction)registerButton:(id)sender {
    [self performSegueWithIdentifier:@"registerSegue" sender:self];
}

-(IBAction) goToAbout:(id)sender {
   [self performSegueWithIdentifier:@"aboutSegue" sender:sender];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
//linked with the delegate of the header
    [textField resignFirstResponder];
    return YES;
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

-(void) sendLoginURLRequest: (NSString*)username password:(NSString*)password{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"ENTER_YOUR_HOSTED_MEILI_HTTP_ENDPOINT/users/loginUser"]];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    __block NSArray *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               // NSLog(@"Async JSON: %@", json);
                               
                               NSDictionary* userId = json[0];
                               
                               // NSLog(@"%@", userId[@"id"]);
                               
                               if (userId[@"id"]!=NULL) {
                                   DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
                                   [dbHelper setUserId:userId[@"id"] phoneModel:[self getPhoneModel] phoneOS: [self getSystemVersion]];

                                   [self performSegueWithIdentifier:@"loginSuccess" sender:self];
                               }
                               else [self alertStatus:@"Error" :NSLocalizedString(@"credentialsMissmatchWarning", "not all fields are filled error") :0];
                               
                           }];
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


@end

