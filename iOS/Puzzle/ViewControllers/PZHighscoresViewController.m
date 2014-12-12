//
//  PZHighscoresViewController.m
//  Puzzle
//
//  Created by Eugene But on 9/23/12.
//
//

////////////////////////////////////////////////////////////////////////////////
#import "PZHighscoresViewController.h"
#import "PZHightscoresAccessor.h"
#import "PZMessageFormatter.h"

////////////////////////////////////////////////////////////////////////////////
@implementation PZHighscoresViewController

+ (BOOL)canShowHighscores {
    return [PZHightscoresAccessor hasHighscores];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.movesValueLabel.text = [PZMessageFormatter movesCountLongMessage:
            [PZHightscoresAccessor defaultsUIntegerForKey:kBestMovesDefaultsKey]];
    self.timeValueLabel.text = [PZMessageFormatter timeMessage:
            [PZHightscoresAccessor defaultsUIntegerForKey:kBestTimeDefaultsKey]];
    
    self.movesLabel.text = NSLocalizedString(@"Min Moves:", @"Highscores Best Time");
    self.timeLabel.text = NSLocalizedString(@"Best Time:", @"Highscores Best Time");
}

@end
