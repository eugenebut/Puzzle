//
//  PZHightscoresAccessor.h
//  Puzzle
//
//  Created by Eugene But on 9/23/12.
//
//

////////////////////////////////////////////////////////////////////////////////
@import Foundation;

////////////////////////////////////////////////////////////////////////////////
extern NSString *const kBestTimeDefaultsKey;
extern NSString *const kBestMovesDefaultsKey;

////////////////////////////////////////////////////////////////////////////////
@interface PZHightscoresAccessor : NSObject

+ (BOOL)hasHighscores;

+ (NSUInteger)defaultsUIntegerForKey:(NSString *)aKey;
+ (void)updateDefaultsUInteger:(NSUInteger)aValue forKey:(NSString *)aKey;

@end
