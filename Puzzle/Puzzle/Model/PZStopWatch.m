//
//  PZStopWatch.m
//  Puzzle
//
//  Created by Eugene But on 9/14/12.
//
//

#import "PZStopWatch.h"

@interface PZStopWatch ()

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSUInteger time;

@end

@implementation PZStopWatch

- (void)start
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                  selector:@selector(timeDidFire) userInfo:nil repeats:YES];
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)reset
{
    if (0 != self.time)
    {
        self.time = 0;
        [self.delegate PZStopWatchDidChangeTime:self];
    }
}

- (void)timeDidFire
{
    self.time++;
    [self.delegate PZStopWatchDidChangeTime:self];
}

- (NSUInteger)seconds
{
    return self.time % 60;
}

- (NSUInteger)minutes
{
    return self.time / 60 % 60;
}

- (NSUInteger)hours
{
    return self.time / 60 / 60;
}

@end
