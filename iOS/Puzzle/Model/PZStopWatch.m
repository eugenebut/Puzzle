//
//  PZStopWatch.m
//  Puzzle
//
//  Created by Eugene But on 9/14/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZStopWatch.h"

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZStopWatch ()

@property (nonatomic, weak) NSTimer *timer;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZStopWatch

- (void)start {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                selector:@selector(timeDidFire)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)reset {
    if (0 != self.totalSeconds) {
        self.totalSeconds = 0;
        [self.delegate PZStopWatchDidChangeTime:self];
    }
}

- (void)timeDidFire {
    self.totalSeconds++;
    [self.delegate PZStopWatchDidChangeTime:self];
}

@end
