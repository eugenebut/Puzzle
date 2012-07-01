//
//  PZPuzzle.h
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZTileLocation.h"

@class PZTile;

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
@property (nonatomic, assign) NSUInteger turnsCount;
@property (nonatomic, readonly) PZTileLocation emptyTileLocation;

- (PZTile *)tileAtLocation:(PZTileLocation)aLocation;
- (NSArray *)tilesAtLocations:(NSArray *)aLocations;
- (PZMoveDirection)allowedMoveDirectionForTileAtLocation:(PZTileLocation)aLocation;
- (NSArray *)affectedTilesByTileMoveAtLocation:(PZTileLocation)aLocation;
- (NSArray *)affectedTilesLocationsByTileMoveAtLocation:(PZTileLocation)aLocation;
- (BOOL)moveTileAtLocation:(PZTileLocation)aLocation;

- (BOOL)isWin;
- (void)shuffleUsingBlock:(void (^)(NSArray *tiles, PZMoveDirection direction))aBlock;

@end
