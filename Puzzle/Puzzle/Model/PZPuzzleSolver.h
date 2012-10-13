//
//  PZPuzzle+Solver.h
//  Puzzle
//
//  Created by Eugene But on 10/12/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZPuzzle.h"

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZPuzzle (Solver)

- (NSArray *)solution;

typedef void (^ChangeCompletion)(void);

- (void)applySolution:(NSArray *)solution changeBlock:(void (^)(NSArray *aTiles,
                                                                PZMoveDirection aDirection,
                                                                ChangeCompletion aCompletion))aBlock;

@end
