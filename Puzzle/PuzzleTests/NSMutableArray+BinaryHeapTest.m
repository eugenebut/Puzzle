//
//  NSMutableArray+BinaryHeapTest.m
//  Puzzle
//
//  Created by Eugene But on 10/11/12.
//
//

#import "NSMutableArray+BinaryHeapTest.h"
#import "NSMutableArray+BinaryHeap.h"

NSComparisonResult (^NumberComparator)(id obj1, id obj2) = ^(id obj1, id obj2){
    return [obj1 compare:obj2];
};

@implementation NSMutableArray_BinaryHeapTest

- (void)testHeapifying {
    NSMutableArray *testable = [@[@1, @8, @12, @5, @2, @6, @10] mutableCopy];
    [testable binaryHeapHeapifyWithComparator:NumberComparator];
    STAssertEqualObjects((@[@12, @8, @10, @5, @2, @6, @1]), testable, @"Invalid testable: %@", testable);
}

- (void)testPush {
    NSMutableArray *testable = [NSMutableArray new];
    
    [testable binaryHeapPushObject:@1 comparator:NumberComparator];
    STAssertEqualObjects(@[@1], testable, @"");

    [testable binaryHeapPushObject:@2 comparator:NumberComparator];
    STAssertEqualObjects((@[@2, @1]), testable, @"");

    [testable binaryHeapPushObject:@10 comparator:NumberComparator];
    STAssertEqualObjects((@[@10, @1, @2]), testable, @"Invalid testable: %@", testable);

    [testable binaryHeapPushObject:@5 comparator:NumberComparator];
    STAssertEqualObjects((@[@10, @5, @2, @1]), testable, @"Invalid testable: %@", testable);

    [testable binaryHeapPushObject:@8 comparator:NumberComparator];
    STAssertEqualObjects((@[@10, @8, @2, @1, @5]), testable, @"Invalid testable: %@", testable);

    [testable binaryHeapPushObject:@6 comparator:NumberComparator];
    STAssertEqualObjects((@[@10, @8, @6, @1, @5, @2]), testable, @"Invalid testable: %@", testable);

    [testable binaryHeapPushObject:@12 comparator:NumberComparator];
    STAssertEqualObjects((@[@12, @8, @10, @1, @5, @2, @6]), testable, @"Invalid testable: %@", testable);
}

- (void)testPop {
    NSMutableArray *testable = [@[@12, @8, @10, @1, @5, @2, @6] mutableCopy];
    
    STAssertEqualObjects(@12, [testable binaryHeapPeakObject], @"");
    STAssertEqualObjects(@12, [testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");
    STAssertEqualObjects((@[@10, @8, @6, @1, @5, @2]), testable, @"Invalid testable: %@", testable);

    STAssertEqualObjects(@10, [testable binaryHeapPeakObject], @"");
    STAssertEqualObjects(@10, [testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");
    STAssertEqualObjects((@[@8, @5, @6, @1, @2]), testable, @"Invalid testable: %@", testable);

    STAssertEqualObjects(@8, [testable binaryHeapPeakObject], @"");
    STAssertEqualObjects(@8, [testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");
    STAssertEqualObjects((@[@6, @5, @2, @1]), testable, @"Invalid testable: %@", testable);

    STAssertEqualObjects(@6, [testable binaryHeapPeakObject], @"");
    STAssertEqualObjects(@6, [testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");
    STAssertEqualObjects((@[@5, @1, @2]), testable, @"Invalid testable: %@", testable);

    STAssertEqualObjects(@5, [testable binaryHeapPeakObject], @"");
    STAssertEqualObjects(@5, [testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");
    STAssertEqualObjects((@[@2, @1]), testable, @"Invalid testable: %@", testable);

    STAssertEqualObjects(@2, [testable binaryHeapPeakObject], @"");
    STAssertEqualObjects(@2, [testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");
    STAssertEqualObjects((@[@1]), testable, @"Invalid testable: %@", testable);

    STAssertEqualObjects(@1, [testable binaryHeapPeakObject], @"");
    STAssertEqualObjects(@1, [testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");
    STAssertEqualObjects((@[]), testable, @"Invalid testable: %@", testable);

    STAssertNil([testable binaryHeapPeakObject], @"");
    STAssertNil([testable binaryHeapPopMaxObjectWithComparator:NumberComparator], @"");

}


@end
