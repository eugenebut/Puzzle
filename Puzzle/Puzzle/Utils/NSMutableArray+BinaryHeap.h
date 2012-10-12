//
//  NSMutableArray+BinaryHeap.h
//  Puzzle
//
//  Created by Eugene But on 10/11/12.
//
//

//////////////////////////////////////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////
@interface NSMutableArray (BinaryHeap)

- (void)binaryHeapHeapifyWithComparator:(NSComparator)aComparator;

- (id)binaryHeapPeakObject;

- (void)binaryHeapPushObject:(id)anObject comparator:(NSComparator)aComparator;
- (id)binaryHeapPopMaxObjectWithComparator:(NSComparator)aComparator;

@end
