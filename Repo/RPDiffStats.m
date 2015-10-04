//
//  RPDiffStats.m
//  Repo
//
//  Created by Charles Osmer on 10/4/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPDiffStats.h"

#import <git2/diff.h>

@implementation RPDiffStats

- (void)dealloc
{
    git_diff_stats_free(_gitStats);
}

- (instancetype)initWithGitDiffStats:(git_diff_stats *)stats
{
    NSParameterAssert(stats != NULL);
    if ((self = [super init])) {
        _gitStats = stats;
    }
    return self;
}

- (size_t)filesChanged
{
    return git_diff_stats_files_changed(self.gitStats);
}

- (size_t)insertions
{
    return git_diff_stats_insertions(self.gitStats);
}

- (size_t)deletions
{
    return git_diff_stats_deletions(self.gitStats);
}

@end
