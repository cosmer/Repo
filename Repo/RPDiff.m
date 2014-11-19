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
#import <git2/errors.h>

@implementation RPDiff

- (void)dealloc
{
    git_diff_free(_gitDiff);
}

+ (instancetype)diffIndexToWorkingDirectoryInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);
    
    git_diff *diff = NULL;
    git_diff_options diffOptions = GIT_DIFF_OPTIONS_INIT;
    diffOptions.flags = GIT_DIFF_INCLUDE_UNTRACKED | GIT_DIFF_IGNORE_CASE;
    int gitError = git_diff_index_to_workdir(&diff, repo.gitRepository, NULL, &diffOptions);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to diff index to working directory"];
        }
        return nil;
    }
    
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
