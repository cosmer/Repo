//
//  RPDiffDelta+Private.h
//  Repo
//
//  Created by Charles Osmer on 1/4/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <git2/diff.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPDiffDelta ()

- (instancetype)init NS_UNAVAILABLE;

/// Does not assume ownership of `delta`.
- (instancetype)initWithGitDiffDelta:(const git_diff_delta *)delta NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
