//
//  PZTile.h
//  Puzzle
//
//  Created by Eugene But on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZTile.h"

@interface PZTileImpl : NSObject<IPZTile>

- (id)initWithImage:(UIImage *)anImage currentLocation:(PZTileLocation)aCurrent winLocation:(PZTileLocation)aWinLocation;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) PZTileLocation winLocation;
@property (nonatomic, assign) PZTileLocation currentLocation;

@property (nonatomic, strong) id representedObject;

@end
