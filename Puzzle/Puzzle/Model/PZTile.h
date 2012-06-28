//
//  PZTile.h
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct
{
    NSUInteger x;
    NSUInteger y;
} PZTileLocation;

static inline PZTileLocation PZTileLocationMake(NSUInteger x, NSUInteger y)
{
    PZTileLocation result;
    result.x = x;
    result.y = y;
    return result;
}

static inline bool PZTileLocationEqualToLocation(PZTileLocation loc1, PZTileLocation loc2)
{
    return loc1.x == loc2.x && loc1.y == loc2.y;
}

@interface PZTile : NSObject

- (id)initWithImage:(UIImage *)anImage winLocation:(PZTileLocation)aWinLocation;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) PZTileLocation winLocation;

@property (nonatomic, strong) id representedObject;

@end
