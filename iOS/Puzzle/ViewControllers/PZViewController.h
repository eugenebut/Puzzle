//
//  PZViewController.h
//  Puzzle

//////////////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>
#import "PZStopWatch.h"
#import "PZHelpViewController.h"

//////////////////////////////////////////////////////////////////////////////////////////
@class PZPuzzle;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZViewController : UIViewController<UIGestureRecognizerDelegate, PZStopWatchDelegate, PZHelpViewControllerDelegate>
{
@private
    PZStopWatch *_stopWatch;
    PZPuzzle *_puzzle;
}

@property (nonatomic, weak) IBOutlet UIView *layersView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *movesLabel;
@property (nonatomic, weak) IBOutlet UIButton *highScoresButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (nonatomic, strong) NSString *tilesImageFile;

- (IBAction)showHighscores:(UIButton *)aSender;
- (IBAction)showHelp:(UIButton *)aSender;

@end
