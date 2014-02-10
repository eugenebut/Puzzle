//
//  PZTileLocation.h
//  Puzzle

////////////////////////////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////
typedef struct {
    NSUInteger x;
    NSUInteger y;
} PZTileLocation;

////////////////////////////////////////////////////////////////////////////////
static inline PZTileLocation PZTileLocationMake(NSUInteger x, NSUInteger y) {
    PZTileLocation result;
    result.x = x;
    result.y = y;
    return result;
}

static inline bool PZTileLocationEqualToLocation(PZTileLocation loc1,
                                                 PZTileLocation loc2) {
    return loc1.x == loc2.x && loc1.y == loc2.y;
}

static inline bool PZTileLocationInSameColumnAsLocation(PZTileLocation loc1,
                                                        PZTileLocation loc2) {
    return loc1.x == loc2.x;
}

static inline bool PZTileLocationInSameRowAsLocation(PZTileLocation loc1,
                                                     PZTileLocation loc2) {
    return loc1.y == loc2.y;
}

////////////////////////////////////////////////////////////////////////////////
@interface NSValue (PZTileLocation)

- (instancetype)initWithTileLocation:(PZTileLocation)aLocation;
- (PZTileLocation)tileLocation;

@end

