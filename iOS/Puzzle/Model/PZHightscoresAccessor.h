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

+ (NSUInteger)defaultsIntegerForKey:(NSString *)aKey;
+ (void)updateDefaultsInteger:(NSUInteger)aValue forKey:(NSString *)aKey;

@end
