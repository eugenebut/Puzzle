//
//  PZViewController.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZViewController.h"
#import "PZPuzzle.h"
#import "PZTile.h"
#import <QuartzCore/QuartzCore.h>

//////////////////////////////////////////////////////////////////////////////////////////
static const NSUInteger kPuzzleSize = 4;
static const NSUInteger kShufflesCount = 30;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZViewController ()

@property (nonatomic, strong) PZPuzzle *puzzle;
@property (nonatomic, assign) BOOL wasInitialyShuffled; // shuffle at launch only

// properties below are helpers for pan gesture
@property (nonatomic, assign) PZTileLocation panTileLocation;
@property (nonatomic, strong) NSArray *pannedTiles;
@property (nonatomic, assign) CGRect panConstraints;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZViewController
@synthesize winInfoLabel, puzzle, puzzleImageFile, panTileLocation, pannedTiles,
            panConstraints, wasInitialyShuffled;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addTilesLayers];
    [self addGestureRecognizers];
}

- (void)viewDidUnload
{
    // TODO: make this weak
    self.winInfoLabel = nil;

    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)anAnimated
{
    // support shakes handling
    [self becomeFirstResponder];
    
    // shuffle if necessary
    if (!self.wasInitialyShuffled)
    {
        [self shuffle];
        self.wasInitialyShuffled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    // TODO: save puzzle state and unload it from memory
    // self.puzzle = nil;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -
#pragma mark Gestures Recognition

- (void)addGestureRecognizers
{
    // tap gesture recognizer
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];

    // pan gesture recognizer
    UIGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)aRecognizer
{
    PZTileLocation location = [self tileLocationFromGestureRecognizer:aRecognizer];
    return kNoneDirection != [self.puzzle allowedMoveDirectionForTileAtLocation:location];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)aGestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)anOtherGestureRecognizer
{
    return YES;
}

- (void)handleTap:(UIGestureRecognizer *)aRecognizer
{
    PZTileLocation location = [self tileLocationFromGestureRecognizer:aRecognizer];
    NSArray *tiles = [self.puzzle affectedTilesByTileMoveAtLocation:location];
    [self moveLayersOfTiles:tiles direction:[self.puzzle allowedMoveDirectionForTileAtLocation:location]];
    [self moveTileAtLocation:location];
}

- (void)handlePan:(UIPanGestureRecognizer *)aRecognizer
{
    if (UIGestureRecognizerStateBegan == aRecognizer.state ||
        UIGestureRecognizerStateChanged == aRecognizer.state)
    {
        if (UIGestureRecognizerStateBegan == aRecognizer.state)
        {
            // remember location we started pan from
            self.panTileLocation = [self tileLocationAtPoint:[aRecognizer locationOfTouch:0 inView:self.view]];
            
            // remember all tiles we going to move
            NSArray *tilesLocations = [self.puzzle affectedTilesLocationsByTileMoveAtLocation:self.panTileLocation];
            self.pannedTiles = [self.puzzle tilesAtLocations:tilesLocations];
            
            // setup constraints rect we want to keep out moving tiles in
            self.panConstraints = CGRectUnion([self rectForTilesAtLocations:tilesLocations],
                                              [self rectForTileAtLocation:self.puzzle.emptyTileLocation]);
        }

        // move tiles
        CGPoint translation = [aRecognizer translationInView:self.view];
        [CATransaction setDisableActions:YES]; // turn off layers animation
        [self moveLayersOfTiles:self.pannedTiles offset:translation constraints:self.panConstraints];
        [aRecognizer setTranslation:CGPointZero inView:self.view];
    }
    else if (UIGestureRecognizerStateEnded == aRecognizer.state ||
             UIGestureRecognizerStateCancelled == aRecognizer.state)
    {
        if (UIGestureRecognizerStateEnded == aRecognizer.state)
        {
            // finish move if necessary
            CGRect originalTileRect = [self rectForTileAtLocation:self.panTileLocation];
            CGRect currentTileRect = ((CALayer *)[self.puzzle tileAtLocation:self.panTileLocation].representedObject).frame;
            CGSize distancePassed = CGRectIntersection(originalTileRect, currentTileRect).size;

            // check if halfway is passed
            BOOL halfwayPassed = (distancePassed.width < CGRectGetWidth(originalTileRect) / 2) ||
                                 (distancePassed.height < CGRectGetHeight(originalTileRect) / 2);
            
            if (halfwayPassed)
            {
                [self moveTileAtLocation:self.panTileLocation];
            }
        }
        
        // update tiles and cleanup state
        [self updateTilesLocations:self.pannedTiles];
        self.pannedTiles = nil;
    }
}

- (PZTileLocation)tileLocationFromGestureRecognizer:(UIGestureRecognizer *)aRecognizer
{
    return [self tileLocationAtPoint:[aRecognizer locationInView:self.view]];
}

#pragma mark -
#pragma mark Tiles moving

- (void)moveLayersOfTiles:(NSArray *)aTiles direction:(PZMoveDirection)aDirection
{
    switch (aDirection)
    {
        case kLeftDirection:
            [self moveLayersOfTiles:aTiles offset:CGPointMake(-[self tileWidth], 0.0)];
            break;
        case kRightDirection:
            [self moveLayersOfTiles:aTiles offset:CGPointMake([self tileWidth], 0.0)];
            break;
        case kUpDirection:
            [self moveLayersOfTiles:aTiles offset:CGPointMake(0.0, -[self tileHeight])];
            break;
        case kDownDirection:
            [self moveLayersOfTiles:aTiles offset:CGPointMake(0.0, [self tileHeight])];
            break;
        case kNoneDirection:
            NSAssert(NO, @"We must not be here");
            break;
    }
}

- (void)moveLayersOfTiles:(NSArray *)aTiles offset:(CGPoint)anOffset
{
    for (id<IPZTile> tile in aTiles)
    {
        CALayer *layer = tile.representedObject;
        layer.position = CGPointMake(layer.position.x + anOffset.x,
                                     layer.position.y + anOffset.y);
    }
}

- (void)moveLayersOfTiles:(NSArray *)aTiles offset:(CGPoint)anOffset constraints:(CGRect)aConstraints
{
    // first apply constraints
    CGPoint constrainedOffset = anOffset;
    for (id<IPZTile> tile in aTiles)
    {
        CALayer *layer = tile.representedObject;
        CGRect newLayerFrame = CGRectOffset(layer.frame, constrainedOffset.x, constrainedOffset.y);
        
        // lets check if the new layer frame is out of constraints rect. If so we alter
        // the offset to keep constraints
        if (!CGRectContainsRect(aConstraints, newLayerFrame))
        {
            CGRect intersection = CGRectIntersection(newLayerFrame, aConstraints);
            if (CGRectIsEmpty(intersection))
            {
                return;
            }
            
            // do we need horizontal correction?
            CGFloat xCorrection = CGRectGetWidth(newLayerFrame) - CGRectGetWidth(intersection);
            BOOL shiftLeft = (CGRectGetMinX(intersection) == CGRectGetMinX(newLayerFrame));
            constrainedOffset.x += shiftLeft ? -xCorrection : xCorrection;

            // do we need vertical correction?
            CGFloat yCorrection = CGRectGetHeight(newLayerFrame) - CGRectGetHeight(intersection);
            BOOL shiftUp = (CGRectGetMinY(intersection) == CGRectGetMinY(newLayerFrame));
            constrainedOffset.y += shiftUp ? -yCorrection : yCorrection;
        }
    }
    
    [self moveLayersOfTiles:aTiles offset:constrainedOffset];
}

- (void)updateTilesLocations:(NSArray *)aTiles
{
    for (id<IPZTile>tile in aTiles)
    {
        CGRect frame = [self rectForTileAtLocation:tile.currentLocation];
        ((CALayer *)tile.representedObject).frame = frame;
    }
}

#pragma mark -
#pragma mark Tiles Info

- (PZTileLocation)tileLocationAtPoint:(CGPoint)aPoint
{
    return PZTileLocationMake((NSUInteger)aPoint.x / [self tileWidth],
                              (NSUInteger)aPoint.y / [self tileHeight]);
}

- (CGFloat)tileWidth
{
    static CGFloat result = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        result = [UIScreen mainScreen].applicationFrame.size.width / kPuzzleSize;
    });
    return result;
}

- (CGFloat)tileHeight
{
    static CGFloat result = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        result = [UIScreen mainScreen].applicationFrame.size.height / kPuzzleSize;
    });
    return result;
}

- (CGRect)rectForTilesAtLocations:(NSArray *)aTilesLocations
{
    CGRect result = CGRectZero;
    for (NSValue *location in aTilesLocations)
    {
        PZTileLocation tileLocation = [location tileLocation];
        CGRect rect = [self rectForTileAtLocation:tileLocation];
        result = CGRectEqualToRect(result, CGRectZero) ? rect : CGRectUnion(result, rect);
    }
    return result;
}

- (CGRect)rectForTileAtLocation:(PZTileLocation)aLocation
{
    // we allow 1.0 inset for border
    return CGRectInset(CGRectMake([self tileWidth] * aLocation.x,
                                  [self tileHeight] * aLocation.y,
                                  [self tileWidth], [self tileHeight]), 1.0, 1.0);
}

#pragma mark -
#pragma mark Shuffle

- (void)motionBegan:(UIEventSubtype)aMotion withEvent:(UIEvent *)anEvent
{
    
}

- (void)motionEnded:(UIEventSubtype)aMotion withEvent:(UIEvent *)anEvent
{
    if (UIEventSubtypeMotionShake == aMotion)
    {
        [self shuffle];
    }
}

- (void)motionCancelled:(UIEventSubtype)aMotion withEvent:(UIEvent *)anEvent
{    
    if (UIEventSubtypeMotionShake == aMotion)
    {
        self.view.userInteractionEnabled = YES;
    }
}

- (void)shuffle
{
    [self hideWinMessageIfNecessary];
    self.view.userInteractionEnabled = NO;
    [self shufflePuzzleWithNumberOfMoves:kShufflesCount];
}

- (void)shufflePuzzleWithNumberOfMoves:(NSUInteger)aNumberOfMoves
{
    if (0 == aNumberOfMoves)
    {
        // we done shuffling
        self.view.userInteractionEnabled = YES;
        return;
    }

    [self.puzzle moveTileToRandomLocationWithCompletionBlock:^(NSArray *aTiles, PZMoveDirection aDirection)
    {
        [CATransaction setAnimationDuration:0.05];
        [CATransaction setCompletionBlock:^
        {
            [self shufflePuzzleWithNumberOfMoves:aNumberOfMoves - 1];
        }];
        [self moveLayersOfTiles:aTiles direction:aDirection];
    }];
}

#pragma mark -
#pragma mark Misc

- (PZPuzzle *)puzzle
{
    if (nil == puzzle)
    {
        // TODO: restore state after memory warning
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.puzzleImageFile];
        puzzle = [[PZPuzzle alloc] initWithImage:image size:kPuzzleSize];
    }
    return puzzle;
}

- (void)addTilesLayers
{
    for (NSUInteger x = 0; x < kPuzzleSize; x++)
    {
        for (NSUInteger y = 0; y < kPuzzleSize; y++)
        {
            PZTileLocation tileLocation = PZTileLocationMake(x, y);
            id<IPZTile> tile = [self.puzzle tileAtLocation:tileLocation];
            CALayer *tileLayer = [CALayer new];
            tile.representedObject = tileLayer;
            
            tileLayer.opaque = YES;
            tileLayer.contents = (id)[tile.image CGImage];
            tileLayer.frame = [self rectForTileAtLocation:tileLocation];
            tileLayer.shadowOpacity = 0.7;
            tileLayer.shadowOffset = CGSizeMake(3.0, 3.0);
            tileLayer.shouldRasterize = YES;
            tileLayer.rasterizationScale = [UIScreen mainScreen].scale;
            [self.view.layer addSublayer:tileLayer];
        }
    }
}

- (void)moveTileAtLocation:(PZTileLocation)aLocation
{
    [self.puzzle moveTileAtLocation:aLocation];
    if (self.puzzle.isWin)
    {
        [self showWinMessage];
    }
}

- (void)showWinMessage
{
    self.view.userInteractionEnabled = NO;
    
    self.winInfoLabel.text = [[NSString alloc] initWithFormat:
                              @"Puzzle solved using %d moves\nShake your device to shuffle",
                              self.puzzle.movesCount];

    [self.view bringSubviewToFront:self.winInfoLabel];
    self.winInfoLabel.hidden = NO;
    self.winInfoLabel.alpha = 0.0;

    [UIView animateWithDuration:0.5 animations:^
    {
        self.winInfoLabel.alpha = 1.0;
    }];
}

- (void)hideWinMessageIfNecessary
{
    if (self.winInfoLabel.hidden)
    {
        return;
    }

    [UIView animateWithDuration:0.5 animations:^ {
         self.winInfoLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.winInfoLabel.hidden = YES;
    }];
}

@end
