//
//  PZViewController.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PZViewController.h"
#import "PZPuzzle.h"
#import "PZTile.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger kPuzzleSize = 4;

@interface PZViewController ()

@property (nonatomic, strong) PZPuzzle *puzzle;

@end

@implementation PZViewController
@synthesize  puzzle, puzzleImageFile;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTiles];
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
        // TODO: restore state
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.puzzleImageFile];
        puzzle = [[PZPuzzle alloc] initWithImage:image size:kPuzzleSize];
    }
    return puzzle;
}

- (void)addTiles
{
    CGFloat tileWidth = [self tileWidth];
    CGFloat tileHeight = [self tileHeight];

    for (NSUInteger x = 0; x < kPuzzleSize; x++)
    {
        for (NSUInteger y = 0; y < kPuzzleSize; y++)
        {
            CALayer *tileLayer = [CALayer new];
            PZTile *tile = [self.puzzle tileAtLocation:PZTileLocationMake(x, y)];
            tileLayer.contents = (id)[tile.image CGImage];
            tile.representedObject = tileLayer;
            tileLayer.frame = CGRectInset(CGRectMake(x * tileWidth, y * tileHeight,
                                                     tileWidth, tileHeight), 1.0, 1.0);
            [self.view.layer addSublayer:tileLayer];
        }
    }
}

- (PZTileLocation)tileLocationAtPoint:(CGPoint)aPoint
{
    return PZTileLocationMake(aPoint.x * kPuzzleSize / [self tileWidth], aPoint.y * kPuzzleSize / [self tileHeight]);
}

- (CGFloat)tileWidth
{
    return [UIScreen mainScreen].applicationFrame.size.width / kPuzzleSize;
}

- (CGFloat)tileHeight
{
    return [UIScreen mainScreen].applicationFrame.size.height / kPuzzleSize;
}

@end
