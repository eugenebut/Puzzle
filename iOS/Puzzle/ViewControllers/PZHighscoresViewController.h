//
//  PZHighscoresViewController.h
//  Puzzle
//
//  Created by Eugene But on 9/23/12.
//
//

////////////////////////////////////////////////////////////////////////////////
@import UIKit;

////////////////////////////////////////////////////////////////////////////////
@interface PZHighscoresViewController : UIViewController

+ (BOOL)canShowHighscores;

@property (weak, nonatomic) IBOutlet UILabel *movesValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
