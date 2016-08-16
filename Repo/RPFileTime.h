//
//  RPFileTime.h
//  Repo
//
//  Created by Charles Osmer on 8/15/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    int32_t seconds;
    uint32_t nanoseconds;
} RPFileTime;

NSComparisonResult RPCompareFileTimes(RPFileTime left, RPFileTime right);
