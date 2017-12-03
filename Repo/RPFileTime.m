//
//  RPFileTime.m
//  Repo
//
//  Created by Charles Osmer on 8/15/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import "RPFileTime.h"

NSComparisonResult RPCompareFileTimes(RPFileTime left, RPFileTime right)
{
    if (left.seconds < right.seconds) {
        return NSOrderedAscending;
    }
    if (left.seconds > right.seconds) {
        return NSOrderedDescending;
    }

    if (left.nanoseconds < right.nanoseconds) {
        return NSOrderedAscending;
    }
    if (left.nanoseconds > right.nanoseconds) {
        return NSOrderedDescending;
    }

    return NSOrderedSame;
}

BOOL RPFileTimesEqual(RPFileTime a, RPFileTime b)
{
    return a.seconds == b.seconds && a.nanoseconds == b.nanoseconds;
}
