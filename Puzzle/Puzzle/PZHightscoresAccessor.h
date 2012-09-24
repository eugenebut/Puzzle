//
//  PZHightscoresAccessor.h
//  Puzzle
//
//  Created by Eugene But on 9/23/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////
extern NSString *const kBestTimeDefaultsKey;
extern NSString *const kBestMovesDefaultsKey;

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZHightscoresAccessor : NSObject

+ (BOOL)hasHighscores;

// TODO: rename to defaultsIntegerForKey
+ (NSUInteger)defaultsIntegerForKey:(NSString *)aKey;
+ (void)updateDefaultsInteger:(NSUInteger)aValue forKey:(NSString *)aKey;

@end
