//
//  PZMessageFormatter.h
//  Puzzle
//
//  Created by Eugene But on 9/15/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////
@interface PZMessageFormatter : NSObject

+ (NSString *)timeMessage:(NSUInteger)aSeconds;
+ (NSString *)movesCountMessage:(NSUInteger)aCount;
+ (NSString *)movesCountLongMessage:(NSUInteger)aCount;

@end
