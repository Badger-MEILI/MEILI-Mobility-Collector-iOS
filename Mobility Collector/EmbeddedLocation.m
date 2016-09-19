//
//  EmbeddedLocation.m
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 22/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "EmbeddedLocation.h"

@implementation EmbeddedLocation

-(id)initWithModel:(AccelerometerValues *)accVals location:(CLLocation *)location userId:(long)userId{
    self = [super init];
    self.userId = userId;
    self.location=location;
    self.accVals = accVals;
    return self;
}

-(CLLocation *)getLocation{
    return self.location;
}

-(AccelerometerValues *)getAccelerometerValues{
    return self.accVals;
}

-(NSString*)getSqlInsertStatement{
    CLLocation* loc = [self getLocation];
    AccelerometerValues* acc = [self accVals];
    NSString *query = [NSString stringWithFormat:@"insert into Location_table values ('%ld', '%ld', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d')",
                       (long int) loc.timestamp.timeIntervalSince1970,
                       self.userId,
                       loc.coordinate.latitude,
                       loc.coordinate.longitude,
                       loc.speed,
                       loc.altitude,
                       loc.course,
                       loc.horizontalAccuracy,
                       0,
                       acc.xMean,
                       acc.yMean,
                       acc.zMean,
                       acc.totalMean,
                       acc.xStdDev,
                       acc.yStdDev,
                       acc.zStdDev,
                       acc.totalStdDev,
                       acc.xMin,
                       acc.yMin,
                       acc.zMin,
                       acc.totalMin,
                       acc.xMax,
                       acc.yMax,
                       acc.zMax,
                       acc.totalMax,
                       acc.xNumberOfPeaks,
                       acc.yNumberOfPeaks,
                       acc.zNumberOfPeaks,
                       acc.totalNumberOfPeaks,
                       acc.totalNumberOfSteps,
                       acc.xIsMoving,
                       acc.yIsMoving,
                       acc.zIsMoving,
                       acc.totalIsMoving,
                       acc.size,
                       false
                       ];
    
    return query;
}

@end
