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

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZWinViewController ()

@property (nonatomic, assign) NSUInteger time;
@property (nonatomic, assign) NSUInteger movesCount;
@property (nonatomic, assign) NSUInteger bestTime;
@property (nonatomic, assign) NSUInteger bestMovesCount;

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
        
        [self updateDefaultsValue:self.time forKey:kBestTimeDefaultsKey];
        [self updateDefaultsValue:self.movesCount forKey:kBestMovesDefaultsKey];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"Puzzle Solved!", "Puzzle Solved!");
    
    self.yourTimeLabel.text = [PZMessageFormatter timeMessage:self.time];
    self.yourMovesLabel.text = [PZMessageFormatter movesCountMessage:self.movesCount];
    
    self.bestTimeLabel.text = [PZMessageFormatter timeMessage:MIN(self.bestTime, self.time)];
    self.bestMovesLabel.text = [PZMessageFormatter movesCountMessage:MIN(self.bestMovesCount, self.movesCount)];
    
    // update message
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
