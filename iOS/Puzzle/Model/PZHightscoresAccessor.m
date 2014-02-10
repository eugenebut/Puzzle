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

+ (NSUInteger)defaultsIntegerForKey:(NSString *)aKey {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    return (nil != result) ? [result unsignedIntegerValue] : ULONG_MAX;
}

+ (void)updateDefaultsInteger:(NSUInteger)aValue forKey:(NSString *)aKey {
    NSNumber *bestValue = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    if (nil == bestValue || aValue < [bestValue unsignedIntegerValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:
            @(aValue) forKey:aKey];
    }
}

@end
