//
//  PZViewController.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//

////////////////////////////////////////////////////////////////////////////////
#import "PZViewController.h"
#import "PZWinViewController.h"
#import "PZHighscoresViewController.h"
#import "PZHelpViewController.h"
#import "PZPuzzle.h"
#import "PZTile.h"
#import "PZMessageFormatter.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////
static const BOOL kSupportsShadows = YES;
static const NSUInteger kPuzzleSize = 4;
static const NSUInteger kShufflesCount = 40;

static const CGFloat kAutoMoveAnimationDuration = 0.05;
static const CGFloat kTransparencyAnimationDuration = 0.5;
static const CGFloat kShowHelpAnimationDuration = 0.5;

static const PZTileLocation kAllowedLocationsAll = {-1, -1};
static const PZTileLocation kAllowedLocationsNone = {-2, -2};

static const CGFloat kHelpShift = 70.0;
static const CGFloat kHelpViewShift = 10.0;

static const CGFloat kGuideColor[] = {1.0, 0.82, 0.7, 1.0};

static NSString *const kPuzzleState = @"PZPuzzleStateDefaults";
static NSString *const kElapsedTime = @"PZElapsedTimeDefaults";
static NSString *const kWinController = @"PZWinControllerDefaults";

////////////////////////////////////////////////////////////////////////////////
@interface UIView(PZExtentions)

- (void)setOffscreenLocation;

@end

////////////////////////////////////////////////////////////////////////////////
@interface CALayer(PZExtentions)

- (void)setupPuzzleShadow;

@end

////////////////////////////////////////////////////////////////////////////////
@interface PZViewController ()

@property (nonatomic, strong) PZPuzzle *puzzle;
@property (nonatomic, strong) PZStopWatch *stopWatch;
@property (nonatomic, assign, getter=isGameStarted) BOOL gameStarted; // shuffle at launch only

@property (nonatomic, strong) PZWinViewController *winViewController;
@property (nonatomic, strong) PZHighscoresViewController *highscoresViewController;
@property (nonatomic, strong) PZHelpViewController *helpViewController;

// properties below are helpers for pan gesture
@property (nonatomic, assign) PZTileLocation panTileLocation;
@property (nonatomic, strong) NSArray *pannedTiles;
@property (nonatomic, assign) CGRect panConstraints;

@property (nonatomic, assign, getter=isHelpMode) BOOL helpMode;
@property (nonatomic, assign) PZTileLocation allowedLocations;
typedef void(^PZTileMoveBlock)(void);
@property (nonatomic, strong) PZTileMoveBlock tileMoveBlock;

// tap gesture recognizer
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@end

////////////////////////////////////////////////////////////////////////////////
@implementation PZViewController

- (void)viewDidLoad {
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
    self.allowedLocations = kAllowedLocationsAll;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self
            name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
            name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.tapRecognizer = nil;
    self.panRecognizer = nil;
}

- (void)viewDidAppear:(BOOL)anAnimated {
    // support shakes handling
    [self becomeFirstResponder];
    
    if ([self hasSavedState]) {
        [self updateMoveLabel];
        [self updateTimeLabel];
        if (!self.puzzle.isWin) {
            [self.stopWatch start];
        }
    }
    else if (!self.isGameStarted) {
        // propose tutorial if necessary
        [self showHelp];
        self.gameStarted = YES;
    }
}

- (void)dealloc {
    [self.stopWatch stop];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)aNotification {
    [self saveGameState];
    [self.stopWatch stop];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)aNotification {
    if (!self.puzzle.isWin) {
        [self.stopWatch start];
    }
}

- (PZPuzzle *)puzzle {
    if (nil == _puzzle) {
        UIImage *wholeImage = [[UIImage alloc] initWithContentsOfFile:self.tilesImageFile];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGRect rect = CGRectMake(CGRectGetMinX([self tilesAreaInView]) * scale,
                                 (CGRectGetMinY([self tilesAreaInView]) + kHelpShift) * scale,
                                 CGRectGetWidth([self tilesAreaInView]) * scale,
                                 CGRectGetHeight([self tilesAreaInView]) * scale);
        UIImage *tilesImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([wholeImage CGImage],
                                                                                     rect)];
        
        NSDictionary *state = [[NSUserDefaults standardUserDefaults] objectForKey:kPuzzleState];
        _puzzle = [[PZPuzzle alloc] initWithImage:tilesImage size:kPuzzleSize state:state];
    }
    return _puzzle;
}

#pragma mark -
#pragma mark State

- (BOOL)hasSavedState {
    return nil != [[NSUserDefaults standardUserDefaults] objectForKey:kPuzzleState];
}

- (void)saveGameState {
    if (self.isHelpMode) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.puzzle.state forKey:kPuzzleState];
    [[NSUserDefaults standardUserDefaults] setObject:
            [NSNumber numberWithUnsignedInteger:self.stopWatch.totalSeconds]
            forKey:kElapsedTime];

    [[NSUserDefaults standardUserDefaults]
            setObject:[NSKeyedArchiver archivedDataWithRootObject:self.winViewController]
            forKey:kWinController];
}

- (void)restoreState {
    self.stopWatch.totalSeconds = [[[NSUserDefaults standardUserDefaults]
                                    objectForKey:kElapsedTime] unsignedIntegerValue];
    if (self.puzzle.isWin) {
        // user interaction is enabled on first launch
        self.view.userInteractionEnabled = ![self hasSavedState];
        NSData *controllerData = [[NSUserDefaults standardUserDefaults] objectForKey:kWinController];
        if (nil != controllerData) {
            self.winViewController = [NSKeyedUnarchiver unarchiveObjectWithData:
                    [[NSUserDefaults standardUserDefaults] objectForKey:kWinController]];
            [self.winViewController updateMessages];
            [self.view addSubview:self.winViewController.view];
        }
    }
}

#pragma mark -
#pragma mark Gestures Recognition

- (void)addGestureRecognizers {
    // tap gesture recognizer
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.tapRecognizer];

    // pan gesture recognizer
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)aRecognizer {
    if (PZTileLocationEqualToLocation(kAllowedLocationsNone, self.allowedLocations)) {
        return NO;
    }
    
    [self hideHighscoresMessageIfNecessary];
    
    if (CGRectContainsPoint([self tilesAreaOnScreen], [aRecognizer locationInView:self.view])) {
        PZTileLocation location = [self tileLocationFromGestureRecognizer:aRecognizer];
        if (PZTileLocationEqualToLocation(kAllowedLocationsAll, self.allowedLocations) ||
            PZTileLocationEqualToLocation(location, self.allowedLocations)) {
            return kNoneDirection != [self.puzzle allowedMoveDirectionForTileAtLocation:location];
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)aGestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)anOtherGestureRecognizer {
    return YES;
}

- (void)handleTap:(UIGestureRecognizer *)aRecognizer {
    [self moveLayersAndTilesAtLocation:[self tileLocationFromGestureRecognizer:aRecognizer]];
}

- (void)handlePan:(UIPanGestureRecognizer *)aRecognizer {
    if (UIGestureRecognizerStateBegan == aRecognizer.state ||
        UIGestureRecognizerStateChanged == aRecognizer.state) {
        if (UIGestureRecognizerStateBegan == aRecognizer.state) {
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
             UIGestureRecognizerStateCancelled == aRecognizer.state) {
        if (UIGestureRecognizerStateEnded == aRecognizer.state) {
            // finish move if necessary
            CGRect originalTileRect = [self rectForTileAtLocation:self.panTileLocation];
            CGRect currentTileRect = ((CALayer *)[self.puzzle tileAtLocation:self.panTileLocation].representedObject).frame;
            CGSize distancePassed = CGRectIntersection(originalTileRect, currentTileRect).size;

            // check if halfway is passed
            BOOL halfwayPassed = (distancePassed.width < CGRectGetWidth(originalTileRect) / 2) ||
                                 (distancePassed.height < CGRectGetHeight(originalTileRect) / 2);
            
            if (halfwayPassed) {
                [self updateZIndices];
                [self moveTileAtLocation:self.panTileLocation];
            }
        }
        
        // update tiles and cleanup state
        [self updateTilesLocations:self.pannedTiles];
        self.pannedTiles = nil;
    }
}

- (PZTileLocation)tileLocationFromGestureRecognizer:(UIGestureRecognizer *)aRecognizer {
    return [self tileLocationAtPoint:[aRecognizer locationInView:self.view]];
}

#pragma mark -
#pragma mark Tiles And Layers

- (void)addTilesLayers {
    for (NSUInteger x = 0; x < kPuzzleSize; x++) {
        for (NSUInteger y = 0; y < kPuzzleSize; y++) {
            PZTileLocation tileLocation = PZTileLocationMake(x, y);
            id<IPZTile> tile = [self.puzzle tileAtLocation:tileLocation];
            CALayer *tileLayer = [CALayer new];
            tile.representedObject = tileLayer;
            
            tileLayer.opaque = YES;
            tileLayer.contents = (id)[tile.image CGImage];
            tileLayer.frame = [self rectForTileAtLocation:tileLocation];
            
            if (kSupportsShadows) {
                [tileLayer setupPuzzleShadow];
            }
            [self.layersView.layer addSublayer:tileLayer];
        }
    }
}

- (void)moveLayersOfTiles:(NSArray *)aTiles direction:(PZMoveDirection)aDirection {
    switch (aDirection) {
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

- (void)moveLayersOfTiles:(NSArray *)aTiles offset:(CGPoint)anOffset {
    for (id<IPZTile> tile in aTiles) {
        CALayer *layer = tile.representedObject;
        layer.position = CGPointMake(layer.position.x + anOffset.x,
                                     layer.position.y + anOffset.y);
    }
}

- (void)moveLayersOfTiles:(NSArray *)aTiles offset:(CGPoint)anOffset constraints:(CGRect)aConstraints {
    // first apply constraints
    CGPoint constrainedOffset = anOffset;
    for (id<IPZTile> tile in aTiles) {
        CALayer *layer = tile.representedObject;
        CGRect newLayerFrame = CGRectOffset(layer.frame, constrainedOffset.x, constrainedOffset.y);
        
        // lets check if the new layer frame is out of constraints rect. If so we alter
        // the offset to keep constraints
        if (!CGRectContainsRect(aConstraints, newLayerFrame)) {
            CGRect intersection = CGRectIntersection(newLayerFrame, aConstraints);
            if (CGRectIsEmpty(intersection)) {
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

- (void)moveLayersAndTilesAtLocation:(PZTileLocation)aLocation {
    NSArray *tiles = [self.puzzle affectedTilesByTileMoveAtLocation:aLocation];
    PZMoveDirection direction = [self.puzzle allowedMoveDirectionForTileAtLocation:aLocation];
    [self moveLayersOfTiles:tiles direction:direction];
    [self updateZIndices];
    [self moveTileAtLocation:aLocation];
}

- (void)moveTileAtLocation:(PZTileLocation)aLocation {
    [self.puzzle moveTileAtLocation:aLocation];
    
    [self updateMoveLabel];
    
    if (self.puzzle.isWin && !self.isHelpMode) {
        [self.stopWatch stop];
        [self updateTimeLabel];
        [self showWinMessage];
    }
    
    if (self.tileMoveBlock) {
        __strong PZTileMoveBlock tileMoveBlock = self.tileMoveBlock;
        self.tileMoveBlock = nil;
        tileMoveBlock();
    }
}

- (void)updateTilesLocations:(NSArray *)aTiles {
    for (id<IPZTile>tile in aTiles) {
        CGRect frame = [self rectForTileAtLocation:tile.currentLocation];
        ((CALayer *)tile.representedObject).frame = frame;
    }
}

- (void)updateZIndices {
    if (!kSupportsShadows) {
        return;
    }
    
    for (NSUInteger y = 0; y < kPuzzleSize; y++) {
        for (NSUInteger x = 0; x < kPuzzleSize; x++) {
            id<IPZTile> tile = [self.puzzle tileAtLocation:PZTileLocationMake(x, y)];
            CALayer *layer = [tile representedObject];
            [layer removeFromSuperlayer];
            [self.layersView.layer addSublayer:layer];
        }
    }
}

#pragma mark -
#pragma mark Tiles Info

- (PZTileLocation)tileLocationAtPoint:(CGPoint)aPoint {
    return PZTileLocationMake((NSUInteger)(aPoint.x  - CGRectGetMinX([self tilesAreaOnScreen])) / [self tileWidth],
                              (NSUInteger)(aPoint.y  - CGRectGetMinY([self tilesAreaOnScreen])) / [self tileHeight]);
}

- (CGRect)tilesAreaOnScreen {
    CGRect result = [self tilesAreaInView];
    return self.isHelpMode ? CGRectOffset(result, 0.0, kHelpShift) : result;
}

- (CGRect)tilesAreaInView {
    static CGRect result = {};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = CGRectMake(12.0, 82.0, 296.0, 296.0);
    });
    return result;
}

- (CGFloat)tileWidth {
    static CGFloat result = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = CGRectGetWidth([self tilesAreaInView]) / kPuzzleSize;
    });
    return result;
}

- (CGFloat)tileHeight {
    static CGFloat result = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = CGRectGetHeight([self tilesAreaInView]) / kPuzzleSize;
    });
    return result;
}

- (CGRect)rectForTilesAtLocations:(NSArray *)aTilesLocations {
    CGRect result = CGRectZero;
    for (NSValue *location in aTilesLocations) {
        PZTileLocation tileLocation = [location tileLocation];
        CGRect rect = [self rectForTileAtLocation:tileLocation];
        result = CGRectEqualToRect(result, CGRectZero) ? rect : CGRectUnion(result, rect);
    }
    return result;
}

- (CGRect)rectForTileAtLocation:(PZTileLocation)aLocation {
    // we allow 1.0 inset for border
    return CGRectInset(CGRectMake([self tileWidth] * aLocation.x + CGRectGetMinX([self tilesAreaInView]),
                                  CGRectGetMinY([self tilesAreaInView]) + [self tileHeight] * aLocation.y,
                                  [self tileWidth], [self tileHeight]), 1.0, 1.0);
}

#pragma mark -
#pragma mark Shuffle

- (void)motionBegan:(UIEventSubtype)aMotion withEvent:(UIEvent *)anEvent {
    
}

- (void)motionEnded:(UIEventSubtype)aMotion withEvent:(UIEvent *)anEvent {
    if (UIEventSubtypeMotionShake == aMotion) {
        if (self.isHelpMode) {
            [self hideHelpWithCompletionBlock:^{
                [self shuffle];
            }];
        }
        else {
            [self shuffle];
        }
    }
}

- (void)motionCancelled:(UIEventSubtype)aMotion withEvent:(UIEvent *)anEvent {
    if (UIEventSubtypeMotionShake == aMotion) {
        self.view.userInteractionEnabled = YES;
    }
}

- (void)shuffle {
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

- (void)shuffleWithCompletionBlock:(void (^)(void))aBlock {
    self.view.userInteractionEnabled = NO;
    [self shufflePuzzleWithNumberOfMoves:kShufflesCount completionBlock:aBlock];
}

- (void)shufflePuzzleWithNumberOfMoves:(NSUInteger)aNumberOfMoves completionBlock:(void (^)(void))aBlock {
    if (0 == aNumberOfMoves) {
        // we done shuffling
        self.view.userInteractionEnabled = YES;
        aBlock();
        return;
    }

    [self.puzzle moveTileToRandomLocationWithCompletionBlock:^(NSArray *aTiles, PZMoveDirection aDirection) {
        [CATransaction setAnimationDuration:kAutoMoveAnimationDuration];
        [CATransaction setCompletionBlock:^{
            [self shufflePuzzleWithNumberOfMoves:aNumberOfMoves - 1 completionBlock:aBlock];
        }];
        [self moveLayersOfTiles:aTiles direction:aDirection];
        [self updateZIndices];
    }];
}

#pragma mark -
#pragma mark Time And Moves Labels

- (PZStopWatch *)stopWatch {
    if (nil == _stopWatch) {
        _stopWatch = [PZStopWatch new];
        _stopWatch.delegate = self;
    }
    return _stopWatch;
}

- (void)PZStopWatchDidChangeTime:(PZStopWatch *)aStopWatch {
    [self updateTimeLabel];
}

- (void)updateMoveLabel {
    self.movesLabel.text = [PZMessageFormatter movesCountMessage:self.puzzle.movesCount];
}

- (void)updateTimeLabel {
    self.timeLabel.text = [PZMessageFormatter timeMessage:self.stopWatch.totalSeconds];
}

#pragma mark -
#pragma mark Help

- (IBAction)showHelp:(UIButton *)aSender {
    [self hideHighscoresMessageIfNecessary];
    [self saveGameState];
    [self showHelp];
}

- (void)showHelp {
    // prepare help view
    self.helpViewController = [PZHelpViewController new];
    self.helpViewController.delegate = self;
    UIView *helpView = self.helpViewController.view;
    [self.view addSubview:helpView];
    CGPoint destination = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds),
                                      CGRectGetMidY(helpView.frame) + kHelpViewShift);
    [helpView setOffscreenLocation];
    
    // animate UI
    [UIView animateWithDuration:kShowHelpAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
        for (UIView *view in self.view.subviews) {
            // keep fake navigation bar in place to have tinted status bar
            if (![view isKindOfClass:[UINavigationBar class]]) {
                view.center = CGPointMake(view.center.x, view.center.y + kHelpShift);
            }
        }
        
        // put help view in place
        helpView.center = destination;
        helpView.transform = CGAffineTransformIdentity;
    }
    completion:^(BOOL finished) {
        self.helpMode = YES;
        self.allowedLocations = kAllowedLocationsNone;
    }];
}

- (void)helpViewControllerWantsHide:(PZHelpViewController *)aController
{
    [self hideHelpWithCompletionBlock:^{
        if (self.puzzle.isWin) {
            [self shuffleWithCompletionBlock:^{
                [self.stopWatch start];
                [self updateMoveLabel];
            }];
        }
    }];
}

- (void)helpViewControllerSolvePuzzle:(PZHelpViewController *)aController
                      completionBlock:(void(^)(void))aSolveCompletionBlock {

    [self resignFirstResponder]; // disable shake handling

    [self.puzzle solveInstantly];
    [UIView animateWithDuration:kAutoMoveAnimationDuration animations:^{
        [self updateTilesLocations:[self.puzzle allTiles]];
    } completion:^(BOOL finished) {
        aSolveCompletionBlock();
    }];
}

- (void)helpViewControllerShuflePuzzle:(PZHelpViewController *)aController
                       completionBlock:(void(^)(void))aBlock {
    [CATransaction setAnimationDuration:0.13];
    [CATransaction setCompletionBlock:^{
        [CATransaction setAnimationDuration:0.13];
        [CATransaction setCompletionBlock:^{
            [CATransaction setAnimationDuration:0.13];
            [CATransaction setCompletionBlock:^{
                aBlock();
            }];
            [self moveLayersAndTilesAtLocation:PZTileLocationMake(2, 1)];
        }];
        [self moveLayersAndTilesAtLocation:PZTileLocationMake(2, 0)];
    }];
    [self moveLayersAndTilesAtLocation:PZTileLocationMake(3, 0)];
}

- (void)helpViewControllerLearnTap:(PZHelpViewController *)aController
                   completionBlock:(void(^)(void))aBlock {
    self.allowedLocations = PZTileLocationMake(2, 0);
    CALayer *guide = [self newTapGuideLayerForRect:[self rectForTileAtLocation:self.allowedLocations]];
    [self.layersView.layer addSublayer:guide];
    self.panRecognizer.enabled = NO;
    self.tileMoveBlock = ^{
        [guide removeFromSuperlayer];
        aBlock();
    };
}

- (void)helpViewControllerLearnPan:(PZHelpViewController *)aController
                   completionBlock:(void(^)(void))aBlock {
    self.allowedLocations = PZTileLocationMake(3, 0);
    NSArray *guides = [self newPanGuideLayersForRect:[self rectForTileAtLocation:self.allowedLocations]];
    for (CALayer *guide in guides) {
        [self.layersView.layer addSublayer:guide];
    }
    
    self.panRecognizer.enabled = YES;
    self.tapRecognizer.enabled = NO;
    self.tileMoveBlock = ^{
        [guides makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        aBlock();
    };
}

- (void)helpViewControllerLearnMoveAll:(PZHelpViewController *)aController
                       completionBlock:(void(^)(void))aBlock {
    __weak id weakSelf = self;
    
    self.allowedLocations = PZTileLocationMake(3, 3);
    CALayer *guide = [self newTapGuideLayerForRect:[self rectForTileAtLocation:self.allowedLocations]];
    [self.layersView.layer addSublayer:guide];
    self.tapRecognizer.enabled = YES;
    self.tileMoveBlock = ^{
        [guide removeFromSuperlayer];
        aBlock();
        [weakSelf becomeFirstResponder]; // enable shake handling
    };
}

- (void)hideHelpWithCompletionBlock:(void(^)(void))aCompletionBlock {
    [UIView animateWithDuration:kShowHelpAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [self.helpViewController.view setOffscreenLocation];
        
        for (UIView *view in self.view.subviews) {
            // keep fake navigation bar in place to have tinted status bar
            if (view != self.helpViewController.view && ![view isKindOfClass:[UINavigationBar class]]) {
                view.center = CGPointMake(view.center.x, view.center.y - kHelpShift);
            }
        }
        self.allowedLocations = kAllowedLocationsAll;
    } completion:^(BOOL finished) {
        [self.helpViewController.view removeFromSuperview];
        self.helpViewController = nil;
        self.helpMode = NO;
        self.helpButton.userInteractionEnabled = YES;
        if (NULL != aCompletionBlock) {
            aCompletionBlock();
        }
    }];
}

- (CALayer *)newTapGuideLayerForRect:(CGRect)aRect {
    CGPoint center = CGPointMake(CGRectGetWidth(aRect) / 2, CGRectGetHeight(aRect) / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:10.0
                                                    startAngle:0 endAngle:M_PI * 2
                                                     clockwise:YES];

    CGColorRef color = CGColorCreate(CGColorSpaceCreateDeviceRGB(), kGuideColor);
    
    CAShapeLayer *guide = [CAShapeLayer new];
    guide.frame = aRect;
    guide.path = CGPathCreateCopy([path CGPath]);
    guide.strokeColor = color;
    guide.fillColor = NULL;
    
    // scaling animation
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 2.0;
    scale.removedOnCompletion = NO;
    scale.repeatCount = HUGE_VALF;
    scale.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    scale.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3.0, 3.0, 1.0)];
    scale.fillMode = kCAFillModeForwards;
    [guide addAnimation:scale forKey:@"transform.scale"];
    
    // fading animation
    CABasicAnimation *hide = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    hide.duration = 1.0;
    hide.removedOnCompletion = NO;
    hide.repeatCount = HUGE_VALF;
    hide.fromValue = (__bridge id)([[UIColor clearColor] CGColor]);
    hide.toValue = (__bridge id)color;
    hide.fillMode = kCAFillModeForwards;
    hide.autoreverses = YES;
    [guide addAnimation:hide forKey:@"strokeColor"];
    
    return guide;
}

- (NSArray *)newPanGuideLayersForRect:(CGRect)aRect {
    
    // create arrow head
    UIBezierPath *headPath = [UIBezierPath new];
    static const CGFloat kArrowMargin = 10.0;
    [headPath moveToPoint:CGPointMake(CGRectGetWidth(aRect) / 2, CGRectGetHeight(aRect) / 3)];
    [headPath addLineToPoint:CGPointMake(CGRectGetWidth(aRect) / 2, kArrowMargin)];
    [headPath addLineToPoint:CGPointMake(kArrowMargin, CGRectGetHeight(aRect) / 2)];
    [headPath addLineToPoint:CGPointMake(CGRectGetWidth(aRect) / 2, CGRectGetHeight(aRect) - kArrowMargin)];
    [headPath addLineToPoint:CGPointMake(CGRectGetWidth(aRect) / 2, CGRectGetHeight(aRect) * 2 / 3)];
    
    CGColorRef color = CGColorCreate(CGColorSpaceCreateDeviceRGB(), kGuideColor);

    CAShapeLayer *head = [CAShapeLayer new];
    head.frame = aRect;
    head.path = CGPathCreateCopy([headPath CGPath]);
    head.strokeColor = color;
    head.fillColor = NULL;
    
    // moving animation
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    move.duration = 2.0;
    move.removedOnCompletion = NO;
    move.repeatCount = HUGE_VALF;
    move.fromValue = [NSValue valueWithCGPoint:head.position];
    move.toValue = [NSValue valueWithCGPoint:CGPointMake(head.position.x - CGRectGetWidth(aRect), head.position.y)];
    move.fillMode = kCAFillModeForwards;
    [head addAnimation:move forKey:@"position"];

    // fading animation
    CABasicAnimation *hide = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    hide.duration = 1.0;
    hide.removedOnCompletion = NO;
    hide.repeatCount = HUGE_VALF;
    hide.fromValue = (__bridge id)([[UIColor clearColor] CGColor]);
    hide.toValue = (__bridge id)color;
    hide.fillMode = kCAFillModeForwards;
    hide.autoreverses = YES;
    [head addAnimation:hide forKey:@"strokeColor"];

    // create arrow body
    UIBezierPath *bodyPath = [UIBezierPath new];
    [bodyPath moveToPoint:CGPointMake(CGRectGetWidth(aRect) - kArrowMargin, CGRectGetHeight(aRect) / 3)];
    [bodyPath addLineToPoint:CGPointMake(CGRectGetWidth(aRect) / 2, CGRectGetHeight(aRect) / 3)];

    [bodyPath moveToPoint:CGPointMake(CGRectGetWidth(aRect) - kArrowMargin, CGRectGetHeight(aRect) * 2 / 3)];
    [bodyPath addLineToPoint:CGPointMake(CGRectGetWidth(aRect) / 2, CGRectGetHeight(aRect) * 2 / 3)];
    
    CAShapeLayer *body = [CAShapeLayer new];
    body.frame = aRect;
    body.path = CGPathCreateCopy([bodyPath CGPath]);
    body.strokeColor = color;
    body.fillColor = NULL;
    
    // streatching animation
    CABasicAnimation *stretch = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    stretch.duration = 2.0;
    stretch.removedOnCompletion = NO;
    stretch.repeatCount = HUGE_VALF;
    stretch.fromValue = @0.0;
    stretch.toValue = @-2.77;
    stretch.fillMode = kCAFillModeForwards;
    [body addAnimation:stretch forKey:@"transform.scale.x"];

    // fading animation
    [body addAnimation:hide forKey:@"strokeColor"];

    return @[head, body];
}

#pragma mark -
#pragma mark Hightscores

- (IBAction)showHighscores:(UIButton *)aSender {
    if (nil != self.highscoresViewController) {
        return;
    }
    
    self.highscoresViewController = [PZHighscoresViewController new];
    
    [self.view addSubview:self.highscoresViewController.view];
    
    // set position
    CGRect frame = self.highscoresViewController.view.frame;
    frame.origin.x = CGRectGetMaxX([aSender frame]);
    frame.origin.y = CGRectGetMidY([aSender frame]) - CGRectGetMidY(frame);
    self.highscoresViewController.view.frame = frame;

    // make it appear with animation
    self.highscoresViewController.view.alpha = 0.0;
    [UIView animateWithDuration:kTransparencyAnimationDuration animations:^{
         self.highscoresViewController.view.alpha = 1.0;
    }];
}

- (void)hideHighscoresMessageIfNecessary {
    if (nil == self.highscoresViewController) {
        return;
    }
    
    [UIView animateWithDuration:kTransparencyAnimationDuration animations:^ {
        self.highscoresViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.highscoresViewController.view removeFromSuperview];
        self.highscoresViewController = nil;
    }];
}

- (void)showHighscoresButtonIfNecessary {
    if (self.highScoresButton.hidden && [PZHighscoresViewController canShowHighscores]) {
        self.highScoresButton.hidden = NO;
        self.highScoresButton.alpha = 0.0;
        [UIView animateWithDuration:kTransparencyAnimationDuration animations:^{
            self.highScoresButton.alpha = 1.0;
        }];
    }
}

#pragma mark -
#pragma mark Win

- (void)showWinMessage {
    self.view.userInteractionEnabled = NO;
    
    // create view and add it to hierarchy offscreen
    self.winViewController = [[PZWinViewController alloc]
                              initWithTime:self.stopWatch.totalSeconds
                              movesCount:self.puzzle.movesCount];
    
    UIView *view = self.winViewController.view;
    CGPoint screenCenter = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds),
                                       CGRectGetMidY([UIScreen mainScreen].bounds));
    view.center = CGPointMake(-CGRectGetWidth(view.frame) / 2, screenCenter.y);
    [self.view addSubview:view];
    
    // play 2 staged sliding animation
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.center = CGPointMake(screenCenter.x + 20.0, screenCenter.y);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            view.center = screenCenter;
        } completion:^(BOOL finished) {
            // play win message content animation
            [self.winViewController startAnimation];
        }];
    }];
}

- (void)hideWinMessageIfNecessary {
    if (nil == self.winViewController) {
        return;
    }
    
    UIView *view = self.winViewController.view;
    [UIView animateWithDuration:kTransparencyAnimationDuration animations:^{
        view.center = CGPointMake(-CGRectGetWidth(view.frame) / 2,
                                  CGRectGetMidY([UIScreen mainScreen].bounds));
        
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        self.winViewController = nil;
    }];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation UIView(PZExtentions)

- (void)setOffscreenLocation {
    self.center = CGPointMake(-120.0, -100.0);
    self.transform = CGAffineTransformMakeRotation(M_PI_4 / 2);
}

@end
     
//////////////////////////////////////////////////////////////////////////////////////////
@implementation CALayer(PZExtentions)

- (void)setupPuzzleShadow {
    self.shadowOpacity = 0.7;
    self.shadowOffset = CGSizeMake(3.0, 3.0);
    self.shouldRasterize = YES;
    self.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
