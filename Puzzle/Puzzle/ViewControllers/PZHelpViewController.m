//
//  PZHelpViewController.m
//  Puzzle
//
//  Created by Eugene But on 10/10/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZHelpViewController.h"

//////////////////////////////////////////////////////////////////////////////////////////
static const NSTimeInterval kAnimationDuration = 0.5;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZHelpViewController ()

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZHelpViewController

- (void)viewDidLoad {
    self.textView.text = NSLocalizedString(@"Puzzle_Help", @"Puzzle Help Description");
}

- (IBAction)hide {
    [self.delegate helpViewControllerWantsHide:self];
}

- (IBAction)beginTutorial:(UIButton *)aSender {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.hideButton.alpha = 0.0;
        aSender.alpha = 0.0;
        self.textView.alpha = 0.0;
        self.view.userInteractionEnabled = NO;
        // TODO: show progress
    }
    completion:^(BOOL finished) {
        self.hideButton.hidden = YES;
        
        [self.delegate helpViewControllerSolvePuzzle:self completionBlock:^{
            self.textView.text = NSLocalizedString(@"Puzzle_Objective", @"Puzzle Objective Description");
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.textView.alpha = 1.0;
            }];
        }];
    }];
}

@end
