YITimeTracker
=============

A simple time-tracking tool which can easily integrate with other libraries e.g. SVProgressHUD, MTStatusBarOverlay.

How to use
----------
```
- (void)measureTimeAndDisplaySomewhere
{
    // set display style (default = automatic = SVProgressHUD or MTStatusBarOverlay or NSLog)
    [YITimeTracker setDisplayStyle:YITimeTrackerDisplayStyleAutomatic];
    
    [YITimeTracker startTimeTrackingWithName:@"Loading"];
    
    [self doSomethingWithCompletion:^{
        [YITimeTracker stopTimeTrackingWithName:@"Loading"];
    }];
}

- (void)measureTimeCustomized
{
    [YITimeTracker startTimeTrackingWithName:@"Saving" completion:^{
        NSLog(@"Now Saving...");
    }];
    
    [self doSomethingWithCompletion:^{
        [YITimeTracker stopTimeTrackingWithName:@"Saving" completion:^(NSTimeInterval elapsedTime) {
            NSLog(@"OK Saved! %f sec",elapsedTime);
        }];
    }];
}
```

License
-------
YITimeTracker is available under the [Beerware](http://en.wikipedia.org/wiki/Beerware) license.
