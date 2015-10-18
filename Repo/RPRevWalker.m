//
//  RPRevWalker.m
//  Repo
//
//  Created by Charles Osmer on 10/18/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPRevWalker.h"

#import "RPOID.h"

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

@end
