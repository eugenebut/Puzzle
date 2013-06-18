//
//  PZHelpViewController.h
//  Puzzle
//
//  Created by Eugene But on 10/10/12.
//
//

////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////
@protocol PZHelpViewControllerDelegate;

////////////////////////////////////////////////////////////////////////////////
@interface PZHelpViewController : UIViewController

@property (nonatomic, assign) id<PZHelpViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)hide;
- (IBAction)beginTutorial:(UIButton *)sender;

@end

////////////////////////////////////////////////////////////////////////////////
@protocol PZHelpViewControllerDelegate

- (void)helpViewControllerWantsHide:(PZHelpViewController *)aController;
- (void)helpViewControllerSolvePuzzle:(PZHelpViewController *)aController completionBlock:(void(^)(void))aBlock;
- (void)helpViewControllerShuflePuzzle:(PZHelpViewController *)aController completionBlock:(void(^)(void))aBlock;
- (void)helpViewControllerLearnTap:(PZHelpViewController *)aController completionBlock:(void(^)(void))aBlock;
- (void)helpViewControllerLearnPan:(PZHelpViewController *)aController completionBlock:(void(^)(void))aBlock;
- (void)helpViewControllerLearnMoveAll:(PZHelpViewController *)aController completionBlock:(void(^)(void))aBlock;

@end