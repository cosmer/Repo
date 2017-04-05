//
//  RPDiffDelta.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"
#import "RPTypes.h"

NS_ASSUME_NONNULL_BEGIN

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
    RPDiffDeltaStatusUnreadable,
    RPDiffDeltaStatusConflicted,
};

extern NSString *RPDiffDeltaStatusName(RPDiffDeltaStatus status);
extern NSString *RPDiffDeltaStatusLetter(RPDiffDeltaStatus status);

/// RPDiffDelta is immutable and thread safe.
@interface RPDiffDelta : NSObject

- (instancetype)initWithDelta:(RPDiffDelta *)delta NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDelta:(RPDiffDelta *)delta apparentLocation:(RPDiffLocation)apparentLocation;

- (instancetype)initWithDiff:(RPDiff *)diff deltaIndex:(NSUInteger)deltaIndex location:(RPDiffLocation)location;

@property(nonatomic, readonly) RPDiffLocation location;
@property(nonatomic, readonly) RPDiffLocation apparentLocation;
@property(nonatomic, readonly) RPDiffDeltaStatus status;
@property(nonatomic, strong, readonly) RPDiffFile *oldFile;
@property(nonatomic, strong, readonly) RPDiffFile *newFile NS_RETURNS_NOT_RETAINED;

@end

NS_ASSUME_NONNULL_END
