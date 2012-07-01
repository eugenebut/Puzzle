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

@property (nonatomic, assign) PZTileLocation pivotLocation;
@property (nonatomic, strong) NSArray *pivotTiles;
@property (nonatomic, assign) CGRect panConstraints;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZViewController
@synthesize  puzzle, puzzleImageFile, pivotLocation, pivotTiles, panConstraints;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTiles];
    [self addGestureRecognizers];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    self.puzzle = nil;
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

    UIGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
}

- (UISwipeGestureRecognizer *)newSwipeGestureRecognizerForDirection:(UISwipeGestureRecognizerDirection)aDirection
    handler:(SEL)aSelector
{
    UISwipeGestureRecognizer *result = [[UISwipeGestureRecognizer alloc]
                                       initWithTarget:self action:aSelector];
    result.delegate = self;
    result.direction = aDirection;
    return result;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)aRecognizer
{
    PZTileLocation location = [self tileLocationFromGestureRecognizer:aRecognizer];
    return kNoneDirection != [self.puzzle allowedMoveDirectionForTileAtLocation:location];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleTap:(UIGestureRecognizer *)aRecognizer
{
    PZTileLocation location = [self tileLocationFromGestureRecognizer:aRecognizer];
    NSArray *tiles = [self.puzzle affectedTilesByTileMoveAtLocation:location];
    switch ([self.puzzle allowedMoveDirectionForTileAtLocation:location])
    {
        case kLeftDirection:
            [self moveTiles:tiles offset:CGPointMake(-[self tileWidth], 0.0)];
            break;
        case kRightDirection:
            [self moveTiles:tiles offset:CGPointMake([self tileWidth], 0.0)];
            break;
        case kUpDirection:
            [self moveTiles:tiles offset:CGPointMake(0.0, -[self tileHeight])];
            break;
        case kDownDirection:
            [self moveTiles:tiles offset:CGPointMake(0.0, [self tileHeight])];
            break;
        case kNoneDirection:
            NSAssert(NO, @"We should not even begin gesture recognition");
            break;
    }
    [self.puzzle moveTileAtLocation:location];
}

- (void)handlePan:(UIPanGestureRecognizer *)aRecognizer
{
    if (UIGestureRecognizerStateBegan == aRecognizer.state)
    {
        // remember location we started pan from
        self.pivotLocation = [self tileLocationAtPoint:[aRecognizer locationOfTouch:0 inView:self.view]];
        
        // remember all tiles we going to move
        NSArray *tilesLocations = [self.puzzle affectedTilesLocationsByTileMoveAtLocation:self.pivotLocation];
        self.pivotTiles = [self.puzzle tilesAtLocations:tilesLocations];
        
        // setup constraints rect we want to keep out moving tiles in
        self.panConstraints = CGRectInset(CGRectUnion([self rectForTilesAtLocations:tilesLocations],
                                                      [self rectForTileAtLocation:self.puzzle.emptyTileLocation]), 1.0, 1.0);
    }
    else if (UIGestureRecognizerStateEnded == aRecognizer.state || UIGestureRecognizerStateCancelled == aRecognizer.state)
    {
        CGRect originalTileRect = CGRectInset([self rectForTileAtLocation:self.pivotLocation], 1.0, 1.0);
        CGRect currentTileRect = ((CALayer *)[self.puzzle tileAtLocation:self.pivotLocation].representedObject).frame;
        CGRect intersection = CGRectIntersection(originalTileRect, currentTileRect);

        if (CGRectGetWidth(intersection) < CGRectGetWidth(originalTileRect) / 2 ||
            (CGRectGetHeight(intersection) < CGRectGetHeight(originalTileRect) / 2))
        {
            // proceed with horizontal move
            [self.puzzle moveTileAtLocation:self.pivotLocation];
        }

        for (PZTile *tile in self.pivotTiles)
        {
//            NSLog(@"tile.currentLocation: %d %d", tile.currentLocation.x, tile.currentLocation.y);
//            NSLog(@"Rect: %@", NSStringFromCGRect([self rectForTileAtLocation:tile.currentLocation]));
            ((CALayer *)tile.representedObject).frame = CGRectInset([self rectForTileAtLocation:tile.currentLocation], 1.0, 1.0);
        }
    }
    else if (UIGestureRecognizerStateBegan == aRecognizer.state ||
        UIGestureRecognizerStateChanged == aRecognizer.state)
    {
        CGPoint translation = [aRecognizer translationInView:self.view];
        [CATransaction setDisableActions:YES]; // turn off layers animation
        [self moveTiles:self.pivotTiles offset:translation constraints:self.panConstraints];
        [aRecognizer setTranslation:CGPointZero inView:self.view];
    }
}

- (PZTileLocation)tileLocationFromGestureRecognizer:(UIGestureRecognizer *)aRecognizer
{
    return [self tileLocationAtPoint:[aRecognizer locationInView:self.view]];
}

- (void)moveTiles:(NSArray *)aTiles offset:(CGPoint)anOffset
{
    for (PZTile *tile in aTiles)
    {
        CALayer *layer = tile.representedObject;
        layer.position = CGPointMake(layer.position.x + anOffset.x, layer.position.y + anOffset.y);
    }
}

- (void)moveTiles:(NSArray *)aTiles offset:(CGPoint)anOffset constraints:(CGRect)aConstraints
{
    // first apply constraints
    CGPoint constrainedOffset = anOffset;
    for (PZTile *tile in aTiles)
    {
        CALayer *layer = tile.representedObject;
        CGRect newLayerFrame = CGRectOffset(layer.frame, constrainedOffset.x, constrainedOffset.y);
        if (!CGRectContainsRect(aConstraints, newLayerFrame))
        {
//            NSLog(@"constrainedOffset.x: %f", constrainedOffset.x);
//            NSLog(@"constrainedOffset.y: %f", constrainedOffset.y);
            CGRect intersection = CGRectIntersection(newLayerFrame, aConstraints);

            CGFloat xCorrection = CGRectGetWidth(newLayerFrame) - CGRectGetWidth(intersection);
//            NSLog(@"xCorrection: %f", xCorrection);
            BOOL shiftLeft = (CGRectGetMinX(intersection) == CGRectGetMinX(newLayerFrame));
//            NSLog(@"shiftRight: %d", shiftLeft);
            constrainedOffset.x += shiftLeft ? -xCorrection : xCorrection;

            CGFloat yCorrection = CGRectGetHeight(newLayerFrame) - CGRectGetHeight(intersection);
            //NSLog(@"yCorrection: %f", yCorrection);
            BOOL shiftUp = (CGRectGetMinY(intersection) == CGRectGetMinY(newLayerFrame));
            //NSLog(@"shiftUp: %d", shiftUp);
            constrainedOffset.y += shiftUp ? -yCorrection : yCorrection;
        }
    }
    
    [self moveTiles:aTiles offset:constrainedOffset];
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
    for (NSUInteger x = 0; x < kPuzzleSize; x++)
    {
        for (NSUInteger y = 0; y < kPuzzleSize; y++)
        {
            CALayer *tileLayer = [CALayer new];
            
            PZTileLocation location = PZTileLocationMake(x, y);
            PZTile *tile = [self.puzzle tileAtLocation:location];
            tile.representedObject = tileLayer;
            
            tileLayer.opaque = YES;
            tileLayer.contents = (id)[tile.image CGImage];
            tileLayer.frame = CGRectInset([self rectForTileAtLocation:location], 1.0, 1.0);
            [self.view.layer addSublayer:tileLayer];
        }
    }
}

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
    return CGRectInset(CGRectMake([self tileWidth] * aLocation.x,
                                  [self tileHeight] * aLocation.y,
                                  [self tileWidth], [self tileHeight]), 1.0, 1.0);
}

@end
