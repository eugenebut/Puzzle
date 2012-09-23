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
+ (NSUInteger)defaultsValueForKey:(NSString *)aKey;
+ (void)updateDefaultsValue:(NSUInteger)aValue forKey:(NSString *)aKey;

@end