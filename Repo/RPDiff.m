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
#import "NSError+RPGitErrors.h"

#import <git2/diff.h>
#import <git2/revparse.h>
#import <git2/errors.h>

@implementation RPDiff

- (void)dealloc
{
    git_diff_free(_gitDiff);
}

+ (instancetype)diffIndexToWorkdirInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);
    
    git_diff_options options = GIT_DIFF_OPTIONS_INIT;
    options.flags = GIT_DIFF_INCLUDE_UNTRACKED | GIT_DIFF_RECURSE_UNTRACKED_DIRS | GIT_DIFF_IGNORE_CASE;
    
    git_diff *diff = NULL;
    int gitError = git_diff_index_to_workdir(&diff, repo.gitRepository, NULL, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to diff index to working directory"];
        }
        return nil;
    }
    
    return [[self alloc] initWithGitDiff:diff repo:repo];
}

+ (instancetype)diffHeadToWorkdirWithIndexInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);
    
    int gitError = GIT_OK;
    
    git_object *object = NULL;
    gitError = git_revparse_single(&object, repo.gitRepository, "HEAD^{tree}");
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to parse rev for HEAD"];
        }
        return nil;
    }
    
    git_tree *tree = NULL;
    gitError = git_tree_lookup(&tree, repo.gitRepository, git_object_id(object));
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to create tree for HEAD"];
        }
        
        git_object_free(object);
        return nil;
    }
    
    git_diff_options options = GIT_DIFF_OPTIONS_INIT;
    options.flags = GIT_DIFF_INCLUDE_UNTRACKED | GIT_DIFF_RECURSE_UNTRACKED_DIRS | GIT_DIFF_IGNORE_CASE;
    
    git_diff *diff = NULL;
    gitError = git_diff_tree_to_workdir_with_index(&diff, repo.gitRepository, tree, &options);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to diff head to working directory with index"];
        }
        
        git_tree_free(tree);
        git_object_free(object);
        return nil;
    }
    
    git_tree_free(tree);
    git_object_free(object);
    
    return [[self alloc] initWithGitDiff:diff repo:repo];
}

- (instancetype)initWithGitDiff:(git_diff *)diff repo:(RPRepo *)repo
{
    NSParameterAssert(diff != nil);
    NSParameterAssert(repo != nil);
    if ((self = [super init])) {
        _gitDiff = diff;
        _repo = repo;
    }
    return self;
}

- (NSUInteger)deltaCount
{
    return git_diff_num_deltas(self.gitDiff);
}

- (void)enumerateDeltasUsingBlock:(void (^)(RPDiffDelta *delta))block
{
    NSParameterAssert(block != nil);
    
    NSUInteger count = self.deltaCount;
    for (NSUInteger i = 0; i < count; ++i) {
        RPDiffDelta *delta = [[RPDiffDelta alloc] initWithDiff:self deltaIndex:i];
        block(delta);
    }
}

@end
