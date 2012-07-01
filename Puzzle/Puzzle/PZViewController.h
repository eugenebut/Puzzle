//
//  PZViewController.h
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PZPuzzle;

@interface PZViewController : UIViewController<UIGestureRecognizerDelegate>
{
@private
    PZPuzzle *puzzle;
}

@property (strong, nonatomic) IBOutlet UILabel *winInfoLabel;

@property (nonatomic, strong) NSString *puzzleImageFile;

@end
