//
//  PZTileLocation.m
//  Puzzle
//
//  Created by Eugene But on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PZTileLocation.h"

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
