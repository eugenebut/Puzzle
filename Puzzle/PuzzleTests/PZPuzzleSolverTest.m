//
//  PZPuzzleSolverTest.m
//  Puzzle
//
//  Created by Eugene But on 10/12/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZPuzzleSolverTest.h"
#import "PZPuzzle.h"
#import "PZPuzzleSolver.h"

//////////////////////////////////////////////////////////////////////////////////////////
static const NSUInteger kPuzzleSize = 4;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZPuzzleSolverTest()

@property (nonatomic, strong) PZPuzzle *testable;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzleSolverTest

- (void)setUp {
    [super setUp];
    self.testable = [[PZPuzzle alloc] initWithImage:[UIImage imageNamed:@"puzzle_iPhone"] size:kPuzzleSize state:nil];
}

- (void)tearDown {
    self.testable = nil;
    [super tearDown];
}

- (void)testSolver {
    
    // randomize puzzle
    NSUInteger shufflesCount = 30;
    while (shufflesCount--) {
        [self.testable moveTileToRandomLocationWithCompletionBlock:NULL];
    }
    STAssertFalse(self.testable.isWin, @"");

    // solve it
    NSArray *solution = [self.testable solution];
    [self.testable applySolution:solution changeBlock:^(NSArray *aTiles, PZMoveDirection aDirection, ChangeCompletion aCompletion) {
        aCompletion();
    }];
    STAssertTrue(self.testable.isWin, @"");
}

@end
