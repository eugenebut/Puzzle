//
//  PZWinViewController.m
//  Puzzle
//
//  Created by Eugene But on 9/15/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZWinViewController.h"
#import "PZMessageFormatter.h"

//////////////////////////////////////////////////////////////////////////////////////////
static NSString *const kBestTimeDefaultsKey = @"PZBestTimeDefaults";
static NSString *const kBestMovesDefaultsKey = @"PZBestMovesDefaults";

static NSTimeInterval kAnimationInterval = 2.0;

//////////////////////////////////////////////////////////////////////////////////////////
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

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZWinViewController

- (id)initWithTime:(NSUInteger)aTime movesCount:(NSUInteger)aMovesCount
{
    self = [super init];
    if (nil != self)
    {
        self.time = aTime;
        self.movesCount = aMovesCount;

        self.bestTime = [self defaultsValueForKey:kBestTimeDefaultsKey];
        self.bestMovesCount = [self defaultsValueForKey:kBestMovesDefaultsKey];
        
        self.effectiveBestTime = MIN(self.bestTime, self.time);
        self.effectiveBestMovesCount = MIN(self.bestMovesCount, self.movesCount);

        [self updateDefaultsValue:self.time forKey:kBestTimeDefaultsKey];
        [self updateDefaultsValue:self.movesCount forKey:kBestMovesDefaultsKey];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"Puzzle Solved!", @"Message title after solwing the puzzle");
    self.movesLabel.text = NSLocalizedString(@"Moves", @"Number of moves made while solving the puzzle");
    self.timeLabel.text = NSLocalizedString(@"Time", "Elapsed time while solving the puzzle");
    self.yourScoreLabel.text = NSLocalizedString(@"Your Score:", "");
    self.highScoreLabel.text = NSLocalizedString(@"High Score:", "");

}
- (void)viewDidAppear:(BOOL)anAnimated
{
    [super viewDidAppear:anAnimated];
        
    NSUInteger maxValue = MAX(MAX(self.time, self.movesCount),
                              MAX(self.effectiveBestTime, self.effectiveBestMovesCount));

    [NSTimer scheduledTimerWithTimeInterval:kAnimationInterval / maxValue target:self
            selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
}

- (void)timerDidFire:(NSTimer *)aTimer
{
    // update numbers
    if (self.animatedTime <= self.time ||
        self.animatedMovesCount <= self.movesCount ||
        self.animatedBestTime <= self.effectiveBestTime ||
        self.animatedBestMovesCount <= self.effectiveBestMovesCount)
    {
        if (self.animatedTime <= self.time)
        {
            self.yourTimeLabel.text = [PZMessageFormatter timeMessage:self.animatedTime++];
        }
        
        if (self.animatedMovesCount <= self.movesCount)
        {
            self.yourMovesLabel.text = [PZMessageFormatter movesCountMessage:self.animatedMovesCount++];
        }
        
        if (self.animatedBestTime <= self.effectiveBestTime)
        {
            self.bestTimeLabel.text = [PZMessageFormatter timeMessage:self.animatedBestTime++];
        }
        
        if (self.animatedBestMovesCount <= self.effectiveBestMovesCount)
        {
            self.bestMovesLabel.text = [PZMessageFormatter movesCountMessage:self.animatedBestMovesCount++];
        }
        return;
    }

    // we are done update message
    NSString *titleMessage = nil;
    if (self.time < self.bestTime && self.movesCount < self.bestMovesCount)
    {
        titleMessage = NSLocalizedString(@"New highscore and best time!", "");
    }
    else if (self.time < self.bestTime)
    {
        titleMessage = NSLocalizedString(@"New best time!", "");
        
    }
    else if (self.movesCount < self.bestMovesCount)
    {
        titleMessage = NSLocalizedString(@"New highscore!", "");
    }
    else
    {
        titleMessage = @"";
    }
    self.messageLabel.text = [titleMessage stringByAppendingFormat:@"\n%@",
                              NSLocalizedString(@"Shake your device to shuffle", "")];
    
    // show the message
    [UIView animateWithDuration:0.5 animations:^
     {
         self.messageLabel.alpha = 1.0;
     }];
    
    [aTimer invalidate];
}

- (NSUInteger)defaultsValueForKey:(NSString *)aKey
{
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    if (nil != result)
    {
        return [result unsignedIntegerValue];
    }
    return ULONG_MAX;
}

- (void)updateDefaultsValue:(NSUInteger)aValue forKey:(NSString *)aKey
{
    NSNumber *bestValue = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    if (nil == bestValue || aValue < [bestValue unsignedIntegerValue])
    {
        [[NSUserDefaults standardUserDefaults]
            setObject:[NSNumber numberWithUnsignedInteger:aValue] forKey:aKey];
    }
}

@end
