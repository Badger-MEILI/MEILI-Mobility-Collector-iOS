//
//  EmbeddedLocationListener.h
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 22/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#ifndef foo_EmbeddedLocationListener_h
#define foo_EmbeddedLocationListener_h


#include <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "AccelerometerValues.h"
#import "EmbeddedLocation.h"
#import "DatabaseHelper.h"
#import "BackgroundTaskManager.h"

@interface EmbeddedLocationListener : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic) CLLocationManager* latentLocationManager;
@property (nonatomic) CMMotionManager* motionManager;
@property (nonatomic) CMMotionManager* savingMotionManager;
@property (nonatomic) DatabaseHelper* dbHelper;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer * delay10Seconds;
@property (nonatomic) NSTimer * delay30Seconds;
@property (nonatomic) NSTimer * accTimer;

@property (nonatomic) BackgroundTaskManager * bgTask;

@property (nonatomic) CLLocation* previousLocation;
@property (nonatomic) bool refreshAccelerometer;

@property (nonatomic) float ALPHA;
@property (nonatomic) bool skipOneLocation;
@property (nonatomic) int distFreq;
@property (nonatomic) long userId;
@property (nonatomic) NSDate* timeOfLastUpload;

@property (nonatomic) NSMutableArray* gravity;
@property (nonatomic) NSMutableArray* savingGravity;

//acc values for this session
@property (nonatomic) NSMutableArray* accelerometerValues;
@property (nonatomic) NSMutableArray* savingsAccelerometerValues;


+(EmbeddedLocationListener*) getInstance;

-(void) startListeningService;
-(void) stopListeningService;
-(void) resetAccelerometerValues;

-(void) openDatabase;
-(void) closeDatabase;
-(void) startAccelerometer;
-(void) stopAccelerometer;

-(NSMutableArray*) lowPassFilter: (float)x y:(float)y z:(float)z;
-(NSMutableArray*) emptyAccelerometerValuesGetNewList;
-(NSMutableArray*) getAccelerometerValues;

-(BOOL) isAccurate: (CLLocation*) location;

-(int) getTimeToNext: (CLLocation*) prevLocation currentLocation:(CLLocation*)currentLocation;

@end

#endif
