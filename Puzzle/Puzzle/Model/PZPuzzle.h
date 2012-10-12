//
//  PZPuzzle.h
//  Puzzle

//////////////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>
#import "PZTileLocation.h"

//////////////////////////////////////////////////////////////////////////////////////////
@protocol IPZTile;

//////////////////////////////////////////////////////////////////////////////////////////
typedef enum
{
    kNoneDirection = 0,
    kLeftDirection,
    kRightDirection,
    kUpDirection,
    kDownDirection
    
} PZMoveDirection;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZPuzzle : NSObject

- (id)initWithImage:(UIImage *)anImage size:(NSUInteger)aSize state:(NSDictionary *)aState;

@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, readonly) PZTileLocation emptyTileLocation;
@property (nonatomic, assign) NSUInteger movesCount;
@property (nonatomic, readonly, getter = isWin) BOOL win;

@property (nonatomic, readonly) NSDictionary *state;

- (id<IPZTile>)tileAtLocation:(PZTileLocation)aLocation;

// aLocations - array of NSValues wrapping PZTileLocation structs
- (NSArray *)tilesAtLocations:(NSArray *)aLocations;
- (NSArray *)allTiles;

// where our tiles can move from the given location?
- (PZMoveDirection)allowedMoveDirectionForTileAtLocation:(PZTileLocation)aLocation;

// moving one tile can affect others, which ones?
- (NSArray *)affectedTilesByTileMoveAtLocation:(PZTileLocation)aLocation;
- (NSArray *)affectedTilesLocationsByTileMoveAtLocation:(PZTileLocation)aLocation;

// move tile in our puzzle. Returns NO if move was not possible
- (BOOL)moveTileAtLocation:(PZTileLocation)aLocation;

// allows shuffling the puzzle
- (void)moveTileToRandomLocationWithCompletionBlock:
    (void (^)(NSArray *aTiles, PZMoveDirection aDirection))aBlock;

@end
