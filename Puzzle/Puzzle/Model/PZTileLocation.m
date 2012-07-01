//
//  PZTileLocation.m
//  Puzzle

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZTileLocation.h"

//////////////////////////////////////////////////////////////////////////////////////////
@implementation NSValue (PZTileLocation)

- (id)initWithTileLocation:(PZTileLocation)aLocation
{
    return [self initWithBytes:&aLocation objCType:@encode(PZTileLocation)];
}

- (PZTileLocation)tileLocation
{
    PZTileLocation result;
    [self getValue:&result];
    return result;
}

@end
