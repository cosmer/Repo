//
//  RPCommitWalker.m
//  Repo
//
//  Created by Charles Osmer on 10/18/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPCommitWalker.h"

#import "RPRepo.h"
#import "RPRevWalker.h"
#import "RPCommit.h"

#import <git2/commit.h>
#import <git2/errors.h>

@implementation RPCommitWalker

- (instancetype)initWithRevWalker:(RPRevWalker *)revWalker repo:(RPRepo *)repo
{
    NSParameterAssert(revWalker != nil);
    NSParameterAssert(repo != nil);
    if (self = [super init]) {
        _revWalker = revWalker;
        _repo = repo;
    }
    return self;
}

- (RPCommit *)next
{
    git_oid oid;
    if (![self.revWalker nextGitOID:&oid]) {
        return NO;
    }

    git_commit *commit = NULL;
    if (git_commit_lookup(&commit, self.repo.gitRepository, &oid) != GIT_OK) {
        return nil;
    }
    
    return [[RPCommit alloc] initWithGitCommit:commit];
}

@end
