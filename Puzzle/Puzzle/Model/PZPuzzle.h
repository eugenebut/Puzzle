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
    kTopDirection,
    kBottomDirection
    
} PZMoveDirection;

@interface PZPuzzle : NSObject

- (id)initWithImage:(UIImage *)anImage size:(NSUInteger)aSize;

@property (nonatomic, assign) NSUInteger size;

- (PZTile *)tileAtLocation:(PZTileLocation)aLocation;
- (PZMoveDirection)allowedMoveDirectionForTileAtLocation:(PZTileLocation)aLocation;
- (NSArray *)affectedTilesByTileMoveAtLocation:(PZTileLocation)aLocation;
- (BOOL)moveTileAtLocation:(PZTileLocation)aLocation;

- (BOOL)isWin;
- (void)shuffleUsingBlock:(void (^)(NSArray *tiles, PZMoveDirection direction))aBlock;

@end
