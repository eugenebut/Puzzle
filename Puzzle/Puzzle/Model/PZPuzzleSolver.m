//
//  PZPuzzle+Solver.m
//  Puzzle
//
//  Created by Eugene But on 10/12/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZPuzzleSolver.h"
#import "NSMutableArray+BinaryHeap.h"
#import "PZTile.h"

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZPuzzleNode: NSObject {
    enum { kTilesCount = 16 };
    char tiles[kTilesCount];
}
- (id)initWithPuzzle:(PZPuzzle *)aPuzzle;

@property (nonatomic, readonly) NSArray *neighbours;
@property (nonatomic, readonly, getter=isWin) BOOL win;
@property (nonatomic, readwrite, strong) PZPuzzleNode *previousNode;
@property (nonatomic, readwrite) unsigned char manhatten;
@property (nonatomic, readwrite) char emptyTile;
@property (nonatomic, readwrite) NSUInteger move;

- (NSComparisonResult)compare:(PZPuzzleNode *)aNode;
- (BOOL)equalBoards:(PZPuzzleNode *)aNode;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzle (Solver)

- (NSArray *)solvePuzzle:(PZPuzzle *)aPuzzle withChangeBlock:(void (^)(NSArray *aTiles, PZMoveDirection aDirection))aBlock {
    
    NSComparisonResult (^Comparator)(id obj1, id obj2) = ^(id obj1, id obj2){
        return [obj1 compare:obj2];
    };

    // enque initial board
    NSMutableArray *queue = [NSMutableArray new];
    [queue binaryHeapPushObject:[[PZPuzzleNode alloc] initWithPuzzle:aPuzzle] comparator:Comparator];
    
    while (0 < queue.count) {
        PZPuzzleNode *node = [queue binaryHeapPopMaxObjectWithComparator:Comparator];
        
        if (node.isWin) {
            // we have a solution, 
            NSMutableArray *solution = [NSMutableArray new];
            while (nil != node) {
                [solution addObject:node];
                node = node.previousNode;
            }
            
            [self applySolution:solution withChangeBlock:aBlock];
            return [NSArray arrayWithArray:solution];
        }
        
        // enqueue neighbours
        for (PZPuzzleNode *neighbour in node.neighbours) {
            if (nil == node.previousNode || ![neighbour equalBoards:node.previousNode]) {
                [queue binaryHeapPushObject:neighbour comparator:Comparator];
            }
        }
    }
    return nil;
}

- (void)applySolution:(NSArray *)aSolution withChangeBlock:(void (^)(NSArray *aTiles, PZMoveDirection aDirection))aBlock {
    __block __weak PZPuzzleNode *previousNode = nil;
    [aSolution enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PZPuzzleNode *aNode, NSUInteger anIndex, BOOL *aStop) {
        if (aSolution.count - 1 != anIndex) {
        
            PZTileLocation location = PZTileLocationMake(aNode.emptyTile % kTilesCount,
                                                         aNode.emptyTile / kTilesCount);
            [self moveTileAtLocation:location];
            aBlock([self affectedTilesByTileMoveAtLocation:location],
                   [self allowedMoveDirectionForTileAtLocation:location]);
        }
        previousNode = aNode;
    }];
}
    
@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzleNode

- (id)initWithPuzzle:(PZPuzzle *)aPuzzle {
    self = [super init];
    if (nil != self) {
        self.previousNode = nil;
        self.emptyTile = [self indexOfTileAtLocation:aPuzzle.emptyTileLocation];
        
        [[aPuzzle allTiles] enumerateObjectsUsingBlock:^(id<IPZTile> aTile, NSUInteger anIndex, BOOL *aStop) {
            self->tiles[anIndex] = [self indexOfTileAtLocation:aTile.winLocation];
        }];
        
        self.move = 0;
        
        [self calculateManhatten];
    }
    return self;
}

- (id)initWithPreviousNode:(PZPuzzleNode *)aNode emptyTile:(char)anEmptyTile {
    self = [super init];
    if (nil != self) {
        self.previousNode = aNode;
        self.emptyTile = anEmptyTile;
        self->tiles[aNode.emptyTile] = self->tiles[anEmptyTile];
        self->tiles[anEmptyTile] = 0;
        self.move = aNode.move + 1;
        
        [self calculateManhatten];
    }
    return self;
}

- (NSArray *)neighbours {
    NSMutableArray *result = [NSMutableArray new];

    char emptyX = self.emptyTile % kTilesCount;
    char emptyY = self.emptyTile / kTilesCount;

    if (0 < emptyX) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:emptyX + emptyY * kTilesCount - 1]];
    }

    if (emptyX < kTilesCount - 1) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:emptyX + emptyY * kTilesCount + 1]];
    }

    if (emptyY < kTilesCount - 1) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:emptyX + emptyY * kTilesCount + kTilesCount]];
    }

    if (0 < emptyY) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:emptyX + emptyY * kTilesCount - kTilesCount]];
    }

    return result;
}

- (BOOL)isWin {
    return 0 == self.manhatten;
}

- (NSComparisonResult)compare:(PZPuzzleNode *)aNode {
    return [[NSNumber numberWithUnsignedInteger:self.manhatten + self.move] compare:
            [NSNumber numberWithUnsignedInteger:aNode.manhatten + aNode.move]];
}

- (BOOL)equalBoards:(PZPuzzleNode *)aNode {
    for (size_t i = 0; i < kTilesCount; ++i) {
        if (self->tiles[i] != aNode->tiles[i]) {
            return NO;
        }
    }
    return YES;
}

- (void)calculateManhatten {
    self.manhatten = 0;
    for (int x = 0; x < kTilesCount; x++) {
        for (int y = 0; y < kTilesCount; y++) {
            int number = tiles[x + y * kTilesCount];
            if (0 != number) {
                int value = abs(x - ((number - 1) % kTilesCount)) + abs(y - ((number - 1) / kTilesCount));
                self.manhatten += value;
            }
        }
    }
}

- (char)indexOfTileAtLocation:(PZTileLocation)aLocation {
    return aLocation.y * kTilesCount + aLocation.x;
}

@end
