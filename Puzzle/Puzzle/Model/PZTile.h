//
//  PZTile.h
//  Puzzle
//
//  Created by Eugene But on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZTileLocation.h"

@protocol IPZTile <NSObject>

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) PZTileLocation currentLocation;

@property (nonatomic, strong) id representedObject;

@end
