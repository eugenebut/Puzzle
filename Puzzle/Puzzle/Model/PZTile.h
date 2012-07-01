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

@property (nonatomic, strong) id representedObject;

@end
