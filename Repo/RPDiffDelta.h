//
//  RPDiffDelta.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPDiff;
@class RPDiffFile;

typedef NS_ENUM(NSInteger, RPDiffDeltaStatus) {
    RPDiffDeltaStatusUnmodified,
    RPDiffDeltaStatusAdded,
    RPDiffDeltaStatusDeleted,
    RPDiffDeltaStatusModified,
    RPDiffDeltaStatusRenamed,
    RPDiffDeltaStatusCopied,
    RPDiffDeltaStatusIgnored,
    RPDiffDeltaStatusUntracked,
    RPDiffDeltaStatusTypeChange,
};

@interface RPDiffDelta : NSObject

- (instancetype)initWithDiff:(RPDiff *)diff deltaIndex:(NSUInteger)deltaIndex NS_DESIGNATED_INITIALIZER;

- (RPDiffFile *)oldFile;
- (RPDiffFile *)newFile;

@property(nonatomic, strong, readonly) RPDiff *diff;
@property(nonatomic, readonly) NSUInteger deltaIndex;

@property(nonatomic, readonly) RPDiffDeltaStatus status;

@end
