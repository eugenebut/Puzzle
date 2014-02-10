//
//  PZMessageFormatter.m
//  Puzzle
//
//  Created by Eugene But on 9/15/12.
//
//

////////////////////////////////////////////////////////////////////////////////
#import "PZMessageFormatter.h"

////////////////////////////////////////////////////////////////////////////////
@implementation PZMessageFormatter

+ (NSString *)timeMessage:(NSUInteger)aSeconds {
    return [NSString stringWithFormat:@"%02d:%02d:%02d",
            aSeconds / 60 / 60,
            aSeconds / 60 % 60,
            aSeconds % 60];
}

+ (NSString *)movesCountMessage:(NSUInteger)aCount {
    static NSNumberFormatter *sFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sFormatter = [self newFormatter];
        [sFormatter setFormatWidth:4];
    });
    
    return [sFormatter stringFromNumber:@(aCount)];
}

+ (NSString *)movesCountLongMessage:(NSUInteger)aCount {
    static NSNumberFormatter *sFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sFormatter = [self newFormatter];
        [sFormatter setFormatWidth:7];
    });

    return [sFormatter stringFromNumber:@(aCount)];
}

+ (NSNumberFormatter *)newFormatter {
    NSNumberFormatter *result = [NSNumberFormatter new];
    [result setLocale:[NSLocale autoupdatingCurrentLocale]];
    [result setNumberStyle:kCFNumberFormatterNoStyle];
    [result setPaddingCharacter:[result stringFromNumber:
                                 @0U]];
    return result;
}

@end
