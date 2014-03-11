//
//  PZStopWatch.m
//  Puzzle
//
//  Created by Eugene But on 9/14/12.
//
//

////////////////////////////////////////////////////////////////////////////////
#import "PZStopWatch.h"

////////////////////////////////////////////////////////////////////////////////
// NSTimer retains it's target and to avoid a retain cycle we don't want
// PZStopWatch to be a timer target. This utility class will be a taged for
// NSTimer.
@interface PZStopWatchTimerTarget: NSObject

- (instancetype)initWithBlock:(void (^)())aBlock;

@property (nonatomic, copy, readonly) void (^block)();

@end

////////////////////////////////////////////////////////////////////////////////
@implementation PZStopWatchTimerTarget

- (instancetype)initWithBlock:(void (^)())aBlock {
    if (nil != (self = [super init])) {
        _block = [aBlock copy];
    }
    return self;
}

- (void)timeDidFire {
    self.block();
}

@end


////////////////////////////////////////////////////////////////////////////////
@interface PZStopWatch ()

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) PZStopWatchTimerTarget *timerTarget;

@end

////////////////////////////////////////////////////////////////////////////////
@implementation PZStopWatch

- (void)dealloc {
    [self stop];
}

- (void)start {
    __weak typeof(self) weakSelf = self;
    self.timerTarget = [[PZStopWatchTimerTarget alloc] initWithBlock:^{
        weakSelf.totalSeconds++;
        [weakSelf.delegate PZStopWatchDidChangeTime:self];
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self.timerTarget
                                                selector:@selector(timeDidFire)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
    self.timerTarget = nil;
}

- (void)reset {
    if (0 != self.totalSeconds) {
        self.totalSeconds = 0;
        [self.delegate PZStopWatchDidChangeTime:self];
    }
}

@end
