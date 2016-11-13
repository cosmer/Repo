//
//  RPDiff.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"
#import "RPTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class RPRepo;
@class RPDiffDelta;
@class RPTree;
@class RPIndex;
@class RPObject;
@class RPDiffStats;
@class RPConflict;

typedef struct git_diff git_diff;

typedef NS_OPTIONS(uint32_t, RPDiffFlag) {
    RPDiffFlagNormal                        = 0,
    RPDiffFlagReverse                       = (1u << 0),
    RPDiffFlagIncludeIgnored                = (1u << 1),
    RPDiffFlagRecurseIgnoredDirs            = (1u << 2),
    RPDiffFlagIncludeUntracked              = (1u << 3),
    RPDiffFlagRecurseUntrackedDirs          = (1u << 4),
    RPDiffFlagIncludeUnmodified             = (1u << 5),
    RPDiffFlagIncludeTypechange             = (1u << 6),
    RPDiffFlagIncludeTypechangeTrees        = (1u << 7),
    RPDiffFlagIgnoreFilemode                = (1u << 8),
    RPDiffFlagIgnoreSubmodules              = (1u << 9),
    RPDiffFlagIgnoreCase                    = (1u << 10),
    RPDiffFlagIncludeCasechange             = (1u << 11),
    RPDiffFlagDisablePathspecMatch          = (1u << 12),
    RPDiffFlagSkipBinaryCheck               = (1u << 13),
    RPDiffFlagEnableFastUntrackedDirs       = (1u << 14),
    RPDiffFlagUpdateIndex                   = (1u << 15),
    RPDiffFlagIncludeUnreadable             = (1u << 16),
    RPDiffFlagIncludeUnreadableAsUntracked  = (1u << 17),
    RPDiffFlagForceText                     = (1u << 20),
    RPDiffFlagForceBinary                   = (1u << 21),
    RPDiffFlagIgnoreWhitespace              = (1u << 22),
    RPDiffFlagIgnoreWhitespaceChange        = (1u << 23),
    RPDiffFlagIgnoreWhitespaceEOL           = (1u << 24),
    RPDiffFlagShowUntrackedContext          = (1u << 25),
    RPDiffFlagShowUnmodified                = (1u << 26),
    RPDiffFlagPatience                      = (1u << 28),
    RPDiffFlagMinimal                       = (1 << 29),
    RPDiffFlagShowBinary                    = (1 << 30),
};

@interface RPDiffOptions : NSObject

@property(nonatomic) RPDiffFlag flags;

@end

@interface RPDiff : NSObject

+ (nullable instancetype)diffIndex:(RPIndex *)index
                   toWorkdirInRepo:(RPRepo *)repo
                           options:(nullable RPDiffOptions *)options
                             error:(NSError **)error;

+ (nullable instancetype)diffTree:(RPTree *)tree
                          toIndex:(RPIndex *)index
                           inRepo:(RPRepo *)repo
                          options:(nullable RPDiffOptions *)options
                            error:(NSError **)error;

+ (nullable instancetype)diffTree:(RPTree *)tree
         toWorkdirWithIndexInRepo:(RPRepo *)repo
                          options:(nullable RPDiffOptions *)options
                            error:(NSError **)error;

+ (nullable instancetype)diffNewTree:(RPTree *)newTree
                              inRepo:(RPRepo *)repo
                             options:(nullable RPDiffOptions *)options
                               error:(NSError **)error;

+ (nullable instancetype)diffOldTree:(RPTree *)oldTree
                           toNewTree:(RPTree *)newTree
                              inRepo:(RPRepo *)repo
                             options:(nullable RPDiffOptions *)options
                               error:(NSError **)error;

+ (nullable instancetype)diffOldObject:(RPObject *)oldObject
                           toNewObject:(RPObject *)newObject
                                inRepo:(RPRepo *)repo
                               options:(nullable RPDiffOptions *)options
                                 error:(NSError **)error;

+ (nullable instancetype)diffMergeBaseOfOldObject:(RPObject *)oldObject
                                      toNewObject:(RPObject *)newObject
                                           inRepo:(RPRepo *)repo
                                          options:(nullable RPDiffOptions *)options
                                            error:(NSError **)error;

+ (nullable instancetype)diffPullRequestOfOurObject:(RPObject *)ourObject
                                      toTheirObject:(RPObject *)theirObject
                                             inRepo:(RPRepo *)repo
                                            options:(nullable RPDiffOptions *)options
                                              error:(NSError **)error;

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `diff`.
- (instancetype)initWithGitDiff:(git_diff *)diff
                       location:(RPDiffLocation)location
                      conflicts:(NSArray<RPConflict *> *)conflicts
                           repo:(RPRepo *)repo NS_DESIGNATED_INITIALIZER;

/// Assumes ownership of `diff`.
- (instancetype)initWithGitDiff:(git_diff *)diff location:(RPDiffLocation)location repo:(RPRepo *)repo;

- (void)enumerateDeltasUsingBlock:(RP_NO_ESCAPE void (^)(RPDiffDelta *delta))block;

/// Transform a diff marking file renames, copies, etc.
/// \return YES if the find succeeded, NO if an error occurred.
- (BOOL)findSimilar:(NSError **)error;

@property(nonatomic, readonly) git_diff *gitDiff RP_RETURNS_INTERIOR_POINTER;
@property(nonatomic, readonly) RPDiffLocation location;
@property(nonatomic, strong, readonly) NSArray<RPConflict *> *conflicts;
@property(nonatomic, strong, readonly) RPRepo *repo;

@property(nonatomic, strong, readonly, nullable) RPDiffStats *stats;
@property(nonatomic, readonly) NSUInteger deltaCount;

@end

NS_ASSUME_NONNULL_END
