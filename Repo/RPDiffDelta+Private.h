//
//  RPDiffDelta+Private.h
//  Repo
//
//  Created by Charles Osmer on 1/4/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <git2/diff.h>

#import "RPTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface RPDiffDelta ()

/// Does not assume ownership of `delta`.
- (instancetype)initWithGitDiffDelta:(const git_diff_delta *)delta location:(RPDiffLocation)location NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
