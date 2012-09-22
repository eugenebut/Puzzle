//
//  PZViewController.h
//  Puzzle

//////////////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>
#import "PZStopWatch.h"

//////////////////////////////////////////////////////////////////////////////////////////
@class PZPuzzle;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZViewController : UIViewController<UIGestureRecognizerDelegate, PZStopWatchDelegate>
{
@private
    PZStopWatch *_stopWatch;
    PZPuzzle *_puzzle;
}

@property (nonatomic, weak) IBOutlet UIView *layersView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *movesLabel;
@property (nonatomic, strong) NSString *tilesImageFile;

@end
