//
//  PZHighscoresViewController.m
//  Puzzle
//
//  Created by Eugene But on 9/23/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZHighscoresViewController.h"
#import "PZHightscoresAccessor.h"
#import "PZMessageFormatter.h"

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZHighscoresViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.movesValueLabel.text = [PZMessageFormatter movesCountMessage:
            [PZHightscoresAccessor defaultsValueForKey:kBestMovesDefaultsKey]];
    self.timeValueLabel.text = [PZMessageFormatter timeMessage:
            [PZHightscoresAccessor defaultsValueForKey:kBestTimeDefaultsKey]];
}

@end
