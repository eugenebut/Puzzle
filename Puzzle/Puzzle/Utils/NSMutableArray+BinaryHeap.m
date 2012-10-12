//
//  NSMutableArray+BinaryHeap.m
//  Puzzle
//
//  Created by Eugene But on 10/11/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import "NSMutableArray+BinaryHeap.h"

//////////////////////////////////////////////////////////////////////////////////////////
@implementation NSMutableArray (MaxHeap)

- (void)binaryHeapHeapifyWithComparator:(NSComparator)aComparator {
    for (NSUInteger index = self.count / 2; 1 <= index; --index) {
        [self binaryHeapSink:index comparator:aComparator];
    }
}

- (id)binaryHeapPeakObject {
    return 0 < self.count ? [self objectAtIndex:0] : nil;
}

- (void)binaryHeapPushObject:(id)anObject comparator:(NSComparator)aComparator {
    [self addObject:anObject];
    [self binaryHeapSwim:self.count comparator:aComparator];
}

- (id)binaryHeapPopMaxObjectWithComparator:(NSComparator)aComparator {
    id result = [self binaryHeapPeakObject];
    if (nil != result) {
        [self exchangeObjectAtIndex:0 withObjectAtIndex:self.count - 1];
        [self removeLastObject];
        [self binaryHeapSink:1 comparator:aComparator];
    }
    return result;
}

- (void)binaryHeapSwim:(NSUInteger)anIndex comparator:(NSComparator)aComparator {
    while (1 < anIndex && NSOrderedAscending == aComparator([self objectAtIndex:(anIndex / 2 - 1)], [self objectAtIndex:(anIndex - 1)])) {
        [self exchangeObjectAtIndex:(anIndex / 2 - 1) withObjectAtIndex:(anIndex - 1)];
        anIndex = anIndex / 2;
    }    
}

- (void)binaryHeapSink:(NSUInteger)anIndex comparator:(NSComparator)aComparator {

    while (2 * anIndex < self.count) {
        NSUInteger childIndex = 2 * anIndex;
        if (childIndex < self.count &&
            NSOrderedAscending == aComparator([self objectAtIndex:childIndex - 1], [self objectAtIndex:childIndex])) {
            ++childIndex;
        }
        
        if (NSOrderedAscending != aComparator([self objectAtIndex:anIndex - 1], [self objectAtIndex:childIndex - 1])) {
            break;
        }
        
        [self exchangeObjectAtIndex:(anIndex - 1) withObjectAtIndex:(childIndex - 1)];
        anIndex = childIndex;
    }
}

@end
