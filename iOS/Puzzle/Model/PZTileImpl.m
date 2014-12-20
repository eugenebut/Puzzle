//
//  PZTile.m
//  Puzzle

////////////////////////////////////////////////////////////////////////////////
#import "PZTileImpl.h"

////////////////////////////////////////////////////////////////////////////////
@implementation PZTileImpl

- (instancetype)initWithImage:(UIImage *)anImage
              currentLocation:(PZTileLocation)aCurrentLocation
                  winLocation:(PZTileLocation)aWinLocation {
    if (nil != (self = [super init])) {
        _image = anImage;
        _currentLocation = aCurrentLocation;
        _winLocation = aWinLocation;
    }
    return self;
}

- (instancetype)init {
    return [self initWithImage:nil
               currentLocation:PZTileLocationMake(0, 0)
                   winLocation:PZTileLocationMake(0, 0)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"Current location: %lu-%lu\nWin location: %lu-%lu",
            (unsigned long)self.currentLocation.x,
            (unsigned long)self.currentLocation.y,
            (unsigned long)self.winLocation.x,
            (unsigned long)self.winLocation.y];
}

@end
