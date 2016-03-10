//
//  RPRevWalker.m
//  Repo
//
//  Created by Charles Osmer on 10/18/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPRevWalker.h"

#import "RPOID.h"
#import "RPRepo.h"
#import "NSError+RPGitErrors.h"

#import <git2/revwalk.h>
#import <git2/errors.h>

@implementation RPRevWalker

- (void)dealloc
{
    git_revwalk_free(_gitRevwalk);
}

- (instancetype)initWithGitRevWalk:(git_revwalk *)revwalk
{
    NSParameterAssert(revwalk != NULL);
    if ((self = [super init])) {
        _gitRevwalk = revwalk;
    }
    return self;
}

- (instancetype)initWithRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);
    
    git_revwalk *revwalk = NULL;
    int gitError = git_revwalk_new(&revwalk, repo.gitRepository);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to create revwalk."];
        }
        return nil;
    }
    
    return [self initWithGitRevWalk:revwalk];
}

- (RPOID *)next
{
    git_oid oid;
    if (git_revwalk_next(&oid, self.gitRevwalk) != GIT_OK) {
        return nil;
    }
    
    return [[RPOID alloc] initWithGitOID:&oid];
}

- (BOOL)nextGitOID:(git_oid *)oid
{
    NSParameterAssert(oid != NULL);
    if (git_revwalk_next(oid, self.gitRevwalk) != GIT_OK) {
        return NO;
    }
    
    return YES;
}

- (BOOL)push:(RPOID *)oid error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    int gitError = git_revwalk_push(self.gitRevwalk, oid.gitOID);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to push commit %@.", oid];
        }
        return NO;
    }
    return YES;
}

- (BOOL)hide:(RPOID *)oid error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    int gitError = git_revwalk_hide(self.gitRevwalk, oid.gitOID);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to hide commit %@.", oid];
        }
        return NO;
    }
    return YES;
}

- (NSInteger)count
{
    NSInteger count = 0;
    while (true) {
        git_oid oid;
        if (git_revwalk_next(&oid, self.gitRevwalk) != GIT_OK) {
            break;
        }
        count += 1;
    }
    return count;
}

@end
