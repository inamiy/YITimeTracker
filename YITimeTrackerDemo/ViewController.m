//
//  ViewController.m
//  YITimeTrackerDemo
//
//  Created by Yasuhiro Inami on 2013/02/23.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "ViewController.h"
#import "YITimeTracker.h"

#define DISPLAY_NAME    @"Loading"


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

#pragma mark Start/Stop example

- (void)measureTime
{
    [YITimeTracker startTimeTrackingWithName:DISPLAY_NAME];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [YITimeTracker stopTimeTrackingWithName:DISPLAY_NAME];
        
    });
}

- (void)measureTimeCustomized
{
    [YITimeTracker startTimeTrackingWithName:DISPLAY_NAME completion:^{
        NSLog(@"Now Saving...");
    }];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [YITimeTracker stopTimeTrackingWithName:DISPLAY_NAME completion:^(NSTimeInterval elapsedTime) {
            NSLog(@"OK Saved! %f sec",elapsedTime);
        }];
        
    });
}

#pragma mark -

#pragma mark IBActions

- (IBAction)handleAutomaticButton:(id)sender
{
    if ([YITimeTracker isTimeTrackingWithName:DISPLAY_NAME]) return;
    
    [YITimeTracker setDisplayStyle:YITimeTrackerDisplayStyleAutomatic];
    
    [self measureTime];
}

- (IBAction)handleNSLogButton:(id)sender
{
    if ([YITimeTracker isTimeTrackingWithName:DISPLAY_NAME]) return;
    
    [YITimeTracker setDisplayStyle:YITimeTrackerDisplayStyleNSLog];
    
    [self measureTime];
}

- (IBAction)handleSVProgressHUDButton:(id)sender
{
    if ([YITimeTracker isTimeTrackingWithName:DISPLAY_NAME]) return;
    
    [YITimeTracker setDisplayStyle:YITimeTrackerDisplayStyleSVProgressHUD];
    
    [self measureTime];
}

- (IBAction)handleMTStatusBarOverlayButton:(id)sender
{
    if ([YITimeTracker isTimeTrackingWithName:DISPLAY_NAME]) return;
    
    [YITimeTracker setDisplayStyle:YITimeTrackerDisplayStyleMTStatusBarOverlay];
    
    [self measureTime];
}

- (IBAction)handleCustomButton:(id)sender
{
    if ([YITimeTracker isTimeTrackingWithName:DISPLAY_NAME]) return;
    
    [self measureTimeCustomized];
}

@end
