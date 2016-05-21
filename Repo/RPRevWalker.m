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

_Static_assert(RPRevWalkSortOptionsTopological == GIT_SORT_TOPOLOGICAL, "");
_Static_assert(RPRevWalkSortOptionsTime == GIT_SORT_TIME, "");
_Static_assert(RPRevWalkSortOptionsReverse == GIT_SORT_REVERSE, "");

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

- (BOOL)pushCommit:(RPOID *)oid error:(NSError **)error
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

- (BOOL)pushReference:(NSString *)reference error:(NSError **)error
{
    NSParameterAssert(reference != nil);
    int gitError = git_revwalk_push_ref(self.gitRevwalk, reference.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to push reference %@.", reference];
        }
        return NO;
    }
    return YES;
}

- (BOOL)hideCommit:(RPOID *)oid error:(NSError **)error
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

- (void)sortBy:(RPRevWalkSortOptions)options
{
    git_revwalk_sorting(self.gitRevwalk, (unsigned int)options);
}

- (void)simplifyFirstParent
{
    git_revwalk_simplify_first_parent(self.gitRevwalk);
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
