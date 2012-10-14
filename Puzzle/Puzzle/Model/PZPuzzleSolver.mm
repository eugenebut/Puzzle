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
#import <queue>
#import <iostream>
#import "SmallObj.h"

//////////////////////////////////////////////////////////////////////////////////////////
class puzzle_node: public Loki::SmallValueObject<> {

public:

    class comparator;
    
    // sentinel
    inline puzzle_node();

    // initial node
    inline puzzle_node(PZPuzzle *puzzle);
    
    // neighbour node
    inline puzzle_node(puzzle_node *node, uint8_t empty_tile);
    inline ~puzzle_node();
    
    inline void enqueue_neighbours(std::priority_queue<puzzle_node *, std::vector<puzzle_node *>,
                            puzzle_node::comparator > *queue);

    inline bool is_win() const {
        return 0 == manhattan_;
    }
    
    inline uint8_t empty_tile() const {
        return empty_tile_;
    }

    inline uint8_t manhattan() const {
        return manhattan_;
    }

    inline uint16_t weight() const {
        return weight_;
    }

    inline puzzle_node *previous_node() const {
        return previous_node_;
    }

    class comparator {
    public:
        bool operator()(const puzzle_node *n1, const puzzle_node *n2) {
            return n2->weight() < n1->weight();
        }
    };

    static const size_t kPuzzleSize = 4;
    static const size_t kTilesCount = kPuzzleSize * kPuzzleSize;

protected:
    inline uint8_t tile_index(PZTileLocation location) const;
    inline uint8_t calculate_manhatten() const;

private:
    
    puzzle_node *previous_node_;
    uint8_t tiles_[kTilesCount];
    uint8_t refcount_;
    uint8_t empty_tile_;
    uint8_t manhattan_;
    uint16_t move_;
    uint16_t weight_;
};

puzzle_node::puzzle_node()
: previous_node_(NULL),
  empty_tile_(100),
  refcount_(0) {
    ::memset(tiles_, 0x00, sizeof(tiles_));
}

puzzle_node::puzzle_node(PZPuzzle *puzzle) :
    previous_node_(new puzzle_node()),
    empty_tile_(tile_index(puzzle.emptyTileLocation)),
    move_(0),
    refcount_(0)
{
    ++(previous_node_->refcount_);
    [[puzzle allTiles] enumerateObjectsUsingBlock:^(id<IPZTile> aTile, NSUInteger anIndex, BOOL *aStop) {
        tiles_[anIndex] = tile_index(aTile.winLocation);
    }];
    
    manhattan_ = calculate_manhatten();
    weight_ = manhattan_;
}

puzzle_node::puzzle_node(puzzle_node *node, uint8_t empty_tile) :
  previous_node_(node),
  move_(node->move_ + 1),
  empty_tile_(empty_tile),
  refcount_(0)
{
    ::memmove(tiles_, node->tiles_, sizeof(tiles_));
    std::swap(tiles_[node->empty_tile_], tiles_[empty_tile_]);
    manhattan_ = calculate_manhatten();
    weight_ = move_ + manhattan_;
    ++(previous_node_->refcount_);
}

puzzle_node::~puzzle_node() {
    if (NULL != previous_node_) {
        if (0 == --(previous_node_->refcount_)) {
            delete previous_node_;
        }
    }
}

void puzzle_node::enqueue_neighbours(std::priority_queue<puzzle_node *, std::vector<puzzle_node *>, puzzle_node::comparator > *queue)  {
    uint8_t previous_empty_tile = previous_node_->empty_tile_;
    uint8_t empty_x = empty_tile_ % kPuzzleSize;
    uint8_t empty_y = empty_tile_ / kPuzzleSize;
    
    uint8_t next_empty_tile = empty_tile_ - 1;
    if (0 < empty_x && next_empty_tile != previous_empty_tile) {
        puzzle_node *node = new puzzle_node(this, next_empty_tile);
        queue->push(node);
        //        std::cout << "Pushed Manhattan: " << (int)node->manhattan() << " weight: " << node->weight() << std::endl;
    }
    
    next_empty_tile = empty_tile_ + 1;
    if (empty_x < kPuzzleSize - 1 && next_empty_tile != previous_empty_tile) {
        puzzle_node *node = new puzzle_node(this, next_empty_tile);
        queue->push(node);
        //        std::cout << "Pushed Manhattan: " << (int)node->manhattan() << " weight: " << node->weight() << std::endl;
    }
    
    next_empty_tile = empty_tile_ + kPuzzleSize;
    if (empty_y < kPuzzleSize - 1 && next_empty_tile != previous_empty_tile) {
        puzzle_node *node = new puzzle_node(this, next_empty_tile);
        queue->push(node);
        //        std::cout << "Pushed Manhattan: " << (int)node->manhattan() << " weight: " << node->weight() << std::endl;
    }
    
    next_empty_tile = empty_tile_ - kPuzzleSize;
    if (0 < empty_y && next_empty_tile != previous_empty_tile) {
        puzzle_node *node = new puzzle_node(this, next_empty_tile);
        queue->push(node);
        //        std::cout << "Pushed Manhattan: " << (int)node->manhattan() << " weight: " << node->weight() << std::endl;
    }
}

uint8_t puzzle_node::tile_index(PZTileLocation location) const {
    return location.y * kPuzzleSize + location.x;
}

uint8_t puzzle_node::calculate_manhatten() const {
    uint8_t result = 0;
    for (int x = 0; x < kPuzzleSize; x++) {
        for (int y = 0; y < kPuzzleSize; y++) {
            uint8_t number = tiles_[x + y * kPuzzleSize];
            if ((kTilesCount - 1) != number) {
                result += abs(x - (number % kPuzzleSize)) + abs(y - (number / kPuzzleSize));
            }
        }
    }
    return result;
}

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzle (Solver)

- (NSArray *)solution {
    puzzle_node *node = new puzzle_node(self);
    
    // we can't find solution for complex puzzles withing reasonable amount of time
    if (20 < node->manhattan()) {
        delete node;
        return nil;
    }
    
    std::priority_queue<puzzle_node *, std::vector<puzzle_node *>, puzzle_node::comparator > queue;
    //size_t size = sizeof(puzzle_node);
    queue.push(node);
    //std::cout << "Initial manhattan: " << (int)node->manhattan() << std::endl;
    
    while (!queue.empty()) {
        puzzle_node *node = queue.top();
//        std::cout << "Popped Manhattan: " << (int)node->manhattan() << " weight: " << node->weight() << std::endl;
        
        if (node->is_win()) {
            NSMutableArray *solution = [NSMutableArray new];

            while (NULL != node) {
                [solution addObject:[NSNumber numberWithChar:node->empty_tile()]];
                node = node->previous_node();
            }
            [solution removeLastObject];
            
            while (!queue.empty()) {
                const puzzle_node *node = queue.top();
                queue.pop();
                delete node;
            }
            
            return [NSArray arrayWithArray:solution];
        }
        queue.pop();
        node->enqueue_neighbours(&queue);
    }
    return nil;
}

- (void)applySolution:(NSArray *)solution animationBlock:(void (^)(NSArray *aTiles,
                                                                PZMoveDirection aDirection,
                                                                ChangeCompletion aCompletion))aBlock
{
    [self applySolution:solution index:solution.count - 2 animationBlock:aBlock];

}

- (void)applySolution:(NSArray *)solution
                index:(NSUInteger)anIndex
          animationBlock:(void (^)(NSArray *aTiles, PZMoveDirection aDirection, ChangeCompletion aCompletion))aBlock
{
    if (solution.count <= anIndex) {
        return;
    }
    
    NSNumber *node = [solution objectAtIndex:anIndex];
    PZTileLocation location = PZTileLocationMake([node charValue] % puzzle_node::kPuzzleSize,
                                                 [node charValue] / puzzle_node::kPuzzleSize);
    
    // remember tiles and direction to pass them to block
    NSArray *tiles = [self affectedTilesByTileMoveAtLocation:location];
    PZMoveDirection direction = [self allowedMoveDirectionForTileAtLocation:location];

    [self moveTileAtLocation:location];
    
    aBlock(tiles, direction, ^{
        [self applySolution:solution index:anIndex - 1 animationBlock:aBlock];
    });
}

@end
