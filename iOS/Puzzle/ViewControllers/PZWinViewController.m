//
//  PZWinViewController.m
//  Puzzle
//
//  Created by Eugene But on 9/15/12.
//
//

////////////////////////////////////////////////////////////////////////////////
#import "PZWinViewController.h"
#import "PZMessageFormatter.h"
#import "PZHightscoresAccessor.h"

static NSTimeInterval kAnimationInterval = 0.01;

////////////////////////////////////////////////////////////////////////////////
@interface PZWinViewController ()

@property (nonatomic, assign) NSUInteger time;
@property (nonatomic, assign) NSUInteger movesCount;
@property (nonatomic, assign) NSUInteger bestTime;
@property (nonatomic, assign) NSUInteger bestMovesCount;
@property (nonatomic, assign) NSUInteger effectiveBestTime;
@property (nonatomic, assign) NSUInteger effectiveBestMovesCount;

@property (nonatomic, assign) NSUInteger animatedTime;
@property (nonatomic, assign) NSUInteger animatedMovesCount;
@property (nonatomic, assign) NSUInteger animatedBestTime;
@property (nonatomic, assign) NSUInteger animatedBestMovesCount;

@end

////////////////////////////////////////////////////////////////////////////////
@implementation PZWinViewController

- (id)initWithTime:(NSUInteger)aTime movesCount:(NSUInteger)aMovesCount {
    self = [super init];
    if (nil != self) {
        self.time = aTime;
        self.movesCount = aMovesCount;

        self.bestTime = [PZHightscoresAccessor defaultsIntegerForKey:kBestTimeDefaultsKey];
        self.bestMovesCount = [PZHightscoresAccessor defaultsIntegerForKey:kBestMovesDefaultsKey];
        
        self.effectiveBestTime = MIN(self.bestTime, self.time);
        self.effectiveBestMovesCount = MIN(self.bestMovesCount, self.movesCount);

        [PZHightscoresAccessor updateDefaultsInteger:self.time forKey:kBestTimeDefaultsKey];
        [PZHightscoresAccessor updateDefaultsInteger:self.movesCount forKey:kBestMovesDefaultsKey];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateMessages];
}

- (void)startAnimation {
    self.messageLabel.alpha = 1.0;
    self.animatedBestMovesCount = 0;
    self.animatedBestTime = 0;
    self.animatedMovesCount = 0;
    self.animatedTime = 0;

    self.messageLabel.alpha = 0.0;
    
    [NSTimer scheduledTimerWithTimeInterval:kAnimationInterval target:self
            selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
}

- (void)timerDidFire:(NSTimer *)aTimer {
    // update numbers
    if (self.animatedTime < self.time ||
        self.animatedMovesCount < self.movesCount ||
        self.animatedBestTime < self.effectiveBestTime ||
        self.animatedBestMovesCount < self.effectiveBestMovesCount) {
        if (self.animatedTime < self.time) {
            self.yourTimeLabel.text = [PZMessageFormatter timeMessage:self.animatedTime];
            self.animatedTime += MAX(1, (self.time * kAnimationInterval));
        }
        
        if (self.animatedMovesCount < self.movesCount) {
            self.yourMovesLabel.text = [PZMessageFormatter movesCountMessage:self.animatedMovesCount];
            self.animatedMovesCount += MAX(1, (self.movesCount * kAnimationInterval));
        }
        
        if (self.animatedBestTime < self.effectiveBestTime) {
            self.bestTimeLabel.text = [PZMessageFormatter timeMessage:self.animatedBestTime];
            self.animatedBestTime += MAX(1, (self.effectiveBestTime * kAnimationInterval));
        }
        
        if (self.animatedBestMovesCount < self.effectiveBestMovesCount) {
            self.bestMovesLabel.text = [PZMessageFormatter movesCountMessage:self.animatedBestMovesCount];
            self.animatedBestMovesCount += MAX(1, (self.effectiveBestMovesCount * kAnimationInterval));
        }
        
        return;
    }

    // final labels update
    self.yourTimeLabel.text = [PZMessageFormatter timeMessage:self.time];
    self.yourMovesLabel.text = [PZMessageFormatter movesCountMessage:self.movesCount];
    self.bestTimeLabel.text = [PZMessageFormatter timeMessage:self.effectiveBestTime];
    self.bestMovesLabel.text = [PZMessageFormatter movesCountMessage:self.effectiveBestMovesCount];

    // show the message
    [UIView animateWithDuration:0.25 animations:^{
         self.messageLabel.alpha = 1.0;
    }];
    
    [aTimer invalidate];
}

- (void)updateMessages
{
    self.titleLabel.text = NSLocalizedString(@"Puzzle Solved!", @"Message title after solwing the puzzle");
    self.movesLabel.text = NSLocalizedString(@"Moves", @"Number of moves made while solving the puzzle");
    self.timeLabel.text = NSLocalizedString(@"Time", "Elapsed time while solving the puzzle");
    self.yourScoreLabel.text = NSLocalizedString(@"Your Score:", "");
    self.highScoreLabel.text = NSLocalizedString(@"High Score:", "");
    // we are done update message
    NSString *titleMessage = nil;
    if (self.time < self.bestTime && self.movesCount < self.bestMovesCount) {
        titleMessage = NSLocalizedString(@"New highscore and best time!", "");
    }
    else if (self.time < self.bestTime) {
        titleMessage = NSLocalizedString(@"New best time!", "");
        
    }
    else if (self.movesCount < self.bestMovesCount) {
        titleMessage = NSLocalizedString(@"New highscore!", "");
    }
    else {
        titleMessage = @"";
    }
    self.messageLabel.text = [titleMessage stringByAppendingFormat:@"\n%@",
                              NSLocalizedString(@"Shake your device to shuffle", "")];
}

@end
