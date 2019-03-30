//
//  RPDiff.m
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPDiff.h"

#import "RPRepo.h"
#import "RPRepo+Merge.h"
#import "RPDiffDelta.h"
#import "RPOID.h"
#import "RPObject.h"
#import "RPTree.h"
#import "RPCommit.h"
#import "RPIndex.h"
#import "RPDiffStats.h"
#import "RPConflict.h"
#import "RPDiffFindOptions+Private.h"
#import "NSError+RPGitErrors.h"

#import <git2/diff.h>
#import <git2/branch.h>
#import <git2/index.h>
#import <git2/errors.h>

_Static_assert(RPDiffFlagNormal == GIT_DIFF_NORMAL, "");
_Static_assert(RPDiffFlagReverse == GIT_DIFF_REVERSE, "");
_Static_assert(RPDiffFlagIncludeIgnored == GIT_DIFF_INCLUDE_IGNORED, "");
_Static_assert(RPDiffFlagRecurseIgnoredDirs == GIT_DIFF_RECURSE_IGNORED_DIRS, "");
_Static_assert(RPDiffFlagIncludeUntracked == GIT_DIFF_INCLUDE_UNTRACKED, "");
_Static_assert(RPDiffFlagRecurseUntrackedDirs == GIT_DIFF_RECURSE_UNTRACKED_DIRS, "");
_Static_assert(RPDiffFlagIncludeUnmodified == GIT_DIFF_INCLUDE_UNMODIFIED, "");
_Static_assert(RPDiffFlagIncludeTypechange == GIT_DIFF_INCLUDE_TYPECHANGE, "");
_Static_assert(RPDiffFlagIncludeTypechangeTrees == GIT_DIFF_INCLUDE_TYPECHANGE_TREES, "");
_Static_assert(RPDiffFlagIgnoreFilemode == GIT_DIFF_IGNORE_FILEMODE, "");
_Static_assert(RPDiffFlagIgnoreSubmodules == GIT_DIFF_IGNORE_SUBMODULES, "");
_Static_assert(RPDiffFlagIgnoreCase == GIT_DIFF_IGNORE_CASE, "");
_Static_assert(RPDiffFlagIncludeCasechange == GIT_DIFF_INCLUDE_CASECHANGE, "");
_Static_assert(RPDiffFlagDisablePathspecMatch == GIT_DIFF_DISABLE_PATHSPEC_MATCH, "");
_Static_assert(RPDiffFlagSkipBinaryCheck == GIT_DIFF_SKIP_BINARY_CHECK, "");
_Static_assert(RPDiffFlagEnableFastUntrackedDirs == GIT_DIFF_ENABLE_FAST_UNTRACKED_DIRS, "");
_Static_assert(RPDiffFlagUpdateIndex == GIT_DIFF_UPDATE_INDEX, "");
_Static_assert(RPDiffFlagIncludeUnreadable == GIT_DIFF_INCLUDE_UNREADABLE, "");
_Static_assert(RPDiffFlagIncludeUnreadableAsUntracked == GIT_DIFF_INCLUDE_UNREADABLE_AS_UNTRACKED, "");
_Static_assert(RPDiffFlagForceText == GIT_DIFF_FORCE_TEXT, "");
_Static_assert(RPDiffFlagForceBinary == GIT_DIFF_FORCE_BINARY, "");
_Static_assert(RPDiffFlagIgnoreWhitespace == GIT_DIFF_IGNORE_WHITESPACE, "");
_Static_assert(RPDiffFlagIgnoreWhitespaceChange == GIT_DIFF_IGNORE_WHITESPACE_CHANGE, "");
_Static_assert(RPDiffFlagIgnoreWhitespaceEOL == GIT_DIFF_IGNORE_WHITESPACE_EOL, "");
_Static_assert(RPDiffFlagShowUntrackedContext == GIT_DIFF_SHOW_UNTRACKED_CONTENT, "");
_Static_assert(RPDiffFlagShowUnmodified == GIT_DIFF_SHOW_UNMODIFIED, "");
_Static_assert(RPDiffFlagPatience == GIT_DIFF_PATIENCE, "");
_Static_assert(RPDiffFlagMinimal == GIT_DIFF_MINIMAL, "");
_Static_assert(RPDiffFlagShowBinary == GIT_DIFF_SHOW_BINARY, "");
_Static_assert(RPDiffFlagIndentHeuristic == GIT_DIFF_INDENT_HEURISTIC, "");

static git_diff_options makeGitDiffOptions(RPDiffOptions *options)
{
    git_diff_options gitOptions = GIT_DIFF_OPTIONS_INIT;
    if (!options) {
        return gitOptions;
    }

    gitOptions.flags = options.flags;

    NSArray<NSString *> *pathspecs = options.pathspecs;
    if (pathspecs.count > 0) {
        const size_t count = (size_t)pathspecs.count;
        gitOptions.pathspec.count = count;
        gitOptions.pathspec.strings = calloc(count, sizeof(char *));

        for (size_t i = 0; i < count; i++) {
            gitOptions.pathspec.strings[i] = strdup(pathspecs[i].UTF8String);
        }
    }

    return gitOptions;
}

static void cleanupGitDiffOptions(git_diff_options *options)
{
    if (options->pathspec.count > 0) {
        for (size_t i = 0; i < options->pathspec.count; i++) {
            free(options->pathspec.strings[i]);
        }

        free(options->pathspec.strings);
    }
}

#define CLEANUP_DIFF_OPTIONS __attribute__ ((__cleanup__(cleanupGitDiffOptions)))

@implementation RPDiff

- (void)dealloc
{
    git_diff_free(_gitDiff);
}

+ (instancetype)diffIndex:(RPIndex *)index
          toWorkdirInRepo:(RPRepo *)repo
                  options:(RPDiffOptions *)options
                    error:(NSError **)error
{
    NSParameterAssert(index != nil);
    NSParameterAssert(repo != nil);
    
    CLEANUP_DIFF_OPTIONS git_diff_options gitOptions = makeGitDiffOptions(options);
    
    git_diff *diff = NULL;
    int gitError = git_diff_index_to_workdir(&diff, repo.gitRepository, index.gitIndex, &gitOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    NSArray *conflicts = [RPConflict conflictsFromGitIndex:index.gitIndex];
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationWorkdir conflicts:conflicts repo:repo];
}

+ (instancetype)diffTree:(RPTree *)tree
                 toIndex:(RPIndex *)index
                  inRepo:(RPRepo *)repo
                 options:(RPDiffOptions *)options
                   error:(NSError **)error
{
    NSParameterAssert(tree != nil);
    NSParameterAssert(index != nil);
    NSParameterAssert(repo != nil);
    
    git_index_read(index.gitIndex, 0);
    
    CLEANUP_DIFF_OPTIONS git_diff_options gitOptions = makeGitDiffOptions(options);

    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_index(&diff, repo.gitRepository, tree.gitTree, index.gitIndex, &gitOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    NSArray *conflicts = [RPConflict conflictsFromGitIndex:index.gitIndex];
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationIndex conflicts:conflicts repo:repo];
}

+ (nullable instancetype)diffTree:(RPTree *)tree
         toWorkdirWithIndexInRepo:(RPRepo *)repo
                          options:(RPDiffOptions *)options
                            error:(NSError **)error
{
    NSParameterAssert(tree != nil);
    NSParameterAssert(repo != nil);

    CLEANUP_DIFF_OPTIONS git_diff_options gitOptions = makeGitDiffOptions(options);

    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_workdir_with_index(&diff, repo.gitRepository, tree.gitTree, &gitOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationWorkdirWithIndex repo:repo];
}

+ (instancetype)diffNewTree:(RPTree *)newTree
                     inRepo:(RPRepo *)repo
                    options:(RPDiffOptions *)options
                      error:(NSError **)error
{
    NSParameterAssert(newTree != nil);
    
    CLEANUP_DIFF_OPTIONS git_diff_options gitOptions = makeGitDiffOptions(options);
    
    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_tree(&diff, repo.gitRepository, NULL, newTree.gitTree, &gitOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationOther repo:repo];}

+ (instancetype)diffOldTree:(RPTree *)oldTree
                  toNewTree:(RPTree *)newTree
                     inRepo:(RPRepo *)repo
                    options:(RPDiffOptions *)options
                      error:(NSError **)error
{
    NSParameterAssert(oldTree != nil);
    NSParameterAssert(newTree != nil);
    
    CLEANUP_DIFF_OPTIONS git_diff_options gitOptions = makeGitDiffOptions(options);
    
    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_tree(&diff, repo.gitRepository, oldTree.gitTree, newTree.gitTree, &gitOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationOther repo:repo];
}

+ (instancetype)diffOldTreeOID:(RPOID *)oldOID
                  toNewTreeOID:(RPOID *)newOID
                        inRepo:(RPRepo *)repo
                       options:(RPDiffOptions *)options
                         error:(NSError **)error
{
    NSParameterAssert(oldOID != nil);
    NSParameterAssert(newOID != nil);
    
    RPTree *oldTree = [RPTree lookupOID:oldOID inRepo:repo error:error];
    if (!oldTree) {
        return nil;
    }
    
    RPTree *newTree = [RPTree lookupOID:newOID inRepo:repo error:error];
    if (!newTree) {
        return nil;
    }

    return [self diffOldTree:oldTree toNewTree:newTree inRepo:repo options:options error:error];
}

+ (instancetype)diffOldObject:(RPObject *)oldObject
                  toNewObject:(RPObject *)newObject
                       inRepo:(RPRepo *)repo
                      options:(RPDiffOptions *)options
                        error:(NSError **)error
{
    RPObject *oldTree = [oldObject peelToType:RPObjectTypeTree error:error];
    if (!oldTree) {
        return nil;
    }
    
    RPObject *newTree = [newObject peelToType:RPObjectTypeTree error:error];
    if (!newTree) {
        return nil;
    }
    
    return [self diffOldTreeOID:oldTree.OID toNewTreeOID:newTree.OID inRepo:repo options:options error:error];
}

+ (instancetype)diffMergeBaseOfOldObject:(RPObject *)oldObject
                             toNewObject:(RPObject *)newObject
                                  inRepo:(RPRepo *)repo
                                 options:(RPDiffOptions *)options
                                   error:(NSError **)error
{
    RPObject *oldCommit = [oldObject peelToType:RPObjectTypeCommit error:error];
    if (!oldCommit) {
        return nil;
    }
    
    RPObject *newCommit = [newObject peelToType:RPObjectTypeCommit error:error];
    if (!newCommit) {
        return nil;
    }
    
    RPOID *mergeBaseOID = [repo mergeBaseOfOID:oldCommit.OID withOID:newCommit.OID error:error];
    if (!mergeBaseOID) {
        return nil;
    }
    
    RPObject *mergeBaseCommit = [RPObject lookupOID:mergeBaseOID withType:RPObjectTypeCommit inRepo:repo error:error];
    if (!mergeBaseCommit) {
        return nil;
    }
    
    RPObject *oldTreeObject = [mergeBaseCommit peelToType:RPObjectTypeTree error:error];
    if (!oldTreeObject) {
        return nil;
    }
    
    RPObject *newTreeObject = [newObject peelToType:RPObjectTypeTree error:error];
    if (!newTreeObject) {
        return nil;
    }
    
    return [self diffOldTreeOID:oldTreeObject.OID toNewTreeOID:newTreeObject.OID inRepo:repo options:options error:error];
}

+ (instancetype)diffPullRequestOfOurObject:(RPObject *)ourObject
                             toTheirObject:(RPObject *)theirObject
                                    inRepo:(RPRepo *)repo
                                   options:(RPDiffOptions *)options
                                     error:(NSError **)error
{
    RPObject *theirCommitObject = [theirObject peelToType:RPObjectTypeCommit error:error];
    if (!theirCommitObject) {
        return nil;
    }
    
    RPObject *ourCommitObject = [ourObject peelToType:RPObjectTypeCommit error:error];
    if (!ourCommitObject) {
        return nil;
    }
    
    RPCommit *theirCommit = [RPCommit lookupOID:theirCommitObject.OID inRepo:repo error:error];
    if (!theirCommit) {
        return nil;
    }
    
    RPCommit *ourCommit = [RPCommit lookupOID:ourCommitObject.OID inRepo:repo error:error];
    if (!ourCommit) {
        return nil;
    }
    
    RPObject *treeObject = [ourObject peelToType:RPObjectTypeTree error:error];
    if (!treeObject) {
        return nil;
    }
    
    RPTree *tree = [RPTree lookupOID:treeObject.OID inRepo:repo error:error];
    if (!tree) {
        return nil;
    }

    RPMergeOptions *mergeOptions = [[RPMergeOptions alloc] init];
    mergeOptions.flags = RPMergeFlagSkipREUC;

    RPIndex *index = [repo mergeOurCommit:ourCommit withTheirCommit:theirCommit options:mergeOptions error:error];
    if (!index) {
        return nil;
    }
    
    CLEANUP_DIFF_OPTIONS git_diff_options gitDiffOptions = makeGitDiffOptions(options);
    
    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_index(&diff, repo.gitRepository, tree.gitTree, index.gitIndex, &gitDiffOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    NSArray *conflicts = [RPConflict conflictsFromGitIndex:index.gitIndex];
    return [[RPDiff alloc] initWithGitDiff:diff location:RPDiffLocationOther conflicts:conflicts repo:repo];
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitDiff:(git_diff *)diff
                       location:(RPDiffLocation)location
                      conflicts:(NSArray<RPConflict *> *)conflicts
                           repo:(RPRepo *)repo
{
    NSParameterAssert(diff != nil);
    NSParameterAssert(conflicts != nil);
    NSParameterAssert(repo != nil);
    if ((self = [super init])) {
        _gitDiff = diff;
        _location = location;
        _conflicts = [conflicts copy];
        _repo = repo;
    }
    return self;
}

- (instancetype)initWithGitDiff:(git_diff *)diff location:(RPDiffLocation)location repo:(RPRepo *)repo
{
    return [self initWithGitDiff:diff location:location conflicts:@[] repo:repo];
}

- (RPDiffStats *)stats
{
    git_diff_stats *stats = NULL;
    if (git_diff_get_stats(&stats, self.gitDiff) != GIT_OK) {
        return nil;
    }
    
    return [[RPDiffStats alloc] initWithGitDiffStats:stats];
}

- (NSUInteger)deltaCount
{
    return git_diff_num_deltas(self.gitDiff);
}

- (void)enumerateDeltasUsingBlock:(RP_NO_ESCAPE void (^)(RPDiffDelta *delta))block
{
    NSParameterAssert(block != nil);
    
    RPDiffLocation location = self.location;
    NSUInteger count = self.deltaCount;
    for (NSUInteger i = 0; i < count; ++i) {
        RPDiffDelta *delta = [[RPDiffDelta alloc] initWithDiff:self deltaIndex:i location:location];
        block(delta);
    }
}

- (BOOL)findSimilarWithOptions:(nullable RPDiffFindOptions *)options error:(NSError **)error
{
    git_diff_find_options gitOptions = GIT_DIFF_FIND_OPTIONS_INIT;
    if (options) {
        gitOptions = options.gitOptions;
    }

    int gitError = git_diff_find_similar(self.gitDiff, &gitOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return NO;
    }
    return YES;
}

@end

@implementation RPDiffOptions

- (instancetype)init
{
    if ((self = [super init])) {
        _pathspecs = @[];
    }
    return self;
}

@end
