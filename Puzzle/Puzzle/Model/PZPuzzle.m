//
//  PZPuzzle.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PZPuzzle.h"
#import "PZTileLocation.h"
#import "PZTile.h"

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZPuzzle()

@property (nonatomic, strong) NSMutableArray *tiles;
@property (nonatomic, readonly) NSUInteger tilesCount;
@property (nonatomic, assign) PZTileLocation emptyTileLocation;

- (NSMutableArray *)newTilesWithImage:(UIImage *)anImage size:(NSUInteger)aSize;
- (PZTileLocation)locationForTileAtIndex:(NSUInteger)anIndex;
- (NSArray *)affectedTilesLocationsByTileMoveAtLocation:(PZTileLocation)aLocation;
- (PZTileLocation)randomMovableTileLocation;
- (void)exchangeTileAtLocation:(PZTileLocation)aLocation1 withTileAtLocation:(PZTileLocation)aLocation2;
- (NSUInteger)indexOfTileAtLocation:(PZTileLocation)aLocation;

@end

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZPuzzle
@synthesize size, tiles, emptyTileLocation;

- (id)initWithImage:(UIImage *)anImage size:(NSUInteger)aSize
{
    if (nil != (self = [super init]))
    {
        self.tiles = [self newTilesWithImage:anImage size:aSize];
    }
    return self;
}

- (PZTile *)tileAtLocation:(PZTileLocation)aLocation
{
    if (PZTileLocationEqualToLocation(self.emptyTileLocation, aLocation))
    {
        return nil;
    }
    return [self.tiles objectAtIndex:[self indexOfTileAtLocation:aLocation]];
}

- (PZMoveDirection)allowedMoveDirectionForTileAtLocation:(PZTileLocation)aLocation
{
    if (PZTileLocationEqualToLocation(aLocation, self.emptyTileLocation))
    {
        // no moves for empty location
        return kNoneDirection;
    }
    if (PZTileLocationInSameColumnAsLocation(aLocation, self.emptyTileLocation))
    {
        // vertical move allowed
        return (aLocation.y < self.emptyTileLocation.y) ? kTopDirection : kBottomDirection;
    }
    if (PZTileLocationInSameRowAsLocation(aLocation, self.emptyTileLocation))
    {
        // horizontal move allowed
        return (aLocation.x < self.emptyTileLocation.x) ? kRightDirection : kLeftDirection;
    }
    return kNoneDirection;
}

- (NSArray *)affectedTilesByTileMoveAtLocation:(PZTileLocation)aLocation
{
    NSArray *locations = [self affectedTilesLocationsByTileMoveAtLocation:aLocation];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:locations.count];

    for (NSValue *location in locations)
    {
        [result addObject:[self tileAtLocation:[location tileLocation]]];    
    }
    
    return [[NSArray alloc] initWithArray:result];
}

- (NSArray *)affectedTilesLocationsByTileMoveAtLocation:(PZTileLocation)aLocation
{
    NSMutableArray *result = [NSMutableArray new];
    void(^addTileLocation)(NSUInteger, NSUInteger) = ^(NSUInteger x, NSUInteger y)
    {
        [result addObject:[[NSValue alloc] initWithTileLocation:PZTileLocationMake(x, y)]];    
    };
    
    switch ([self allowedMoveDirectionForTileAtLocation:aLocation])
    {
        case kNoneDirection:
            break;
        case kLeftDirection:          
            for (NSUInteger x = aLocation.x; self.emptyTileLocation.x < x; x--)
            {
                addTileLocation(x, aLocation.y);
            }
            break;
        case kRightDirection:          
            for (NSUInteger x = aLocation.x; x < self.emptyTileLocation.x; x++)
            {
                addTileLocation(x, aLocation.y);
            }
            break;
        case kTopDirection:          
            for (NSUInteger y = aLocation.y; self.emptyTileLocation.y < y; y--)
            {
                addTileLocation(aLocation.x, y);
            }
            break;
        case kBottomDirection:          
            for (NSUInteger y = aLocation.y; self.emptyTileLocation.y < y; y--)
            {
                addTileLocation(aLocation.x, y);
            }
            break;
    }
    return [[NSArray alloc] initWithArray:result];
}

- (BOOL)moveTileAtLocation:(PZTileLocation)aLocation
{
    __block PZTileLocation previousLocation = self.emptyTileLocation;
    NSArray *locations = [self affectedTilesLocationsByTileMoveAtLocation:aLocation];
    [locations enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:
    ^(id aTileLocation, NSUInteger anIndex, BOOL *aStopFlag)
    {
        PZTileLocation location = [aTileLocation tileLocation];
        [self exchangeTileAtLocation:previousLocation withTileAtLocation:location];
        previousLocation = location;
    }];
    BOOL result = nil != locations;
    if (result)
    {
        self.emptyTileLocation = aLocation;
    }
    return result;
}

- (NSMutableArray *)newTilesWithImage:(UIImage *)anImage size:(NSUInteger)aSize
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
    [result addObject:[NSNull null]]; // empty tile

    self.emptyTileLocation = PZTileLocationMake(aSize - 1, aSize - 1);

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

- (void)exchangeTileAtLocation:(PZTileLocation)aLocation1 withTileAtLocation:(PZTileLocation)aLocation2
{
    [self.tiles exchangeObjectAtIndex:[self indexOfTileAtLocation:aLocation1]
                    withObjectAtIndex:[self indexOfTileAtLocation:aLocation2]];
}

- (void)shuffleUsingBlock:(void (^)(NSArray *tiles, PZMoveDirection direction))aBlock
{
    PZTileLocation previousLocation = self.emptyTileLocation;
    NSUInteger numberOfMoves = self.size;
    while (numberOfMoves)
    {
        PZTileLocation newLocation = [self randomMovableTileLocation];
        if (!PZTileLocationEqualToLocation(previousLocation, newLocation))
        {
            [self moveTileAtLocation:newLocation];
            if (NULL != aBlock)
            {
                aBlock([self affectedTilesByTileMoveAtLocation:newLocation],
                       [self allowedMoveDirectionForTileAtLocation:newLocation]);
            }
            --numberOfMoves;
        }
    }
}

- (PZTileLocation)randomMovableTileLocation
{
    // we have (columnsCount - 1) + (rowsCount - 1) movable tiles
    NSUInteger movableLocationsCount = 2 * (self.size - 1);
    
    // first just pick an index
    NSUInteger randomLocation = arc4random() % movableLocationsCount;
    
    // half of indices belongs to horizontal line, another half to vertical
    if (randomLocation < (self.size - 1))
    {
        // lets our first half be vertical line 
        if (self.emptyTileLocation.y <= randomLocation )
        {
            // we must take into account empty tile and skip it
            ++randomLocation;
        }

        return PZTileLocationMake(self.emptyTileLocation.x, randomLocation);
    }
    else
    {
        // this is our horizontal line, lets cut a half from our random number
        randomLocation -= self.size - 1;
        if (self.emptyTileLocation.x <= randomLocation )
        {
            // take into account empty tile and skip it
            ++randomLocation;
        }

        return PZTileLocationMake(randomLocation, self.emptyTileLocation.y);
    }
}

- (NSUInteger)indexOfTileAtLocation:(PZTileLocation)aLocation
{
    return aLocation.y * self.size + aLocation.x;
}

@end
