//
//  PZHightscoresAccessor.m
//  Puzzle
//
//  Created by Eugene But on 9/23/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZHightscoresAccessor.h"

//////////////////////////////////////////////////////////////////////////////////////////
NSString *const kBestTimeDefaultsKey = @"PZBestTimeDefaults";
NSString *const kBestMovesDefaultsKey = @"PZBestMovesDefaults";

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZHightscoresAccessor

+ (BOOL)hasHighscores {
    return nil != [[NSUserDefaults standardUserDefaults] objectForKey:kBestTimeDefaultsKey] &&
           nil != [[NSUserDefaults standardUserDefaults] objectForKey:kBestMovesDefaultsKey];
}

+ (NSUInteger)defaultsIntegerForKey:(NSString *)aKey {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    if (nil != result) {
        return [result unsignedIntegerValue];
    }
    return ULONG_MAX;
}

+ (void)updateDefaultsInteger:(NSUInteger)aValue forKey:(NSString *)aKey {
    NSNumber *bestValue = [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    if (nil == bestValue || aValue < [bestValue unsignedIntegerValue]) {
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithUnsignedInteger:aValue] forKey:aKey];
    }
}

@end
