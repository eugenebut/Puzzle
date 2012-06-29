//
//  PZViewController.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PZViewController.h"
#import "PZPuzzle.h"

static const NSUInteger kPuzzleSize = 4;

@interface PZViewController ()

@property (nonatomic, strong) PZPuzzle *puzzle;

@end

@implementation PZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
    self.puzzle = nil;
}

- (PZPuzzle *)puzzle
{
    if (nil == puzzle)
    {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.puzzleImageFile];
        puzzle = [[PZPuzzle alloc] initWithImage:image size:kPuzzleSize];
    }
    return puzzle;
}

@end
