//
//  PZTile.m
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PZTile.h"

@implementation PZTile
@synthesize image, winLocation, representedObject;

- (id)initWithImage:(UIImage *)anImage winLocation:(PZTileLocation)aWinLocation
{
    if (nil != (self = [super init]))
    {
        self.image = anImage;
        self.winLocation = aWinLocation;
    }
    return self;
}

@end
