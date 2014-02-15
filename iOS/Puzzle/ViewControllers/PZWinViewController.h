//
//  PZWinViewController.h
//  Puzzle
//
//  Created by Eugene But on 9/15/12.
//
//

////////////////////////////////////////////////////////////////////////////////
@import UIKit;

////////////////////////////////////////////////////////////////////////////////
@interface PZWinViewController : UIViewController

- (instancetype)initWithTime:(NSUInteger)aTime
                  movesCount:(NSUInteger)aMovesCount;

- (void)startAnimation;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *yourMovesLabel;
@property (nonatomic, weak) IBOutlet UILabel *yourTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *bestMovesLabel;
@property (nonatomic, weak) IBOutlet UILabel *bestTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UILabel *movesLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *yourScoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *highScoreLabel;

- (void)updateMessages;

@end

