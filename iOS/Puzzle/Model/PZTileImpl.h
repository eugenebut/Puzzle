//
//  PZTile.h
//  Puzzle

////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>
#import "PZTile.h"

////////////////////////////////////////////////////////////////////////////////
@interface PZTileImpl : NSObject<IPZTile>

- (instancetype)initWithImage:(UIImage *)anImage
              currentLocation:(PZTileLocation)aCurrentLocation
                  winLocation:(PZTileLocation)aWinLocation;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) PZTileLocation winLocation;
@property (nonatomic, assign) PZTileLocation currentLocation;
@property (nonatomic, strong) id representedObject;

@end
