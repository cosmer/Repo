//
//  RPDiff.m
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPDiff.h"

#import "RPRepo.h"
#import "RPDiffDelta.h"
#import "RPOID.h"
#import "RPObject.h"
#import "RPTree.h"
#import "RPCommit.h"
#import "RPIndex.h"
#import "RPDiffStats.h"
#import "RPConflict.h"
#import "NSError+RPGitErrors.h"

#import <git2/diff.h>
#import <git2/branch.h>
#import <git2/index.h>
#import <git2/errors.h>

static git_diff_options defaultDiffOptions(void)
{
    git_diff_options options = GIT_DIFF_OPTIONS_INIT;
    options.flags = GIT_DIFF_PATIENCE | GIT_DIFF_INCLUDE_UNTRACKED | GIT_DIFF_RECURSE_UNTRACKED_DIRS | GIT_DIFF_IGNORE_CASE;
    return options;
}

@implementation RPDiff

- (void)dealloc
{
    git_diff_free(_gitDiff);
}

+ (instancetype)diffIndex:(RPIndex *)index toWorkdirInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(index != nil);
    NSParameterAssert(repo != nil);
    
    git_diff_options options = defaultDiffOptions();
    
    git_diff *diff = NULL;
    int gitError = git_diff_index_to_workdir(&diff, repo.gitRepository, index.gitIndex, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    NSArray *conflicts = [RPConflict conflictsFromGitIndex:index.gitIndex];
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationWorkdir conflicts:conflicts repo:repo];
}

+ (instancetype)diffTree:(RPTree *)tree toIndex:(RPIndex *)index inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);
    
    git_index_read(index.gitIndex, 0);
    
    git_diff_options options = defaultDiffOptions();
    
    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_index(&diff, repo.gitRepository, tree.gitTree, index.gitIndex, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    NSArray *conflicts = [RPConflict conflictsFromGitIndex:index.gitIndex];
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationIndex conflicts:conflicts repo:repo];
}

+ (instancetype)diffNewTree:(RPTree *)newTree inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(newTree != nil);
    
    git_diff_options options = defaultDiffOptions();
    
    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_tree(&diff, repo.gitRepository, NULL, newTree.gitTree, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationOther repo:repo];}

+ (instancetype)diffOldTree:(RPTree *)oldTree toNewTree:(RPTree *)newTree inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oldTree != nil);
    NSParameterAssert(newTree != nil);
    
    git_diff_options options = defaultDiffOptions();
    
    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_tree(&diff, repo.gitRepository, oldTree.gitTree, newTree.gitTree, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[self alloc] initWithGitDiff:diff location:RPDiffLocationOther repo:repo];
}

+ (instancetype)diffOldTreeOID:(RPOID *)oldOID toNewTreeOID:(RPOID *)newOID inRepo:(RPRepo *)repo error:(NSError **)error
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

    return [self diffOldTree:oldTree toNewTree:newTree inRepo:repo error:error];
}

+ (instancetype)diffOldObject:(RPObject *)oldObject
                  toNewObject:(RPObject *)newObject
                       inRepo:(RPRepo *)repo
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
    
    return [self diffOldTreeOID:oldTree.OID toNewTreeOID:newTree.OID inRepo:repo error:error];
}

+ (instancetype)diffMergeBaseOfOldObject:(RPObject *)oldObject
                             toNewObject:(RPObject *)newObject
                                  inRepo:(RPRepo *)repo
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
    
    return [self diffOldTreeOID:oldTreeObject.OID toNewTreeOID:newTreeObject.OID inRepo:repo error:error];
}

+ (instancetype)diffPullRequestOfOurObject:(RPObject *)ourObject
                             toTheirObject:(RPObject *)theirObject
                                    inRepo:(RPRepo *)repo
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
    
    RPIndex *index = [repo mergeOurCommit:ourCommit withTheirCommit:theirCommit error:error];
    if (!index) {
        return nil;
    }
    
    git_diff_options options = defaultDiffOptions();
    
    git_diff *diff = NULL;
    int gitError = git_diff_tree_to_index(&diff, repo.gitRepository, tree.gitTree, index.gitIndex, &options);
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

- (void)enumerateDeltasUsingBlock:(void (^)(RPDiffDelta *delta))block
{
    NSParameterAssert(block != nil);
    
    RPDiffLocation location = self.location;
    NSUInteger count = self.deltaCount;
    for (NSUInteger i = 0; i < count; ++i) {
        RPDiffDelta *delta = [[RPDiffDelta alloc] initWithDiff:self deltaIndex:i location:location];
        block(delta);
    }
}

- (BOOL)findSimilar:(NSError **)error
{
    git_diff_find_options options = GIT_DIFF_FIND_OPTIONS_INIT;
    options.flags = GIT_DIFF_FIND_RENAMES | GIT_DIFF_FIND_FOR_UNTRACKED;
    
    int gitError = git_diff_find_similar(self.gitDiff, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return NO;
    }
    return YES;
}

@end
