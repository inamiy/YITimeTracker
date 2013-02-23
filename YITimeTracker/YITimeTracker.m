//
//  YITimeTracker.m
//  YITimeTracker
//
//  Created by Yasuhiro Inami on 2013/02/23.
//  Copyright (c) 2013年 Yasuhiro Inami. All rights reserved.
//

#import "YITimeTracker.h"

static NSMutableDictionary* __trackingTimeDictionary;
static YITimeTrackerDisplayStyle __style;


@implementation YITimeTracker

+ (void)initialize
{
    __trackingTimeDictionary = [NSMutableDictionary dictionary];
    __style = YITimeTrackerDisplayStyleAutomatic;
}

+ (NSMutableDictionary*)trackingTimeDictionary
{
    return __trackingTimeDictionary;
}

+ (void)setDisplayStyle:(YITimeTrackerDisplayStyle)style
{
    __style = style;
}

+ (BOOL)isTimeTrackingWithName:(NSString*)name
{
    return !![self.trackingTimeDictionary objectForKey:name];
}

#pragma mark Message

+ (NSString*)_startedMessageWithName:(NSString*)name
{
    return [NSString stringWithFormat:@"%@...",name];
}

+ (NSString*)_stoppedMessageWithName:(NSString*)name elapsedTime:(NSTimeInterval)elapsedTime
{
    return [NSString stringWithFormat:@"%@: %0.2f sec",name,elapsedTime];
}

#pragma mark Start/Stop

+ (void)startTimeTrackingWithName:(NSString*)name completion:(YITimeTrackerStartBlock)completion
{
    [self _startTimeTrackingWithName:name completions:@[completion]];
}

+ (void)_startTimeTrackingWithName:(NSString*)name completions:(NSArray*)completions
{
    if (![self isTimeTrackingWithName:name]) {
        
        for (YITimeTrackerStartBlock completion in completions) {
            if (completion) {
                completion();
            }
        }
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        [self.trackingTimeDictionary setObject:@(startTime) forKey:name];
    }
}

+ (void)stopTimeTrackingWithName:(NSString*)name completion:(YITimeTrackerStopBlock)completion
{
    [self _stopTimeTrackingWithName:name completions:@[completion]];
}

+ (void)_stopTimeTrackingWithName:(NSString*)name completions:(NSArray*)completions
{
    CFAbsoluteTime startTime = [[self.trackingTimeDictionary objectForKey:name] doubleValue];
    CFAbsoluteTime elapsedTime = CFAbsoluteTimeGetCurrent() - startTime;
    
    if ([self isTimeTrackingWithName:name]) {
        [self.trackingTimeDictionary removeObjectForKey:name];
        
        for (YITimeTrackerStopBlock completion in completions) {
            if (completion) {
                completion(elapsedTime);
            }
        }
    }
}

+ (void)startTimeTrackingWithName:(NSString*)name
{
    BOOL isAutomatic = (__style & YITimeTrackerDisplayStyleAutomatic) > 0;
    
    NSMutableArray* completions = [NSMutableArray array];
    
    // SVProgressHUD
    Class aSVProgressHUDClass = NSClassFromString(@"SVProgressHUD");
    SEL aSVProgressHUDSelector = NSSelectorFromString(@"showWithStatus:");
    
    if ((aSVProgressHUDClass && [aSVProgressHUDClass respondsToSelector:aSVProgressHUDSelector]) &&
        ((__style & YITimeTrackerDisplayStyleSVProgressHUD) || (isAutomatic && completions.count == 0))) {
        
        [completions addObject:^{
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[aSVProgressHUDClass methodSignatureForSelector:aSVProgressHUDSelector]];
            invocation.target = aSVProgressHUDClass;
            invocation.selector = aSVProgressHUDSelector;
            
            NSString* message = [self _startedMessageWithName:name];
            [invocation setArgument:&message atIndex:2];
            
            [invocation invoke];
        }];
        
    }
    
    // MTStatusBarOverlay
    Class aMTStatusBarOverlayClass = NSClassFromString(@"MTStatusBarOverlay");
    SEL aMTStatusBarOverlaySelector = NSSelectorFromString(@"postMessage:");
    
    if ((aMTStatusBarOverlayClass && [aMTStatusBarOverlayClass instancesRespondToSelector:aMTStatusBarOverlaySelector]) &&
        ((__style & YITimeTrackerDisplayStyleMTStatusBarOverlay) || (isAutomatic && completions.count == 0))) {
        
        id instance = nil;
        
        if ([aMTStatusBarOverlayClass respondsToSelector:@selector(sharedOverlay)]) {
            instance = [aMTStatusBarOverlayClass performSelector:@selector(sharedOverlay)];
        }
        
        if (instance) {
            [completions addObject:^{
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[instance methodSignatureForSelector:aMTStatusBarOverlaySelector]];
                invocation.target = instance;
                invocation.selector = aMTStatusBarOverlaySelector;
                
                NSString* message = [self _startedMessageWithName:name];
                [invocation setArgument:&message atIndex:2];
                
                [invocation invoke];
            }];
        }
        
    }
    
    // NSLog
    if ((__style & YITimeTrackerDisplayStyleNSLog) || (isAutomatic && completions.count == 0)) {
        
        [completions addObject:^(NSTimeInterval elapsedTime) {
            NSString* message = [self _startedMessageWithName:name];
            NSLog(@"%@",message);
        }];
        
    }
    
    [self _startTimeTrackingWithName:name completions:completions];
    
}

+ (void)stopTimeTrackingWithName:(NSString*)name
{
    BOOL isAutomatic = (__style & YITimeTrackerDisplayStyleAutomatic) > 0;
    
    NSMutableArray* completions = [NSMutableArray array];
    
    // SVProgressHUD
    Class aSVProgressHUDClass = NSClassFromString(@"SVProgressHUD");
    SEL aSVProgressHUDSelector = NSSelectorFromString(@"showSuccessWithStatus:");
    
    if ((aSVProgressHUDClass && [aSVProgressHUDClass respondsToSelector:aSVProgressHUDSelector]) &&
        ((__style & YITimeTrackerDisplayStyleSVProgressHUD) || (isAutomatic && completions.count == 0))) {
        
        [completions addObject:^(NSTimeInterval elapsedTime) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[aSVProgressHUDClass methodSignatureForSelector:aSVProgressHUDSelector]];
            invocation.target = aSVProgressHUDClass;
            invocation.selector = aSVProgressHUDSelector;
            
            NSString* message = [self _stoppedMessageWithName:name elapsedTime:elapsedTime];
            [invocation setArgument:&message atIndex:2];
            
            [invocation invoke];
        }];
        
    }
    
    // MTStatusBarOverlay
    Class aMTStatusBarOverlayClass = NSClassFromString(@"MTStatusBarOverlay");
    SEL aMTStatusBarOverlaySelector = NSSelectorFromString(@"postFinishMessage:duration:");
    
    if ((aMTStatusBarOverlayClass && [aMTStatusBarOverlayClass instancesRespondToSelector:aMTStatusBarOverlaySelector]) &&
        ((__style & YITimeTrackerDisplayStyleMTStatusBarOverlay) || (isAutomatic && completions.count == 0))) {
        
        id instance = nil;
        
        if ([aMTStatusBarOverlayClass respondsToSelector:@selector(sharedOverlay)]) {
            instance = [aMTStatusBarOverlayClass performSelector:@selector(sharedOverlay)];
        }
        
        if (instance) {
            [completions addObject:^(NSTimeInterval elapsedTime) {
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[instance methodSignatureForSelector:aMTStatusBarOverlaySelector]];
                invocation.target = instance;
                invocation.selector = aMTStatusBarOverlaySelector;
                
                NSString* message = [self _stoppedMessageWithName:name elapsedTime:elapsedTime];
                [invocation setArgument:&message atIndex:2];
                
                NSTimeInterval duration = 2;
                [invocation setArgument:&duration atIndex:3];
                
                [invocation invoke];
            }];
        }
        
    }
    
    // NSLog
    if ((__style & YITimeTrackerDisplayStyleNSLog) ||
        (isAutomatic && completions.count == 0)) {
        
        [completions addObject:^(NSTimeInterval elapsedTime) {
            NSString* message = [self _stoppedMessageWithName:name elapsedTime:elapsedTime];
            NSLog(@"%@",message);
        }];
        
    }
    
    [self _stopTimeTrackingWithName:name completions:completions];
}

@end
