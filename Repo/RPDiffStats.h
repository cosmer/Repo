//
//  RPDiffStats.h
//  Repo
//
//  Created by Charles Osmer on 10/4/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

typedef struct git_diff_stats git_diff_stats;

NS_ASSUME_NONNULL_BEGIN

@interface RPDiffStats : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `stats`.
- (instancetype)initWithGitDiffStats:(git_diff_stats *)stats NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) git_diff_stats *gitStats RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, readonly) size_t filesChanged;
@property(nonatomic, readonly) size_t insertions;
@property(nonatomic, readonly) size_t deletions;

@end

NS_ASSUME_NONNULL_END
