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

- (void)binaryHeapHeapifyWithFunction:(NSComparisonResult (*)(id, id))aComparator;

- (id)binaryHeapPeakObject;

- (void)binaryHeapPushObject:(id)anObject function:(NSComparisonResult (*)(id, id))aComparator;
- (id)binaryHeapPopMaxObjectWithFunction:(NSComparisonResult (*)(id, id))aComparator;

@end
