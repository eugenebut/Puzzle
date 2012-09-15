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
static NSNumberFormatter *sFormatter = nil;

//////////////////////////////////////////////////////////////////////////////////////////
@implementation PZMessageFormatter

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(localeDidChangeNotification:)
            name:NSCurrentLocaleDidChangeNotification object:nil];
}

+ (NSString *)timeMessage:(NSUInteger)aSeconds
{
    return [NSString stringWithFormat:@"%02d:%02d:%02d",
            aSeconds / 60 / 60,
            aSeconds / 60 % 60,
            aSeconds % 60];
}

+ (NSString *)movesCountMessage:(NSUInteger)aCount
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sFormatter = [NSNumberFormatter new];
        [sFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        [sFormatter setNumberStyle:kCFNumberFormatterNoStyle];
        [sFormatter setPaddingCharacter:[sFormatter stringFromNumber:
                                         [NSNumber numberWithUnsignedInteger:0]]];
        [sFormatter setFormatWidth:4];
    });
    
    return [sFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:aCount]];
}

+ (void)localeDidChangeNotification:(NSNotification *)aNotification
{
    [sFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    [sFormatter setPaddingCharacter:[sFormatter stringFromNumber:
                                    [NSNumber numberWithUnsignedInteger:0]]];
}

@end
