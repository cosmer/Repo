//
//  RPDiffFindOptions.m
//  Repo
//
//  Created by Charles Osmer on 1/28/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import "RPDiffFindOptions.h"
#import "RPDiffFindOptions+Private.h"

#import <git2/diff.h>

_Static_assert(GIT_DIFF_FIND_BY_CONFIG == RPDiffFindFlagFindByConfig, "");
_Static_assert(GIT_DIFF_FIND_RENAMES  ==RPDiffFindFlagFindRenames, "");
_Static_assert(GIT_DIFF_FIND_RENAMES_FROM_REWRITES  == RPDiffFindFlagFindRenamesFromRewrites, "");
_Static_assert(GIT_DIFF_FIND_COPIES == RPDiffFindFlagFindCopies, "");
_Static_assert(GIT_DIFF_FIND_COPIES_FROM_UNMODIFIED == RPDiffFindFlagFindCopiesFromUnmodified, "");
_Static_assert(GIT_DIFF_FIND_REWRITES == RPDiffFindFlagFindRewrites, "");
_Static_assert(GIT_DIFF_BREAK_REWRITES == RPDiffFindFlagBreakRewrites, "");
_Static_assert(GIT_DIFF_FIND_FOR_UNTRACKED == RPDiffFindFlagFindForUntracked, "");
_Static_assert(GIT_DIFF_FIND_ALL == RPDiffFindFlagFindAll, "");
_Static_assert(GIT_DIFF_FIND_IGNORE_LEADING_WHITESPACE == RPDiffFindFlagIgnoreLeadingWhitespace, "");
_Static_assert(GIT_DIFF_FIND_IGNORE_WHITESPACE == RPDiffFindFlagIgnoreWhitespace, "");
_Static_assert(GIT_DIFF_FIND_DONT_IGNORE_WHITESPACE == RPDiffFindFlagDontIgnoreWhitespace, "");
_Static_assert(GIT_DIFF_FIND_EXACT_MATCH_ONLY == RPDiffFindFlagExactMatchOnly, "");
_Static_assert(GIT_DIFF_BREAK_REWRITES_FOR_RENAMES_ONLY == RPDiffFindFlagBreakRewritesForRenamesOnly, "");
_Static_assert(GIT_DIFF_FIND_REMOVE_UNMODIFIED == RPDiffFindFlagRemoveUnmodified, "");

@implementation RPDiffFindOptions

- (git_diff_find_options)gitOptions
{
    git_diff_find_options options = GIT_DIFF_FIND_OPTIONS_INIT;
    options.flags = self.flags;
    options.rename_threshold = self.renameThreshold;
    options.rename_from_rewrite_threshold = self.renameFromRewriteThreshold;
    options.copy_threshold = self.copyThreshold;
    options.break_rewrite_threshold = self.breakRewriteThreshold;
    options.rename_limit = self.renameLimit;
    options.max_file_size = self.maxFileSize;
    return options;
}

@end
