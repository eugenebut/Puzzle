//
//  PZMessageFormatter.m
//  Puzzle
//
//  Created by Eugene But on 9/15/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "PZMessageFormatter.h"

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZMessageFormatter

+ (NSString *)timeMessage:(NSUInteger)aSeconds
{
    return [NSString stringWithFormat:@"%02d:%02d:%02d",
            aSeconds / 60 / 60,
            aSeconds / 60 % 60,
            aSeconds % 60];
}

+ (NSString *)movesCountMessage:(NSUInteger)aCount
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:kCFNumberFormatterNoStyle];
    [formatter setPaddingCharacter:[formatter stringFromNumber:
                                    [NSNumber numberWithUnsignedInteger:0]]];
    [formatter setFormatWidth:4];
    [formatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    return [formatter stringFromNumber:[NSNumber numberWithUnsignedInteger:aCount]];
}

@end
