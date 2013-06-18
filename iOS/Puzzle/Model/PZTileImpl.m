//
//  PZTile.m
//  Puzzle

////////////////////////////////////////////////////////////////////////////////
#import "PZTileImpl.h"

////////////////////////////////////////////////////////////////////////////////
@implementation PZTileImpl
@synthesize image, currentLocation, winLocation, representedObject;

- (id)initWithImage:(UIImage *)anImage
    currentLocation:(PZTileLocation)aCurrentLocation
        winLocation:(PZTileLocation)aWinLocation {
    if (nil != (self = [super init])) {
        self.image = anImage;
        self.currentLocation = aCurrentLocation;
        self.winLocation = aWinLocation;
    }
    return self;
}

- (id)init {
    return [self initWithImage:nil
               currentLocation:PZTileLocationMake(0, 0)
                   winLocation:PZTileLocationMake(0, 0)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"Current location: %d-%d\nWin location: %d-%d",
            self.currentLocation.x, self.currentLocation.y,
            self.winLocation.x, self.winLocation.y];
}

@end
