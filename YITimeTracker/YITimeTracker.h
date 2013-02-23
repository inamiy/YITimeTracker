//
//  YITimeTracker.h
//  YITimeTracker
//
//  Created by Yasuhiro Inami on 2013/02/23.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^YITimeTrackerStartBlock)(void);
typedef void (^YITimeTrackerStopBlock)(NSTimeInterval elapsedTime);

typedef NS_OPTIONS(NSUInteger, YITimeTrackerDisplayStyle) {
    YITimeTrackerDisplayStyleNone               = 0,
    
    YITimeTrackerDisplayStyleNSLog              = 1 << 0,
    YITimeTrackerDisplayStyleSVProgressHUD      = 1 << 1,
    YITimeTrackerDisplayStyleMTStatusBarOverlay = 1 << 2,
    
    YITimeTrackerDisplayStyleAutomatic          = 1 << 31   // selects one of the above style
};


@interface YITimeTracker : NSObject

+ (BOOL)isTimeTrackingWithName:(NSString*)name;

+ (void)setDisplayStyle:(YITimeTrackerDisplayStyle)style;   // default = automatic

// displays time using displayStyle
+ (void)startTimeTrackingWithName:(NSString*)name;
+ (void)stopTimeTrackingWithName:(NSString*)name;

// customizable methods
+ (void)startTimeTrackingWithName:(NSString*)name completion:(YITimeTrackerStartBlock)completion;
+ (void)stopTimeTrackingWithName:(NSString*)name completion:(YITimeTrackerStopBlock)completion;

@end
