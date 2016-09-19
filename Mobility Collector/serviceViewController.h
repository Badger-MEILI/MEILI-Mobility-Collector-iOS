//
//  serviceViewController.h
//  Mobility Collector
//
//  Created by Adrian Corneliu Prelipcean on 28/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmbeddedLocationListener.h"

@interface serviceViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *serviceHandlingButton;

@property (nonatomic) EmbeddedLocationListener *listener;

- (IBAction)buttonPushed:(id)sender;

@end
