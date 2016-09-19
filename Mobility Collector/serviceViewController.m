//
//  serviceViewController.m
//  Mobility Collector
//
//  Created by Adrian Corneliu Prelipcean on 28/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "serviceViewController.h"
#import "EmbeddedLocationListener.h"

@interface serviceViewController ()
@property BOOL serviceStarted;
@end

@implementation serviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceStarted = false;
    self.serviceHandlingButton.titleLabel.text = @"Start";
    // Do any additional setup after loading the view.
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingLocation:) name:@"test" object:nil];
}

/*

- (void) incomingLocation:(NSNotification *)notification{
    EmbeddedLocation *currentLocation = [notification object];
    self.userId.text = [[NSNumber numberWithLong:currentLocation.userId] stringValue];

    self.latitudeLabel.text = [[NSNumber numberWithFloat:currentLocation.location.coordinate.latitude] stringValue];
    self.longitudeLabel.text = [[NSNumber numberWithFloat:currentLocation.location.coordinate.longitude] stringValue];
    self.accuracyLabel.text = [[NSNumber numberWithFloat:currentLocation.location.horizontalAccuracy] stringValue];
    self.xMeanLabel.text = [[NSNumber numberWithFloat:currentLocation.getAccelerometerValues.getXMean] stringValue];
    self.totalMeanLabel.text = [[NSNumber numberWithFloat:currentLocation.getAccelerometerValues.getTotalMean] stringValue];
}
 */

-(void)viewDidAppear:(BOOL)animated{
    //    compute the automatic height of contents within the scrollView
    
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in self.scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    
    [self.scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];

    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
    
    self.serviceStarted = [[DatabaseHelper getInstance] getIsServiceRunning];
    
    if (self.serviceStarted) [self.serviceHandlingButton setTitle:@"Stop"
                                                         forState:UIControlStateNormal];
    else
        [self.serviceHandlingButton setTitle:@"Start"
                                    forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonPushed:(id)sender {
    self.listener = [EmbeddedLocationListener getInstance];
 
    
    if (self.serviceStarted == true) {
        [[DatabaseHelper getInstance] updateIsServiceRunning:false];
        [self.listener stopListeningService];
        self.serviceStarted = false;
        [self.serviceHandlingButton setTitle:@"Start"
                                     forState:UIControlStateNormal];
     }
    else{
        [[DatabaseHelper getInstance] updateIsServiceRunning:true];
        [self.listener startListeningService];
        self.serviceStarted=true;
        [self.serviceHandlingButton setTitle:@"Stop"
                                    forState:UIControlStateNormal];
        [self sendLogs];
        [self sendUploadURLRequest];
    }
    
    
    // COMMUNICATE WITH THE ADMIN DATABASE
}


-(void) sendLogs{
    
    DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
    
    NSString *dataToUpload = [dbHelper getAllMessages];
    [[DatabaseHelper getInstance] deleteUploadedLogs];
    
    // everything was commented out because the background listening was fixed for the tested version
    // THIS MIGHT NEED TO BE REOPENNED FOR TESTING THE NEW VERSIONS DUE TO CODE AND FLAGS MODIFICATIONS
    //   NSLog(@"%@",dataToUpload);
    /*
    if ([dataToUpload length]!=0)
    {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@ENTER_YOUR_HOSTED_MEILI_HTTP_ENDPOINT/users/insertLog"]];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *postString = [NSString stringWithFormat:@"userId=%u&dataToUpload=%@",[dbHelper getUserId], dataToUpload];
        
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   id str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"%@",str);
                                   
                                   if ([str isEqual:@"success"]){
     [[DatabaseHelper getInstance] deleteUploadedLogs];
                                   }
                               }];
    }
     */
}

-(void) sendUploadURLRequest{
    
    DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
    
    NSString *dataToUpload = [dbHelper getLocationsForUpload];
 
 //   NSLog(@"%@",dataToUpload);
    
    if ([dataToUpload length]!=0)
    {
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"ENTER_YOUR_HOSTED_MEILI_HTTP_ENDPOINT/users/insertLocationsIOS"]];
       
    [request setHTTPMethod:@"POST"];
        
    NSString *postString = [NSString stringWithFormat:@"dataToUpload=%@", dataToUpload];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               id str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"%@",str);
                              
                               if ([str isEqual:@"success"]){
                                   [[DatabaseHelper getInstance] updateUploadedLocations];
                               }
                           }];
    }
}


@end
