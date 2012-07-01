//
//  PZPuzzle.h
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZTileLocation.h"

@protocol IPZTile;

typedef enum
{
    kNoneDirection = 0,
    kLeftDirection,
    kRightDirection,
    kUpDirection,
    kDownDirection
    
} PZMoveDirection;

@interface PZPuzzle : NSObject

- (id)initWithImage:(UIImage *)anImage size:(NSUInteger)aSize;

@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, readonly) PZTileLocation emptyTileLocation;
@property (nonatomic, assign) NSUInteger movesCount;
@property (nonatomic, readonly, getter = isWin) BOOL win;

- (id<IPZTile>)tileAtLocation:(PZTileLocation)aLocation;
- (NSArray *)tilesAtLocations:(NSArray *)aLocations;
- (PZMoveDirection)allowedMoveDirectionForTileAtLocation:(PZTileLocation)aLocation;
- (NSArray *)affectedTilesByTileMoveAtLocation:(PZTileLocation)aLocation;
- (NSArray *)affectedTilesLocationsByTileMoveAtLocation:(PZTileLocation)aLocation;
- (BOOL)moveTileAtLocation:(PZTileLocation)aLocation;

- (void)moveTileToRandomLocationWithCompletionBlock:(void (^)(NSArray *aTiles, PZMoveDirection aDirection))aBlock;

@end
