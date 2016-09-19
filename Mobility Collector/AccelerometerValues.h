//
//  AccelerometerValues.h
//  foo
//
//  Created by Adrian Corneliu Prelipcean on 15/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#include <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AccelerometerValues : NSObject

@property (nonatomic) float xMean, yMean, zMean, totalMean;
@property (nonatomic) float xStdDev, yStdDev, zStdDev, totalStdDev;
@property (nonatomic) float xMin, xMax, yMin, yMax, zMin, zMax, totalMin, totalMax;
@property (nonatomic) int xNumberOfPeaks, yNumberOfPeaks, zNumberOfPeaks, totalNumberOfPeaks;
@property (nonatomic) int totalNumberOfSteps;
@property (nonatomic) BOOL xIsMoving, yIsMoving, zIsMoving, totalIsMoving;
@property (nonatomic) int size;


/*Math*/
-(float) getMean: (NSMutableArray*)arrayVal;
-(float) getMin: (NSMutableArray*)arrayVal;
-(float) getMax: (NSMutableArray*)arrayVal;
-(float) getStdDev:(NSMutableArray*)arrayVal meanVal:(float)meanVal;
-(BOOL) getMovement: (NSMutableArray*)arrayVal meanVal:(float)meanVal;
-(int) getNumberOfPeaks: (NSMutableArray*)arrayVal meanVal:(float)meanVal stdDev:(float)stdDev;
-(int) getNumberOfSteps: (NSMutableArray*)arrayVal meanVal:(float)meanVal stdDev:(float)stdDev;

/*Constructor*/

-(id)initWithModel:(CMAccelerometerData *)aModel;

/*Setters*/

-(void) setXMean:(float)xMean;
-(void) setYMean:(float)yMean;
-(void) setZMean:(float)zMean;
-(void) setTotalMean:(float)totalMean;

-(void) setXStdDev:(float)xStdDev;
-(void) setYStdDev:(float)yStdDev;
-(void) setZStdDev:(float)zStdDev;
-(void) setTotalStdDev:(float)totalStdDev;

-(void) setXMin:(float)xMin;
-(void) setYMin:(float)yMin;
-(void) setZMin:(float)zMin;
-(void) setTotalMin:(float)totalMin;

-(void) setXMax:(float)xMax;
-(void) setYMax:(float)yMax;
-(void) setZMax:(float)zMax;
-(void) setTotalMax:(float)totalMax;

-(void) setXNumberOfPeaks:(int)xNumberOfPeaks;
-(void) setYNumberOfPeaks:(int)yNumberOfPeaks;
-(void) setZNumberOfPeaks:(int)zNumberOfPeaks;
-(void) setTotalNumberOfPeaks:(int)totalNumberOfPeaks;

-(void) setTotalNumberOfSteps:(int)totalNumberOfSteps;

-(void) setXIsMoving:(BOOL)xIsMoving;
-(void) setYIsMoving:(BOOL)yIsMoving;
-(void) setZIsMoving:(BOOL)zIsMoving;
-(void) setTotalIsMoving:(BOOL)totalIsMoving;

-(void) setSize:(int)size;

/*Getters*/

-(float) getXMean;
-(float) getYMean;
-(float) getZMean;
-(float) getTotalMean;

-(float) getXStdDev;
-(float) getYStdDev;
-(float) getZStdDev;
-(float) getTotalStdDev;

-(float) getXMin;
-(float) getYMin;
-(float) getZMin;
-(float) getTotalMin;

-(float) getXMax;
-(float) getYMax;
-(float) getZMax;
-(float) getTotalMax;

-(int) getXNumberOfPeaks;
-(int) getYNumberOfPeaks;
-(int) getZNumberOfPeaks;
-(int) getTotalNumberOfPeaks;

-(int) getTotalNumberOfSteps;

-(BOOL) getXIsMoving;
-(BOOL) getYIsMoving;
-(BOOL) getZIsMoving;
-(BOOL) getTotalIsMoving;

-(int) getSize;

@end