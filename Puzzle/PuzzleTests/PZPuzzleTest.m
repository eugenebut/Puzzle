//
//  PuzzleTests.m
//  PuzzleTests

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZPuzzleTest.h"
#import "PZPuzzle.h"
#import "PZTile.h"

//////////////////////////////////////////////////////////////////////////////////////////
static const NSUInteger kPuzzleSize = 4;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PuzzleTests ()

@property (nonatomic, strong) PZPuzzle *testable;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PuzzleTests
@synthesize testable;

- (void)setUp {
    [super setUp];
    self.testable = [[PZPuzzle alloc] initWithImage:[UIImage imageNamed:@"puzzle_iPhone"] size:kPuzzleSize state:nil];
}

- (void)tearDown {
    self.testable = nil;
    [super tearDown];
}

- (void)testInitialState {    
    STAssertEquals(kPuzzleSize, self.testable.size, @"");
    STAssertTrue(PZTileLocationEqualToLocation(PZTileLocationMake(3, 3),
                                               self.testable.emptyTileLocation),
                                               @"");
    STAssertEquals((NSUInteger)0, self.testable.movesCount, @"No turns were made yet");
    STAssertTrue(self.testable.isWin, @"By default we win");
    STAssertNil([self.testable tileAtLocation:self.testable.emptyTileLocation], @"");
    STAssertNotNil([self.testable tileAtLocation:PZTileLocationMake(0, 0)].image, @"");
    
    // -[PZPuzzle allowedMoveDirectionForTileAtLocation:]
    STAssertEquals(kNoneDirection, [self.testable allowedMoveDirectionForTileAtLocation:testable.emptyTileLocation], @"");
    STAssertEquals(kNoneDirection, [self.testable allowedMoveDirectionForTileAtLocation:PZTileLocationMake(0, 0)], @"");
    STAssertEquals(kDownDirection, [self.testable allowedMoveDirectionForTileAtLocation:PZTileLocationMake(3, 0)], @"");
    STAssertEquals(kRightDirection, [self.testable allowedMoveDirectionForTileAtLocation:PZTileLocationMake(1, 3)], @"");
}

- (void)testDescription {
    STAssertEqualObjects([self.testable description], @"\n"
                                                       "01 02 03 04\n"
                                                       "05 06 07 08\n"
                                                       "09 10 11 12\n"
                                                       "13 14 15 --\n"
                                                       "\nempty tile: 3-3\n", @"");
}

- (void)testBulkTilesAccess {
    NSValue *emptyLocation = [[NSValue alloc] initWithTileLocation:self.testable.emptyTileLocation];
    NSArray *tiles = [self.testable tilesAtLocations:[NSArray arrayWithObject:emptyLocation]];
    STAssertTrue(1 == tiles.count, @"");
    STAssertTrue([[tiles lastObject] isKindOfClass:[NSNull class]], @"");
}

- (void)testMoving {
    // remember our vertical line
    NSArray *verticalTiles = [self.testable tilesAtLocations:[NSArray arrayWithObjects:
            [[NSValue alloc] initWithTileLocation:PZTileLocationMake(3, 0)],
            [[NSValue alloc] initWithTileLocation:PZTileLocationMake(3, 1)],
            [[NSValue alloc] initWithTileLocation:PZTileLocationMake(3, 2)], nil]];

    PZTileLocation moveLocation = PZTileLocationMake(3, 0);
    STAssertEqualObjects(verticalTiles, [self.testable affectedTilesByTileMoveAtLocation:moveLocation], @"");
    
    // perform move
    [self.testable moveTileAtLocation:moveLocation];
    
    // verify puzzle
    STAssertFalse(self.testable.isWin, @"");
    STAssertEquals(moveLocation, self.testable.emptyTileLocation, @"");

    NSArray *newVerticalTiles = [self.testable tilesAtLocations:[NSArray arrayWithObjects:
            [[NSValue alloc] initWithTileLocation:PZTileLocationMake(3, 1)],
            [[NSValue alloc] initWithTileLocation:PZTileLocationMake(3, 2)],
            [[NSValue alloc] initWithTileLocation:PZTileLocationMake(3, 3)], nil]];

    STAssertEqualObjects(verticalTiles, newVerticalTiles, @"");
}

- (void)testRandomizing {
    // at least we should not be in win state
    [self.testable moveTileToRandomLocationWithCompletionBlock:^(NSArray *aTiles, PZMoveDirection aDirection) {}];
    STAssertFalse(self.testable.isWin, @"");
}

@end
