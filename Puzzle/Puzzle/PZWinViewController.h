//
//  PZWinViewController.h
//  Puzzle
//
//  Created by Eugene But on 9/15/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZWinViewController : UIViewController

- (id)initWithTime:(NSUInteger)aTime movesCount:(NSUInteger)aMovesCount;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *yourMovesLabel;
@property (nonatomic, weak) IBOutlet UILabel *yourTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *bestMovesLabel;
@property (nonatomic, weak) IBOutlet UILabel *bestTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@end

