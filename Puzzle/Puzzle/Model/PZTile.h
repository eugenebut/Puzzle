//
//  PZTile.h
//  Puzzle

//////////////////////////////////////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>
#import "PZTileLocation.h"

//////////////////////////////////////////////////////////////////////////////////////////
@protocol IPZTile <NSObject>

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) PZTileLocation currentLocation;

// you may put here any object for your convenience
@property (nonatomic, strong) id representedObject;

@end
