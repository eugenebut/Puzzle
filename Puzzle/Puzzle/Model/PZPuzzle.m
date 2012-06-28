//
//  PZPuzzle.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PZPuzzle.h"

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZPuzzle()

@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, readonly) NSUInteger tilesCount;

- (NSArray *)newTilesWithImage:(UIImage *)anImage size:(NSUInteger)aSize;
- (PZTileLocation)locationForTileAtIndex:(NSUInteger)anIndex;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzle
@synthesize size, tiles;

- (id)initWithImage:(UIImage *)anImage size:(NSUInteger)aSize
{
    if (nil != (self = [super init]))
    {
    }
    return self;
}

- (PZTile *)tileAtLocation:(PZTileLocation)aLocation
{
    return [self.tiles objectAtIndex:aLocation.y * self.size + aLocation.x];
}

- (PZMoveDirection)moveDirectionAtLocation:(PZTileLocation)aLocation
{
    return kNoneDirection;
}

- (NSArray *)affectedTilesByMoveAtLocation:(PZTileLocation)aLocation
{
    return nil;
}

- (NSArray *)newTilesWithImage:(UIImage *)anImage size:(NSUInteger)aSize
{
    CGFloat tileWidth = anImage.size.width / aSize;
    CGFloat tileHeight = anImage.size.height / aSize;

    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.tilesCount];
    for (NSUInteger tileIndex = 0; tileIndex < self.tilesCount; tileIndex++)
    {
        PZTileLocation location = [self locationForTileAtIndex:tileIndex];
        CGRect rect = CGRectMake(location.x * tileWidth, location.y * tileHeight,
                                 tileWidth, tileHeight);
        CGImageRef CGImage = CGImageCreateWithImageInRect([anImage CGImage], rect);
        UIImage *image = [[UIImage alloc] initWithCGImage:CGImage];
        [result addObject:[[PZTile alloc] initWithImage:image winLocation:location]];
    }
    return result;
}

- (NSUInteger)tilesCount
{
    return self.size * self.size - 1;
}

- (PZTileLocation)locationForTileAtIndex:(NSUInteger)anIndex
{
    NSUInteger y = anIndex / self.size;
    NSUInteger x = anIndex - y * self.size;

    return PZTileLocationMake(x, y);
}

- (BOOL)isWin
{
    for (NSUInteger tileIndex = 0; tileIndex < self.tilesCount; tileIndex++)
    {
        PZTile *tile = [self.tiles objectAtIndex:tileIndex];
        if (!PZTileLocationEqualToLocation([self locationForTileAtIndex:tileIndex],
                                           tile.winLocation))
        {
            return NO;
        }
    }
    return YES;
}
@end
