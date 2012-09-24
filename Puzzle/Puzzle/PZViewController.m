//
//  PZViewController.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZViewController.h"
#import "PZWinViewController.h"
#import "PZHighscoresViewController.h"
#import "PZPuzzle.h"
#import "PZTile.h"
#import "PZMessageFormatter.h"
#import <QuartzCore/QuartzCore.h>

//////////////////////////////////////////////////////////////////////////////////////////
static const BOOL kSupportsShadows = YES;
static const NSUInteger kPuzzleSize = 4;
static const NSUInteger kShufflesCount = 1;

static const CGFloat kTransparencyAnimationDuration = 0.5;

static NSString *const kPuzzleState = @"PZPuzzleStateDefaults";
static NSString *const kElapsedTime = @"PZElapsedTimeDefaults";
static NSString *const kWinController = @"PZWinControllerDefaults";

//////////////////////////////////////////////////////////////////////////////////////////
@interface CALayer(PZExtentions)

- (void)setupPuzzleShadow;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZViewController ()

@property (nonatomic, strong) PZPuzzle *puzzle;
@property (nonatomic, strong) PZStopWatch *stopWatch;
@property (nonatomic, assign, getter=isGameStarted) BOOL gameStarted; // shuffle at launch only

@property (nonatomic, strong) PZWinViewController *winViewController;
@property (nonatomic, strong) PZHighscoresViewController *highscoresViewController;

// properties below are helpers for pan gesture
@property (nonatomic, assign) PZTileLocation panTileLocation;
@property (nonatomic, strong) NSArray *pannedTiles;
@property (nonatomic, assign) CGRect panConstraints;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZViewController

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addTilesLayers];
    [self addGestureRecognizers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(applicationDidEnterBackgroundNotification:)
            name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(applicationWillEnterForegroundNotification:)
            name:UIApplicationWillEnterForegroundNotification object:nil];

    [self restoreState];
    
    self.highScoresButton.hidden = ![PZHighscoresViewController canShowHighscores];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
            name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
            name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)anAnimated
{
    // support shakes handling
    [self becomeFirstResponder];
    
    // shuffle if necessary
    if ([self hasSavedState])
    {
        [self updateMoveLabel];
        [self updateTimeLabel];
        if (!self.puzzle.isWin)
        {
            [self.stopWatch start];
        }
    }
    else if (!self.isGameStarted)
    {
        [self shuffleWithCompletionBlock:^{
            [self.stopWatch start];
            [self updateMoveLabel];
        }];
        self.gameStarted = YES;
    }
}

- (void)dealloc
{
    [self.stopWatch stop];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)aNotification
{
    [self saveGameState];
    [self.stopWatch stop];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)aNotification
{
    [self.stopWatch start];
}

#pragma mark -
#pragma mark State

- (BOOL)hasSavedState
{
    return nil != [[NSUserDefaults standardUserDefaults] objectForKey:kPuzzleState];
}

- (void)saveGameState
{
    [[NSUserDefaults standardUserDefaults] setObject:self.puzzle.state forKey:kPuzzleState];
    [[NSUserDefaults standardUserDefaults] setObject:
            [NSNumber numberWithUnsignedInteger:self.stopWatch.totalSeconds]
            forKey:kElapsedTime];

    [[NSUserDefaults standardUserDefaults]
            setObject:[NSKeyedArchiver archivedDataWithRootObject:self.winViewController]
            forKey:kWinController];
}

- (void)restoreState
{
    self.stopWatch.totalSeconds = [[[NSUserDefaults standardUserDefaults]
                                    objectForKey:kElapsedTime] unsignedIntegerValue];
    if (self.puzzle.isWin)
    {
        self.view.userInteractionEnabled = NO;
        NSData *controllerData = [[NSUserDefaults standardUserDefaults] objectForKey:kWinController];
        if (nil != controllerData)
        {
            self.winViewController = [NSKeyedUnarchiver unarchiveObjectWithData:
                    [[NSUserDefaults standardUserDefaults] objectForKey:kWinController]];
            [self.winViewController updateMessages];
            [self.view addSubview:self.winViewController.view];
        }
    }
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
    [self hideHighscoresMessageIfNecessary];
    
    if (CGRectContainsPoint([self tilesArea], [aRecognizer locationInView:self.view]))
    {
        PZTileLocation location = [self tileLocationFromGestureRecognizer:aRecognizer];
        return kNoneDirection != [self.puzzle allowedMoveDirectionForTileAtLocation:location];
    }
    return NO;
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
    [self updateZIndices];
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
                [self updateZIndices];
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
    return PZTileLocationMake((NSUInteger)(aPoint.x  - CGRectGetMinX([self tilesArea])) / [self tileWidth],
                              (NSUInteger)(aPoint.y  - CGRectGetMinY([self tilesArea])) / [self tileHeight]);
}

- (CGRect)tilesArea
{
    static CGRect result = {};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        result = CGRectMake(12.0, 82.0, 296.0, 296.0);
    });
    return result;
}

- (CGFloat)tileWidth
{
    static CGFloat result = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        result = CGRectGetWidth([self tilesArea]) / kPuzzleSize;
    });
    return result;
}

- (CGFloat)tileHeight
{
    static CGFloat result = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        result = CGRectGetHeight([self tilesArea]) / kPuzzleSize;
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
    return CGRectInset(CGRectMake([self tileWidth] * aLocation.x + CGRectGetMinX([self tilesArea]),
                                  CGRectGetMinY([self tilesArea]) + [self tileHeight] * aLocation.y,
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
        [self.stopWatch stop];
        [self.stopWatch reset];

        [self hideWinMessageIfNecessary];
        [self hideHighscoresMessageIfNecessary];
        
        [self shuffleWithCompletionBlock:^{
            [self.stopWatch start];
            [self showHighscoresButtonIfNecessary];
        }];
        [self updateMoveLabel];
    }
}

- (void)motionCancelled:(UIEventSubtype)aMotion withEvent:(UIEvent *)anEvent
{    
    if (UIEventSubtypeMotionShake == aMotion)
    {
        self.view.userInteractionEnabled = YES;
    }
}

- (void)shuffleWithCompletionBlock:(void (^)(void))aBlock
{
    self.view.userInteractionEnabled = NO;
    [self shufflePuzzleWithNumberOfMoves:kShufflesCount completionBlock:aBlock];
}

- (void)shufflePuzzleWithNumberOfMoves:(NSUInteger)aNumberOfMoves completionBlock:(void (^)(void))aBlock
{
    if (0 == aNumberOfMoves)
    {
        // we done shuffling
        self.view.userInteractionEnabled = YES;
        aBlock();
        return;
    }

    [self.puzzle moveTileToRandomLocationWithCompletionBlock:^(NSArray *aTiles, PZMoveDirection aDirection)
    {
        [CATransaction setAnimationDuration:0.05];
        [CATransaction setCompletionBlock:^
        {
            [self shufflePuzzleWithNumberOfMoves:aNumberOfMoves - 1 completionBlock:aBlock];
        }];
        [self moveLayersOfTiles:aTiles direction:aDirection];
        [self updateZIndices];
    }];
}

#pragma mark -
#pragma mark Time And Moves

- (PZStopWatch *)stopWatch
{
    if (nil == _stopWatch)
    {
        _stopWatch = [PZStopWatch new];
        _stopWatch.delegate = self;
    }
    return _stopWatch;
}

- (void)PZStopWatchDidChangeTime:(PZStopWatch *)aStopWatch
{
    [self updateTimeLabel];
}

- (void)updateMoveLabel
{
    self.movesLabel.text = [PZMessageFormatter movesCountMessage:self.puzzle.movesCount];
}

- (void)updateTimeLabel
{
    self.timeLabel.text = [PZMessageFormatter timeMessage:self.stopWatch.totalSeconds];
}

#pragma mark -
#pragma mark Hightscores

- (IBAction)showHighscores:(id)aSender
{
    if (nil != self.highscoresViewController)
    {
        return;
    }
    
    self.highscoresViewController = [PZHighscoresViewController new];
    
    [self.view addSubview:self.highscoresViewController.view];
    
    // set position
    CGRect frame = self.highscoresViewController.view.frame;
    frame.origin.x = CGRectGetMaxX([aSender frame]);
    frame.origin.y = CGRectGetMaxY([aSender frame]) - CGRectGetHeight(frame);
    self.highscoresViewController.view.frame = frame;

    // make it appear with animation
    self.highscoresViewController.view.alpha = 0.0;
    [UIView animateWithDuration:kTransparencyAnimationDuration animations:^{
         self.highscoresViewController.view.alpha = 1.0;
    }];
}

- (void)hideHighscoresMessageIfNecessary
{
    if (nil == self.highscoresViewController)
    {
        return;
    }
    
    [UIView animateWithDuration:kTransparencyAnimationDuration animations:^ {
        self.highscoresViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.highscoresViewController = nil;
    }];
}

- (void)showHighscoresButtonIfNecessary
{
    if (self.highScoresButton.hidden) {
        self.highScoresButton.hidden = NO;
        self.highScoresButton.alpha = 0.0;
        [UIView animateWithDuration:kTransparencyAnimationDuration animations:^{
            self.highScoresButton.alpha = 1.0;
        }];
    }
}
#pragma mark -
#pragma mark Misc

- (PZPuzzle *)puzzle
{
    if (nil == _puzzle)
    {
        UIImage *wholeImage = [[UIImage alloc] initWithContentsOfFile:self.tilesImageFile];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGRect rect = CGRectMake(CGRectGetMinX([self tilesArea]) * scale,
                                 (CGRectGetMinY([self tilesArea]) + 70.0) * scale,
                                 CGRectGetWidth([self tilesArea]) * scale,
                                 CGRectGetHeight([self tilesArea]) * scale);
        UIImage *tilesImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([wholeImage CGImage],
                                                          rect)];

        NSDictionary *state = [[NSUserDefaults standardUserDefaults] objectForKey:kPuzzleState];
        _puzzle = [[PZPuzzle alloc] initWithImage:tilesImage size:kPuzzleSize state:state];
    }
    return _puzzle;
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
            
            if (kSupportsShadows)
            {
                [tileLayer setupPuzzleShadow];
            }
            [self.layersView.layer addSublayer:tileLayer];
        }
    }
}

- (void)moveTileAtLocation:(PZTileLocation)aLocation
{
    [self.puzzle moveTileAtLocation:aLocation];
    
    [self updateMoveLabel];
    
    if (self.puzzle.isWin)
    {
        [self.stopWatch stop];
        [self showWinMessage];
    }
}

- (void)showWinMessage
{
    self.view.userInteractionEnabled = NO;
    
    self.winViewController = [[PZWinViewController alloc]
                              initWithTime:self.stopWatch.totalSeconds
                              movesCount:self.puzzle.movesCount];
    
    [self.view addSubview:self.winViewController.view];

    self.winViewController.view.alpha = 0.0;
    [UIView animateWithDuration:kTransparencyAnimationDuration animations:^
    {
        self.winViewController.view.alpha = 1.0;
    }];
}

- (void)hideWinMessageIfNecessary
{
    if (nil == self.winViewController)
    {
        return;
    }

    [UIView animateWithDuration:kTransparencyAnimationDuration animations:^ {
         self.winViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.winViewController = nil;
    }];
}

- (void)updateZIndices
{
    if (!kSupportsShadows) {
        return;
    }

    for (NSUInteger y = 0; y < kPuzzleSize; y++)
    {
        for (NSUInteger x = 0; x < kPuzzleSize; x++)
        {
            id<IPZTile> tile = [self.puzzle tileAtLocation:PZTileLocationMake(x, y)];
            CALayer *layer = [tile representedObject];
            [layer removeFromSuperlayer];
            [self.layersView.layer addSublayer:layer];
        }
    }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation CALayer(PZExtentions)

- (void)setupPuzzleShadow
{
    self.shadowOpacity = 0.7;
    self.shadowOffset = CGSizeMake(3.0, 3.0);
    self.shouldRasterize = YES;
    self.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
