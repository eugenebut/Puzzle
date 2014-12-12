//
//  PZHightscoresAccessor.m
//  Puzzle
//
//  Created by Eugene But on 9/23/12.
//
//

////////////////////////////////////////////////////////////////////////////////
#import "PZHightscoresAccessor.h"

////////////////////////////////////////////////////////////////////////////////
NSString *const kBestTimeDefaultsKey = @"PZBestTimeDefaults";
NSString *const kBestMovesDefaultsKey = @"PZBestMovesDefaults";

////////////////////////////////////////////////////////////////////////////////
@implementation PZHightscoresAccessor

+ (BOOL)hasHighscores {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return nil != [defaults objectForKey:kBestTimeDefaultsKey] &&
           nil != [defaults objectForKey:kBestMovesDefaultsKey];
}

+ (NSUInteger)defaultsUIntegerForKey:(NSString *)aKey {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    return (nil != result) ? [result unsignedIntegerValue] : ULONG_MAX;
}

+ (void)updateDefaultsUInteger:(NSUInteger)aValue forKey:(NSString *)aKey {
    if (aValue < [self defaultsUIntegerForKey:aKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(aValue)
                                                  forKey:aKey];
    }
}

@end
