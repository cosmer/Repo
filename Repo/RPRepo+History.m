//
//  RPRepo+History.m
//  Repo
//
//  Created by Charles Osmer on 9/2/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPRepo+History.h"

#import <git2/revwalk.h>
#import <git2/errors.h>

_Static_assert(RPHistorySortOptionsTopological == GIT_SORT_TOPOLOGICAL, "");
_Static_assert(RPHistorySortOptionsTime == GIT_SORT_TIME, "");
_Static_assert(RPHistorySortOptionsReverse == GIT_SORT_REVERSE, "");

@implementation RPRepo (History)

/// Caller is responsible for freeing the revwalk.
- (git_revwalk *)makeRevWalkFromRef:(NSString *)ref sortOptions:(RPHistorySortOptions)options error:(NSError **)error
{
    NSParameterAssert(ref != nil);
    
    git_revwalk *walk = NULL;
    int gitError = git_revwalk_new(&walk, self.gitRepository);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to create revwalk"];
        }
        return NULL;
    }
    
    git_revwalk_sorting(walk, (unsigned int)options);
    
    gitError = git_revwalk_push_ref(walk, ref.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to walk ref '%@'", ref];
        }
        git_revwalk_free(walk);
        return NULL;
    }
    
    return walk;
}

- (RPRevWalker *)revWalkerFromRef:(NSString *)ref sortOptions:(RPHistorySortOptions)options error:(NSError **)error
{
    git_revwalk *walk = [self makeRevWalkFromRef:ref sortOptions:options error:error];
    if (!walk) {
        return nil;
    }
    return [[RPRevWalker alloc] initWithGitRevWalk:walk];
}

@end
