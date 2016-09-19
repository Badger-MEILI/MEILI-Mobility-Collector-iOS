//
//  EmbeddedLocationListener.m
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 22/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#include "EmbeddedLocationListener.h"
//#import <AudioToolbox/AudioToolbox.h>

@implementation EmbeddedLocationListener

-(instancetype)init{
    [self reInitialize];
    return self;
}

/*
- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory
                         stringByAppendingPathComponent:@"console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}*/

-(void) reInitialize{
    self.timeOfLastUpload = [NSDate date];
   // [self redirectConsoleLogToDocumentFolder];
    self.ALPHA=0.8f;
    self.skipOneLocation = false;
    self.accelerometerValues = [[NSMutableArray alloc]init];
    self.savingsAccelerometerValues = [[NSMutableArray alloc]init];
    self.distFreq=50;
    self.dbHelper = [DatabaseHelper getInstance];
    
    [[self dbHelper]insertMessageIntoDatabase:@"Re-initialize called"];
    
    self.locationManager = [[CLLocationManager alloc] init];
    // self.locationManager.delegate=self;
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    self.locationManager.distanceFilter=50;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    self.latentLocationManager = [[CLLocationManager alloc] init];
    // self.locationManager.delegate=self;
    self.latentLocationManager.desiredAccuracy=kCLLocationAccuracyBest;
    self.latentLocationManager.distanceFilter=50;
    self.latentLocationManager.activityType = CLActivityTypeFitness;
    self.latentLocationManager.pausesLocationUpdatesAutomatically = NO;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .01;
    
    
    self.savingMotionManager = [[CMMotionManager alloc] init];
    self.savingMotionManager.accelerometerUpdateInterval = .2;
    self.savingsAccelerometerValues = [[NSMutableArray alloc]init];
    
    self.userId = [[DatabaseHelper getInstance] getUserId];

    
}

+(EmbeddedLocationListener *)getInstance{
    
    static EmbeddedLocationListener* instance;
    @synchronized(self) {
        if(instance==nil)
            instance = [[EmbeddedLocationListener alloc] init];
    }
    
    return instance;
    
}

-(NSMutableArray *)getAccelerometerValues{
    return self.accelerometerValues;
}

-(void)resetAccelerometerValues{
    self.accelerometerValues = NULL;
    self.accelerometerValues = [[NSMutableArray alloc] init];

    self.gravity = [[NSMutableArray alloc]init];
    
    self.gravity[0] = [NSNumber numberWithFloat:0.0f];
    self.gravity[1] = [NSNumber numberWithFloat:0.0f];
    self.gravity[2] = [NSNumber numberWithFloat:0.0f];
    
}

-(NSMutableArray *)emptyAccelerometerValuesGetNewList{
    self.accelerometerValues = NULL;
    self.accelerometerValues = [[NSMutableArray alloc]init];
    self.gravity = [[NSMutableArray alloc]init];
    
    self.gravity[0] = [NSNumber numberWithFloat:0.0f];
    self.gravity[1] = [NSNumber numberWithFloat:0.0f];
    self.gravity[2] = [NSNumber numberWithFloat:0.0f];
    
    return self.accelerometerValues;
}

-(BOOL)isAccurate:(CLLocation *)location{
 //   return location.horizontalAccuracy>35;
    return true;
}

-(NSMutableArray *)lowPassFilter:(float)x y:(float)y z:(float)z{
    NSMutableArray *filteredValues = [[NSMutableArray alloc]init];
    
    float newXValue = self.ALPHA * [[self.gravity objectAtIndex:0] floatValue] + (1 - self.ALPHA) * x;
    //float oldXValue = [[self.gravity objectAtIndex:0] floatValue];
    
    float newYValue = self.ALPHA * [[self.gravity objectAtIndex:1] floatValue] + (1 - self.ALPHA) * y;
    //float oldYValue = [[self.gravity objectAtIndex:1] floatValue];
    
    float newZValue = self.ALPHA * [[self.gravity objectAtIndex:2] floatValue] + (1 - self.ALPHA) * z;
    //float oldZValue = [[self.gravity objectAtIndex:2] floatValue];
    
    //self.gravity = [[NSMutableArray alloc]init];
 
    
    
    self.gravity[0] = [NSNumber numberWithFloat:newXValue];
    self.gravity[1] = [NSNumber numberWithFloat:newYValue];
    self.gravity[2] = [NSNumber numberWithFloat:newZValue];
    
    [filteredValues addObject:[NSNumber numberWithFloat:(x-newXValue)]];
    [filteredValues addObject:[NSNumber numberWithFloat:(y-newYValue)]];
    [filteredValues addObject:[NSNumber numberWithFloat:(z-newZValue)]];

    return filteredValues;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    
}

-(void)startListeningService{
  [[self dbHelper]insertMessageIntoDatabase:@"Started Listening service linked to button"];
    [self startRegularListeners];
    [self startBatterySavingsListeners];
}


-(void) startRegularListeners{
    [[self dbHelper]insertMessageIntoDatabase:@"Started regular listener"];
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        [[self dbHelper]insertMessageIntoDatabase:@"Started successfully regular listener"];
        NSLog(@"Started listening meta service");
        self.locationManager.delegate=self;
        
        [self.locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
        [self.locationManager setDistanceFilter:50];
  
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
            [self.latentLocationManager requestAlwaysAuthorization];
        }
        
        if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        [self.latentLocationManager setAllowsBackgroundLocationUpdates:YES];
        }
        
        [self.latentLocationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
      
        [self startAccelerometer];
    }
}

-(void) stopRegularListeners{
    NSLog(@"Stopped listening meta service");
    
    //only do stuff if the locationAccuracy has indeed changed
    [[self dbHelper]insertMessageIntoDatabase:@"Set regular listener accuracy and distance filter to GSM specs"];
    
    CLLocationAccuracy locationAccuracy = self.locationManager.desiredAccuracy;
    
    if (locationAccuracy != kCLLocationAccuracyThreeKilometers)
    {
    [self.locationManager setDesiredAccuracy: kCLLocationAccuracyThreeKilometers];
    [self.locationManager setDistanceFilter:9000];
    }
    
    [self.motionManager stopAccelerometerUpdates];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.delay10Seconds){
        [self.delay10Seconds invalidate];
        self.delay10Seconds = nil;
    }
    
}

-(void)stopListeningService{
    [[self dbHelper]insertMessageIntoDatabase:@"Stopped for good regular listener"];
    [self stopRegularListeners];
    [self stopBatterySavingsListeners];
    [self closeDatabase];
    [self.latentLocationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
}

-(void)openDatabase{
   // does nothing as of now
}

-(void) closeDatabase{
    [self.dbHelper closeDatabase];
}

-(void)stopAccelerometer{
    [[self dbHelper]insertMessageIntoDatabase:@"Stopped getting regular accelerometer values"];
    [self.motionManager stopAccelerometerUpdates];
}

-(void) startAccelerometer{
    [[self dbHelper]insertMessageIntoDatabase:@"Getting regular accelerometer values"];
    if ([self.motionManager isAccelerometerAvailable])
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CMAcceleration acceleration = accelerometerData.acceleration;
                NSMutableArray* arrayOfAccelerometer = [[NSMutableArray alloc]init];
               
                arrayOfAccelerometer = [self lowPassFilter:acceleration.x*9.8 y:acceleration.y*9.8 z:acceleration.z*9.8];
                
                [self.accelerometerValues addObject:arrayOfAccelerometer];
                
            });
        }];
    } else
        NSLog(@"not active");
}


#pragma mark -

#pragma mark CLLocationManagerDelegate


-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            // do some error handling
        }
            break;
        default:{
            [self.locationManager startUpdatingLocation];
        }
            break;
    }
}


-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
    NSLog(@"failed to get location");
    [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Location error %@",error]];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currentLocation = [locations objectAtIndex:0];
    [[self dbHelper]insertMessageIntoDatabase:@"Got location from regular location manager"];
    NSLog(@"got location");
    
    if (currentLocation!=nil){
        NSLog(@"got valid location");
        
        // no need for the current instance of the battery saving
        [self refreshBatterySavingsListeners];
        
        
        if (!self.skipOneLocation){
            if (self.previousLocation!=nil)
                if (self.previousLocation.coordinate.latitude!=currentLocation.coordinate.latitude){
            [self stopAccelerometer];
            if(self.accelerometerValues.count>0){
                if ([self isAccurate:currentLocation]){
                    AccelerometerValues* currentAccelerometerValues = [[AccelerometerValues alloc] initWithModel:self.accelerometerValues];
                    
                    EmbeddedLocation* currentEmbeddedLocation = [[EmbeddedLocation alloc] initWithModel: currentAccelerometerValues
                                                                                               location: currentLocation userId:self.userId];
                
                    [self.dbHelper insertLocationIntoDatabase:currentEmbeddedLocation];
                
                   // [[NSNotificationCenter defaultCenter] postNotificationName:@"test" object: currentEmbeddedLocation];
                    
                }
                [self resetAccelerometerValues];
            }
            [self startAccelerometer];
        }
    }
    }
    
    if (self.timer) {
        return;
    }
    
    // AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);

    
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
    
    //Restart the locationMaanger after 1 minute
    
    int timeToNext = 30;
    
    
    if (self.previousLocation != nil) timeToNext = [self getTimeToNext: self.previousLocation currentLocation:currentLocation];
    
    NSLog(@"TIME TO NEXT WITHIN %d", timeToNext);
    
    
    [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Set the time to next update to %d", timeToNext]];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeToNext target:self
                                                selector:@selector(restartLocationUpdates)
                                                userInfo:nil
                                                 repeats:NO];
    self.previousLocation = currentLocation;
    
    
    // NOT NEEDED - BATTERY SAVINGS TAKES CARE OF THIS
    
    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    
    /*if (self.delay10Seconds) {
        [self.delay10Seconds invalidate];
        self.delay10Seconds = nil;
    }
    
    self.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                                    selector:@selector(stopLocationDelayBy10Seconds)
                                                                    userInfo:nil
                                                                     repeats:NO];
    */
    
}

-(int) getTimeToNext: (CLLocation*) prevLocation currentLocation:(CLLocation*)currentLocation{
    
    
 //   self.skipOneLocation = true;
    
    if ([prevLocation.timestamp isEqualToDate: currentLocation.timestamp]) return 30; // Can't do anything in this case
    
    int timeInSeconds = [currentLocation.timestamp timeIntervalSinceDate: prevLocation.timestamp];
    float distanceInMeters = [prevLocation distanceFromLocation:currentLocation];
    
    float speedMS = distanceInMeters / timeInSeconds;
    
    int timeToNextLocation = 50 / speedMS;
    
    NSLog(@"TIME TO NEXT LOCATION %d",timeToNextLocation);
    
    if (timeToNextLocation<=1) return 1;
    
    if (timeToNextLocation>30) return 30;
    
    return timeToNextLocation;
}

- (void) restartLocationUpdates
{
    NSLog(@"restartLocationUpdates");
  
    
    [[self dbHelper]insertMessageIntoDatabase:@"Restarting location update timer"];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    

   // [self startListeningService];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication]
                                         beginBackgroundTaskWithExpirationHandler:NULL];
    
    
    [[self dbHelper]insertMessageIntoDatabase:@"Application entered background"];
    
    // s[self.latentLocationManager  stopMonitoringSignificantLocationChanges];
    
    if ([self.latentLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.latentLocationManager requestAlwaysAuthorization];
    }
    
    [self.latentLocationManager startMonitoringSignificantLocationChanges];
    
 //   [self startRegularListeners];
    [self startListeningService];
    
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];
  
    [[UIApplication sharedApplication] endBackgroundTask:taskId];

    // [self addApplicationStatusToPList:@"applicationDidEnterBackground"];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication]
                                         beginBackgroundTaskWithExpirationHandler:NULL];
  
    UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        
        [[self dbHelper]insertMessageIntoDatabase:@"Attempting to wake up because of location key"];
        
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
           
            
            [[self dbHelper]insertMessageIntoDatabase:@"Woken up because of the location key"];
            
            NSLog(@"UIApplicationLaunchOptionsLocationKey");
            
            [self reInitialize];
            [self startListeningService];
        }
    }

    [[UIApplication sharedApplication] endBackgroundTask:taskId];

    return YES;
}

// BATTERY SAVINGS PART


-(void) startBatterySavingsListeners{

    NSDate* nowDate = [NSDate date];
    
    int timeInHours = [self hoursBetween:nowDate and:self.timeOfLastUpload];
    
    NSLog(@"%d hours since last", timeInHours);
    
    [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Tried to upload with %u",timeInHours]];
    
    if (timeInHours>=20) {
        [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Got to upload %u",timeInHours]];

        [self sendLogs];
        [self sendUploadURLRequest];
        self.timeOfLastUpload = nowDate;
    }
    
    [[self dbHelper]insertMessageIntoDatabase:@"Started battery savings"];
    
    NSLog(@"Started battery savings listener");
    self.accTimer = [NSTimer scheduledTimerWithTimeInterval:90 target:self
                                                   selector:@selector(accelerometerUpdate)
                                                   userInfo:nil
                                                    repeats:NO];
}


-(void) sendLogs{
    [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Sending logs"]];

    DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
    
    NSString *dataToUpload = [dbHelper getAllMessages];
    
    //   NSLog(@"%@",dataToUpload);
    
    if ([dataToUpload length]!=0)
    {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://testmeili-stackth.rhcloud.com/users/insertLog"]];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *postString = [NSString stringWithFormat:@"userId=%u&dataToUpload=%@",[dbHelper getUserId], dataToUpload];
        
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   id str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"%@",str);
                                   
                                   if ([str isEqual:@"success"]){
                                       [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Sent logs"]];
                                       [[DatabaseHelper getInstance] deleteUploadedLogs];
                                   }
                               }];
    }
}

-(void) sendUploadURLRequest{
    
    [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Sending locations"]];
    
    DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
    
    NSString *dataToUpload = [dbHelper getLocationsForUpload];
    
    //   NSLog(@"%@",dataToUpload);
    
    if ([dataToUpload length]!=0)
    {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://testmeili-stackth.rhcloud.com/users/insertLocationsIOS"]];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *postString = [NSString stringWithFormat:@"dataToUpload=%@", dataToUpload];
        
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   id str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"%@",str);
                                   
                                   if ([str isEqual:@"success"]){
                                       [[self dbHelper]insertMessageIntoDatabase:[NSString stringWithFormat:@"Sent locations"]];
                                       [[DatabaseHelper getInstance] updateUploadedLocations];
                                   }
                               }];
    }
}


- (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    // NSUInteger unitFlags = NSCalendarUnitHour;
    //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [firstDate timeIntervalSinceDate:secondDate]/60;
}

-(void) refreshBatterySavingsListeners{
    
    [[self dbHelper]insertMessageIntoDatabase:@"Refreshed battery savings"];
    
    NSLog(@"Refreshed battery savings listener");
    [self stopBatterySavingsListeners];
    [self startBatterySavingsListeners];
}

-(void) stopBatterySavingsListeners{
    // deactivate main thread - COMPLETE REST STATE
    
    [[self dbHelper]insertMessageIntoDatabase:@"Stopped battery savings"];
    
    NSLog(@"Stopped battery savings listener");

    if (self.accTimer) {
        [self.accTimer invalidate];
        self.accTimer = nil;
    }
    
    // deactivate listening thread
    if (self.delay30Seconds){
        [self.delay30Seconds invalidate];
        self.delay30Seconds = nil;
    }
}



-(void) accelerometerUpdate{
    
    [[self dbHelper]insertMessageIntoDatabase:@"Trigered battery savings update"];
    
    NSLog(@"Triggered battery savings updates");

    [self stopRegularListeners];
    
    self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.bgTask beginNewBackgroundTask];

    // refresh the accelerometer values
    [self emptySavingsAccelerometerValuesGetNewList];

    // unregister the accelerometer
    [self stopSavingsAccelerometer];
    // register the accelerometer
    [self startSavingsAccelerometer];
    // listen to accelerometer
    
    self.delay30Seconds = [NSTimer scheduledTimerWithTimeInterval:30 target:self
                                                         selector:@selector(stopAccelerometerDelayBy30Seconds)
                                                         userInfo:nil
                                                          repeats:NO];
    
}

-(void) stopAccelerometerDelayBy30Seconds{
    
    [[self dbHelper]insertMessageIntoDatabase:@"Testing if there is enough movement to leave battery savings state"];
    
    NSLog(@"Stopped battery savings updates");

    NSLog(@"Gathered data and testing battery savings update");
    
    //form accelerometer value object
   // NSLog(@"Gathered size :%d", self.savingsAccelerometerValues.count);

    [self stopSavingsAccelerometer];
    
    AccelerometerValues* savingsAccVal = [[AccelerometerValues alloc] initWithModel:self.savingsAccelerometerValues];

    // get if it is moving
    NSLog(@"Checking if it is moving %d", savingsAccVal.getTotalIsMoving);
    
    NSLog(@"Average :%f, StdDev :%f, NumberOfPeaks :%d", savingsAccVal.getTotalMean, savingsAccVal.getTotalStdDev, savingsAccVal.getTotalNumberOfPeaks);
    
    // check location skip
    if (savingsAccVal.getTotalIsMoving){
        [self startRegularListeners];
    }
    else {
        [self stopRegularListeners];
    }
    
    // restart the battery savings
    [self refreshBatterySavingsListeners];
}


-(void) startSavingsAccelerometer{
    
    [[self dbHelper]insertMessageIntoDatabase:@"Started listening saving accelerometer"];
    int count = 0;
    if ([self.savingMotionManager isAccelerometerAvailable])
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.savingMotionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CMAcceleration acceleration = accelerometerData.acceleration;
                NSMutableArray* arrayOfAccelerometer = [[NSMutableArray alloc]init];
                arrayOfAccelerometer =
                [self savingLowPassFilter:acceleration.x*9.8 y:acceleration.y*9.8 z:acceleration.z*9.8];
                
                 /*[arrayOfAccelerometer addObject:[NSNumber numberWithFloat:acceleration.x*9.81]];
                 [arrayOfAccelerometer addObject:[NSNumber numberWithFloat:acceleration.y*9.81]];
                 [arrayOfAccelerometer addObject:[NSNumber numberWithFloat:acceleration.z*9.81]];
                 */
                
                [self.savingsAccelerometerValues addObject:arrayOfAccelerometer];
             //   NSLog(@"size :%d", self.savingsAccelerometerValues.count);

            });
        }];
    } else
        NSLog(@"not active");
}

-(void) stopSavingsAccelerometer{
    
    [[self dbHelper]insertMessageIntoDatabase:@"Stopped listening savings accelerometer"];
    [self.savingMotionManager stopAccelerometerUpdates];
}


-(void)emptySavingsAccelerometerValuesGetNewList{
    self.savingsAccelerometerValues = NULL;
    self.savingsAccelerometerValues = [[NSMutableArray alloc]init];

    self.savingGravity = [[NSMutableArray alloc]init];
    self.savingGravity[0]= [NSNumber numberWithFloat:0.0f];
    self.savingGravity[1]= [NSNumber numberWithFloat:0.0f];
    self.savingGravity[2]= [NSNumber numberWithFloat:0.0f];
}


-(NSMutableArray *)savingLowPassFilter:(float)x y:(float)y z:(float)z{
    NSMutableArray *filteredValues = [[NSMutableArray alloc]init];
    
    
  /*  NSLog(@"Gravity %@, %@, %@", self.savingGravity[0], self.savingGravity[1], self.savingGravity[2]);
    
   NSLog(@"before filter %f, %f, %f", x,y,z);
    */
    float newXValue = self.ALPHA * [[self.savingGravity objectAtIndex:0] floatValue] + (1 - self.ALPHA) * x;
    //float oldXValue = [[self.gravity objectAtIndex:0] floatValue];
    
    float newYValue = self.ALPHA * [[self.savingGravity objectAtIndex:1] floatValue] + (1 - self.ALPHA) * y;
    //float oldYValue = [[self.gravity objectAtIndex:1] floatValue];
    
    float newZValue = self.ALPHA * [[self.savingGravity objectAtIndex:2] floatValue] + (1 - self.ALPHA) * z;
    //float oldZValue = [[self.gravity objectAtIndex:2] floatValue];
    
    self.savingGravity[0] = [NSNumber numberWithFloat:newXValue];
    self.savingGravity[1] = [NSNumber numberWithFloat:newYValue];
    self.savingGravity[2] = [NSNumber numberWithFloat:newZValue];
    
    [filteredValues addObject:[NSNumber numberWithFloat:(x-newXValue)]];
    [filteredValues addObject:[NSNumber numberWithFloat:(y-newYValue)]];
    [filteredValues addObject:[NSNumber numberWithFloat:(z-newZValue)]];
    
    
    //NSLog(@"after filter %@, %@, %@", filteredValues[0],filteredValues[1],filteredValues[2]);

    
    return filteredValues;
}

@end

