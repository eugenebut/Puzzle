//
//  PZPuzzle.h
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZTile.h"

typedef enum
{
    kNoneDirection = 0,
    
} PZMoveDirection;

@interface PZPuzzle : NSObject

- (id)initWithImage:(UIImage *)anImage size:(NSUInteger)aSize;

- (PZTile *)tileAtLocation:(PZTileLocation)aLocation;
- (PZMoveDirection)moveDirectionAtLocation:(PZTileLocation)aLocation;
- (NSArray *)affectedTilesByMoveAtLocation:(PZTileLocation)aLocation;

- (BOOL)isWin;
- (void)shuffle;

@end
