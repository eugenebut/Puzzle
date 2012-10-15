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
@interface UIControl(TargetAction)

- (void)PZSetTouchUpInsideAction:(SEL)anAction;

@end

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
        self.nextButton.alpha = 0.0;
        self.textView.alpha = 0.0;
    }
    completion:^(BOOL finished) {
        self.hideButton.hidden = YES;
        
        [self.delegate helpViewControllerSolvePuzzle:self completionBlock:^{
            self.textView.text = NSLocalizedString(@"Puzzle_Objective", @"Puzzle Objective Description");
            
            [self.nextButton setTitle:NSLocalizedString(@"Shuffle Puzle", @"Shuffle button label") forState:UIControlStateNormal];
            [self.nextButton PZSetTouchUpInsideAction:@selector(shuffle:)];
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.textView.alpha = 1.0;
                self.nextButton.alpha = 1.0;
            }];
        }];
    }];
}

- (IBAction)shuffle:(UIButton *)aSender {
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.nextButton.alpha = 0.0;
        self.textView.alpha = 0.0;
    }
    completion:^(BOOL finished) {
        [self.delegate helpViewControllerShuflePuzzle:self completionBlock:^{
            self.textView.text = NSLocalizedString(@"Puzzle_Tutorial_Step_1", @"Puzzle Tutorial 1st step");
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.textView.alpha = 1.0;
                [self.delegate helpViewControllerLearnTap:self completionBlock:^{
                    
                }];
            }];
        }];
    }];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation UIControl(TargetAction)

- (void)PZSetTouchUpInsideAction:(SEL)anAction {
    id target = [[self allTargets] anyObject];
    [self removeTarget:target action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:target action:anAction forControlEvents:UIControlEventTouchUpInside];
}

@end
