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
    enum {
        kPuzzleSize = 4,
        kTilesCount = kPuzzleSize * kPuzzleSize
    };
    char tiles[kTilesCount];
}
- (id)initWithPuzzle:(PZPuzzle *)aPuzzle;

@property (nonatomic, readonly) NSArray *neighbours;
@property (nonatomic, readwrite, strong) PZPuzzleNode *previousNode;
@property (nonatomic, readwrite) unsigned char manhatten;
@property (nonatomic, readwrite) NSUInteger weight;
@property (nonatomic, readwrite) char emptyTile;
@property (nonatomic, readwrite) NSUInteger move;

- (BOOL)equalBoards:(PZPuzzleNode *)aNode;

@end

NSComparisonResult Comparator(id obj1, id obj2) {
    if ([obj1 weight] < [obj2 weight]) {
        return NSOrderedDescending;
    }
    else if ([obj2 weight] < [obj1 weight]) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzle (Solver)

- (NSArray *)solution {
    
    // enque initial board
    NSMutableArray *queue = [NSMutableArray new];
    
    PZPuzzleNode *node = [[PZPuzzleNode alloc] initWithPuzzle:self];
    [queue binaryHeapPushObject:node function:Comparator];
    NSHashTable *set = [NSHashTable new];
    //NSLog(@"Initial manhatten: %d", node.manhatten);

    while (0 < queue.count) {
        PZPuzzleNode *node = [queue binaryHeapPopMaxObjectWithFunction:Comparator];
        //NSLog(@"Weight: %d", node.weight);
        
        if (0 == node.manhatten) {
            // we have a solution, 
            NSMutableArray *solution = [NSMutableArray new];
            while (nil != node) {
                [solution addObject:node];
                node = node.previousNode;
            }
            //NSLog(@"Queue len: %d", queue.count);
            [solution removeLastObject]; // remove sentinel
            //NSLog(@"Final set: %@", set);
            return [NSArray arrayWithArray:solution];
        }

        // enqueue neighbours
        for (PZPuzzleNode *neighbour in node.neighbours) {
            if (![neighbour equalBoards:node.previousNode] && ![set containsObject:neighbour]) {
                [set addObject:neighbour];
                [queue binaryHeapPushObject:neighbour function:Comparator];
            }
        }
    }
    return nil;
}

- (void)applySolution:(NSArray *)solution changeBlock:(void (^)(NSArray *aTiles,
                                                                PZMoveDirection aDirection,
                                                                ChangeCompletion aCompletion))aBlock
{
    [self applySolution:solution index:solution.count - 2 changeBlock:aBlock];

}

- (void)applySolution:(NSArray *)solution
                index:(NSUInteger)anIndex
          changeBlock:(void (^)(NSArray *aTiles, PZMoveDirection aDirection, ChangeCompletion aCompletion))aBlock
{
    if (solution.count <= anIndex) {
        return;
    }
    
    PZPuzzleNode *node = [solution objectAtIndex:anIndex];
    PZTileLocation location = PZTileLocationMake(node.emptyTile % kPuzzleSize,
                                                 node.emptyTile / kPuzzleSize);
    
    // remember tiles and direction to pass them to block
    NSArray *tiles = [self affectedTilesByTileMoveAtLocation:location];
    PZMoveDirection direction = [self allowedMoveDirectionForTileAtLocation:location];

    [self moveTileAtLocation:location];
    
    aBlock(tiles, direction, ^{
        [self applySolution:solution index:anIndex - 1 changeBlock:aBlock];
    });
}
    
@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzleNode

- (id)initWithPuzzle:(PZPuzzle *)aPuzzle {
    self = [super init];
    if (nil != self) {
        self.previousNode = [[[self class] alloc] initSentinel];
        self.emptyTile = [self indexOfTileAtLocation:aPuzzle.emptyTileLocation];
        
        [[aPuzzle allTiles] enumerateObjectsUsingBlock:^(id<IPZTile> aTile, NSUInteger anIndex, BOOL *aStop) {
            self->tiles[anIndex] = [self indexOfTileAtLocation:aTile.winLocation];
        }];
        
        self.move = 0;
        
        [self calculateManhatten];
        
        self.weight = self.manhatten;
    }
    return self;
}

- (id)initSentinel {
    self = [super init];
    self.emptyTile = 100;
    if (nil != self) {
        memset(self->tiles, 0x00, sizeof(self->tiles));
    }
    return self;
}

- (id)initWithPreviousNode:(PZPuzzleNode *)aNode emptyTile:(char)anEmptyTile {
    self = [super init];
    if (nil != self) {
        self.previousNode = aNode;
        self.emptyTile = anEmptyTile;
        memmove(self->tiles, aNode->tiles, sizeof(aNode->tiles));
        self->tiles[aNode.emptyTile] = self->tiles[anEmptyTile];
        self->tiles[anEmptyTile] = kTilesCount - 1;
        self.move = aNode.move + 1;
        
        [self calculateManhatten];

        self.weight = self.move + self.manhatten;
    }
    return self;
}

- (NSArray *)neighbours {
    NSMutableArray *result = [NSMutableArray new];

    char emptyX = self.emptyTile % kPuzzleSize;
    char emptyY = self.emptyTile / kPuzzleSize;

    if (0 < emptyX) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:self.emptyTile - 1]];
    }

    if (emptyX < kPuzzleSize - 1) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:self.emptyTile + 1]];
    }

    if (emptyY < kPuzzleSize - 1) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:self.emptyTile + kPuzzleSize]];
    }

    if (0 < emptyY) {
        [result addObject:[[PZPuzzleNode alloc] initWithPreviousNode:self emptyTile:self.emptyTile - kPuzzleSize]];
    }

    return result;
}

- (BOOL)equalBoards:(PZPuzzleNode *)aNode {
    if (self.emptyTile != aNode.emptyTile) {
        return NO;
    }
    
    for (size_t i = 0; i < kTilesCount; ++i) {
        if (self->tiles[i] != aNode->tiles[i]) {
            return NO;
        }
    }
    return YES;
}

- (void)calculateManhatten {
    self.manhatten = 0;
    for (int x = 0; x < kPuzzleSize; x++) {
        for (int y = 0; y < kPuzzleSize; y++) {
            int number = tiles[x + y * kPuzzleSize];
            if ((kTilesCount - 1) != number) {
                int value = abs(x - (number % kPuzzleSize)) + abs(y - (number / kPuzzleSize));
                self.manhatten += value;
            }
        }
    }
}

- (char)indexOfTileAtLocation:(PZTileLocation)aLocation {
    return aLocation.y * kPuzzleSize + aLocation.x;
}

- (NSString *)description {
    
    NSMutableString *result = [NSMutableString new];

    [result appendString:@"\n"];

    for (size_t i = 0; i < kTilesCount; ++i) {
        if ((kTilesCount - 1) == self->tiles[i]) {
            [result appendString:@"--"];
        }
        else {
            [result appendFormat:@"%02d", self->tiles[i] + 1];
        }
        [result appendString:(0 == ((i + 1) % kPuzzleSize)) ? @"\n" : @" "];
    }
    
    [result appendFormat:@"\nempty tile: %d\n", self.emptyTile];
    [result appendFormat:@"manhattan: %d\n", self.manhatten];
    [result appendFormat:@"move: %d\n", self.move];
    // [result appendFormat:@"hash: %d\n", self.hash];
    
    return [NSString stringWithString:result];
}

- (BOOL)isEqual:(id)anOther {
    return anOther == self || [self equalBoards:anOther];
}

- (NSUInteger)hash {
    uint64_t result = 0;
    for (size_t i = 0; i < kTilesCount; i++) {
        result *= 13;
        result+= self->tiles[i];
    }
    return result;
}

@end
