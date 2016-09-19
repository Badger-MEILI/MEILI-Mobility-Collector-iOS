//
//  AccelerometerValues.m
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 15/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "AccelerometerValues.h"
#import <CoreMotion/CoreMotion.h>

/*
@interface  AccelerometerValues()

//float getMean(NSMutableArray* foo);

@end
*/

@implementation AccelerometerValues


/*Implementing Setters*/

    //Mean
-(void)setXMean:(float)xMean{
   _xMean = xMean;
}

-(void)setYMean:(float)yMean{
    _yMean = yMean;
}

-(void)setZMean:(float)zMean{
    _zMean = zMean;
}

-(void)setTotalMean:(float)totalMean{
    _totalMean = totalMean;
}

    //Min
-(void)setXMin:(float)xMin{
    _xMin = xMin;
}

-(void)setYMin:(float)yMin{
    _yMin = yMin;
}

-(void)setZMin:(float)zMin{
    _zMin = zMin;
}

-(void)setTotalMin:(float)totalMin{
    _totalMin = totalMin;
}

    //Max

-(void)setXMax:(float)xMax{
    _xMax=xMax;
}

-(void)setYMax:(float)yMax{
    _yMax = yMax;
}

-(void)setZMax:(float)zMax{
    _zMax = zMax;
}

-(void)setTotalMax:(float)totalMax{
    _totalMax = totalMax;
}

    //StdDev

-(void)setXStdDev:(float)xStdDev{
    _xStdDev = xStdDev;
}

-(void)setYStdDev:(float)yStdDev{
    _yStdDev = yStdDev;
}

-(void)setZStdDev:(float)zStdDev{
    _zStdDev = zStdDev;
}

-(void)setTotalStdDev:(float)totalStdDev{
    _totalStdDev = totalStdDev;
}

    //Number of peaks

-(void)setXNumberOfPeaks:(int)xNumberOfPeaks{
    _xNumberOfPeaks = xNumberOfPeaks;
}

-(void)setYNumberOfPeaks:(int)yNumberOfPeaks{
    _yNumberOfPeaks = yNumberOfPeaks;
}

-(void)setZNumberOfPeaks:(int)zNumberOfPeaks{
    _zNumberOfPeaks = zNumberOfPeaks;
}

-(void)setTotalNumberOfPeaks:(int)totalNumberOfPeaks{
    _totalNumberOfPeaks = totalNumberOfPeaks;
}

    //isMoving

-(void)setXIsMoving:(BOOL)xIsMoving{
    _xIsMoving=xIsMoving;
}

-(void)setYIsMoving:(BOOL)yIsMoving{
    _yIsMoving=yIsMoving;
}

-(void)setZIsMoving:(BOOL)zIsMoving{
    _zIsMoving=zIsMoving;
}

-(void)setTotalIsMoving:(BOOL)totalIsMoving{
    _totalIsMoving=totalIsMoving;
}

    //Size

-(void)setSize:(int)size{
    _size=size;
}

    //Total number of steps

-(void)setTotalNumberOfSteps:(int)totalNumberOfSteps{
    _totalNumberOfSteps=totalNumberOfSteps;
}

// Getters

    //Mean

-(float)getXMean{
    return self.xMean;
}

-(float)getYMean{
    return self.yMean;
}

-(float)getZMean{
    return self.zMean;
}

-(float)getTotalMean{
    return self.totalMean;
}

    //Min
-(float)getXMin{
    return self.xMin;
}

-(float)getYMin{
    return self.yMin;
}

-(float)getZMin{
    return self.zMin;
}

-(float)getTotalMin{
    return self.totalMin;
}

    //Max

-(float)getXMax{
    return self.xMax;
}

-(float)getYMax{
    return self.yMax;
}

-(float)getZMax{
    return self.zMax;
}

-(float)getTotalMax{
    return self.totalMax;
}

    //StdDev

-(float)getXStdDev{
    return self.xStdDev;
}

-(float)getYStdDev{
    return self.yStdDev;
}

-(float)getZStdDev{
    return self.zStdDev;
}

-(float)getTotalStdDev{
    return self.totalStdDev;
}

    //Number of peaks

-(int)getXNumberOfPeaks{
    return self.xNumberOfPeaks;
}

-(int)getYNumberOfPeaks{
    return self.yNumberOfPeaks;
}

-(int)getZNumberOfPeaks{
    return self.zNumberOfPeaks;
}

-(int)getTotalNumberOfPeaks{
    return self.totalNumberOfPeaks;
}

    //isMoving

-(BOOL)getXIsMoving{
    return self.xIsMoving;
}

-(BOOL)getYIsMoving{
    return self.yIsMoving;
}

-(BOOL)getZIsMoving{
    return self.zIsMoving;
}

-(BOOL)getTotalIsMoving{
    return self.totalIsMoving;
}

    //Number of steps


-(int)getTotalNumberOfSteps{
    return self.totalNumberOfSteps;
}

    //Size

-(int)getSize{
    return self.size;
}


    //Math operation

-(float)getMin:(NSMutableArray *)arrayVal{
    float xMin;
    xMin = [arrayVal[0] floatValue];
    
    NSNumber* someValue;
    
    for (someValue in arrayVal){
        if ([someValue floatValue]<xMin)
        {
            xMin = [someValue floatValue];
        }
    }
    
    return xMin;
}

-(float)getMax:(NSMutableArray *)arrayVal{
    float xMax;
    xMax = [arrayVal[0] floatValue];
    
    NSNumber* someValue;
    
    for (someValue in arrayVal){
        if ([someValue floatValue]>xMax)
        {
            xMax = [someValue floatValue];
        }
    }
    
    return xMax;
}

-(float)getMean:(NSMutableArray *)arrayVal{

    int nr = 0;
    float sum = 0;
    
    for (NSNumber* f in arrayVal) {
        sum = sum + [f floatValue];
        nr++;
    }
    
    if (nr == 0) {
        return 0;
    }
    
    return (float) sum / nr;
}

-(float)getStdDev:(NSMutableArray *)arrayVal meanVal:(float)meanVal{
    float squareSum = 0;
    int numberOfValues = 0;
    for (NSNumber* f in arrayVal) {
        squareSum = squareSum + pow([f floatValue] - meanVal, 2);
        numberOfValues++;
    }
    if (numberOfValues == 0)
        return 0;
    return sqrt(squareSum / numberOfValues);
}

-(BOOL)getMovement:(NSMutableArray *)arrayVal meanVal:(float)meanVal{
    // for Android meanVal > 2.5
    
    if (meanVal > 1.25)
        return true;
    
    return false;
}

-(int)getNumberOfPeaks:(NSMutableArray *)arrayVal meanVal:(float)meanVal stdDev:(float)stdDev{
    
    float comparisonValue = meanVal + sqrt(stdDev);
    
    BOOL prevValue = false;
    BOOL currentValue = false;
    int index = 0;
    int numberOfPeaks = 0;
    
    for (NSNumber* f in arrayVal) {
        if (index < 1) {
            if (index == 0)
                prevValue = [f floatValue] > comparisonValue;
        } else {
            currentValue = [f floatValue] > comparisonValue;
            if (currentValue && !prevValue)
                numberOfPeaks++;
            prevValue = currentValue;
        }
        index++;
    }
    return numberOfPeaks;
}

-(int)getNumberOfSteps:(NSMutableArray *)arrayVal meanVal:(float)meanVal stdDev:(float)stdDev{
    float comparisonValue = meanVal + (float) sqrt((double) stdDev);
    
    BOOL prevValue = false;
    BOOL currentValue = false;
    int index = 0;
    int numberOfSteps = 0;
    
    // in Android comparisonValue > 3
    if (comparisonValue > 2.5) {
        for (NSNumber* f in arrayVal) {
            if (index < 1) {
                if (index == 0)
                    prevValue = [f floatValue] > comparisonValue;
            } else {
                currentValue = [f floatValue] > comparisonValue;
                if (currentValue && !prevValue)
                    numberOfSteps++;
                prevValue = currentValue;
            }
            index++;
        }
        
    }
    return numberOfSteps;
}

-(id)initWithModel:(NSMutableArray*)aModel {
    //feedAccelerometerValues(aModel);
    
    NSMutableArray* xValues = [[NSMutableArray alloc]init];
    NSMutableArray* yValues = [[NSMutableArray alloc]init];
    NSMutableArray* zValues = [[NSMutableArray alloc]init];
    NSMutableArray* totalValues = [[NSMutableArray alloc]init];
    
    NSLog(@"%lu",(unsigned long)aModel.count);
    
    for(NSMutableArray *obj in aModel) {
        NSNumber* xValue = [NSNumber numberWithFloat:[obj[0] floatValue]];
        NSNumber* yValue = [NSNumber numberWithFloat:[obj[1] floatValue]];
        NSNumber* zValue = [NSNumber numberWithFloat:[obj[2] floatValue]];
        
        double totalVal = sqrt([xValue doubleValue] * [xValue doubleValue] +
                               [yValue doubleValue] * [yValue doubleValue]  +
                                   [zValue doubleValue] * [zValue doubleValue]);
        
        NSNumber* totalValue = [NSNumber numberWithDouble:totalVal];
        
        [xValues addObject: xValue];
        [yValues addObject: yValue];
        [zValues addObject: zValue];
        [totalValues addObject: totalValue];
        
    }
   
   [self getMean:xValues];
    
    
    [self setXMean:[self getMean:xValues]];
    [self setYMean:[self getMean:yValues]];
    [self setZMean:[self getMean:zValues]];
    [self setTotalMean:[self getMean:totalValues]];

    
    [self setXMin:[self getMin:xValues]];
    [self setYMin:[self getMin:yValues]];
    [self setZMin:[self getMin:zValues]];
    [self setTotalMin:[self getMin:totalValues]];

    [self setXMax:[self getMax:xValues]];
    [self setYMax:[self getMax:yValues]];
    [self setZMax:[self getMax:zValues]];
    [self setTotalMax:[self getMax:totalValues]];

    [self setXStdDev:[self getStdDev:xValues meanVal:[self getXMean]]];
    [self setYStdDev:[self getStdDev:yValues meanVal:[self getYMean]]];
    [self setZStdDev:[self getStdDev:zValues meanVal:[self getZMean]]];
    [self setTotalStdDev:[self getStdDev:totalValues meanVal:[self getTotalMean]]];
    
    [self setXIsMoving:[self getMovement:xValues meanVal:[self getXMean]]];
    [self setYIsMoving:[self getMovement:yValues meanVal:[self getYMean]]];
    [self setZIsMoving:[self getMovement:zValues meanVal:[self getZMean]]];
    [self setTotalIsMoving:[self getMovement:totalValues meanVal:[self getTotalMean]]];
    
    [self setXNumberOfPeaks:[self getNumberOfPeaks:xValues meanVal:[self getXMean] stdDev:[self getXStdDev]]];
    [self setYNumberOfPeaks:[self getNumberOfPeaks:yValues meanVal:[self getYMean] stdDev:[self getYStdDev]]];
    [self setZNumberOfPeaks:[self getNumberOfPeaks:zValues meanVal:[self getZMean] stdDev:[self getZStdDev]]];
    [self setTotalNumberOfPeaks:[self getNumberOfPeaks:totalValues meanVal:[self getTotalMean] stdDev:[self getTotalStdDev]]];
    
    [self setTotalNumberOfSteps:[self getNumberOfSteps:totalValues meanVal:[self getTotalMean] stdDev:[self getTotalStdDev]]];
    
    [self setSize:[self getSize]];
    
    return self;
}



@end