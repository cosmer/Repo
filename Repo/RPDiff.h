//
//  RPDiff.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class RPRepo;
@class RPDiffDelta;
@class RPTree;
@class RPReference;

typedef struct git_diff git_diff;

@interface RPDiff : NSObject

+ (nullable instancetype)diffIndexToWorkdirInRepo:(RPRepo *)repo error:(NSError **)error;

+ (nullable instancetype)diffHeadToWorkdirWithIndexInRepo:(RPRepo *)repo error:(NSError **)error;

+ (instancetype)diffOldTree:(RPTree *)oldTree toNewTree:(RPTree *)newTree inRepo:(RPRepo *)repo error:(NSError **)error;

+ (nullable instancetype)diffOldReference:(RPReference *)oldReference
                           toNewReference:(RPReference *)newReference
                                   inRepo:(RPRepo *)repo
                                    error:(NSError **)error;

+ (nullable instancetype)diffMergeBaseOfOldReference:(RPReference *)oldReference
                                      toNewReference:(RPReference *)newReference
                                              inRepo:(RPRepo *)repo
                                               error:(NSError **)error;

/// Assumes ownership of `diff`.
- (instancetype)initWithGitDiff:(git_diff *)diff repo:(RPRepo *)repo NS_DESIGNATED_INITIALIZER;

- (void)enumerateDeltasUsingBlock:(RP_NO_ESCAPE void (^)(RPDiffDelta *delta))block;

/// Transform a diff marking file renames, copies, etc.
/// \return YES if the find succeeded, NO if an error occurred.
- (BOOL)findSimilarWithError:(NSError **)error;

@property(nonatomic, readonly) git_diff *gitDiff RP_RETURNS_INTERIOR_POINTER;
@property(nonatomic, strong, readonly) RPRepo *repo;

@property(nonatomic, readonly) NSUInteger deltaCount;

@end

NS_ASSUME_NONNULL_END
