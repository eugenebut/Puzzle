//
//  PZTile.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PZTile.h"

@implementation PZTile
@synthesize image, currentLocation, winLocation, representedObject;

- (id)initWithImage:(UIImage *)anImage currentLocation:(PZTileLocation)aCurrentLocation
        winLocation:(PZTileLocation)aWinLocation
{
    if (nil != (self = [super init]))
    {
        self.image = anImage;
        self.currentLocation = aCurrentLocation;
        self.winLocation = aWinLocation;
    }
    return self;
}

- (id)init
{
    return [self initWithImage:nil currentLocation:PZTileLocationMake(0, 0) winLocation:PZTileLocationMake(0, 0)];
}

@end
