//
//  EmbeddedLocation.h
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 22/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#ifndef foo_EmbeddedLocation_h
#define foo_EmbeddedLocation_h


#include <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "AccelerometerValues.h"

@interface EmbeddedLocation : NSObject

@property (nonatomic) AccelerometerValues* accVals;
@property (nonatomic) CLLocation* location;
@property (nonatomic) long userId;

/*Constructor*/

-(id)initWithModel:(AccelerometerValues *) accVals location:(CLLocation*)location userId:(long)userId;

-(AccelerometerValues*) getAccelerometerValues;
-(CLLocation*) getLocation;

/*Get insert to sql form*/
-(NSString*) getSqlInsertStatement;

@end

#endif
