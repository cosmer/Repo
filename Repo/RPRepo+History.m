//
//  RPRepo+History.m
//  Repo
//
//  Created by Charles Osmer on 9/2/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPRepo+History.h"

#import <git2/commit.h>
#import <git2/revwalk.h>
#import <git2/errors.h>

@implementation RPRepo (History)

- (BOOL)walkHistoryFromRef:(NSString *)ref callback:(BOOL(^)(RPCommit *))callback error:(NSError **)error
{
    NSParameterAssert(ref != nil);
    NSParameterAssert(callback != nil);
    
    git_revwalk *walk = NULL;
    int gitError = git_revwalk_new(&walk, self.gitRepository);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to create revwalk"];
        }
        return NO;
    }
    
    git_revwalk_sorting(walk, GIT_SORT_TOPOLOGICAL | GIT_SORT_TIME);
    
    gitError = git_revwalk_push_ref(walk, ref.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to walk ref '%@'", ref];
        }
        git_revwalk_free(walk);
        return NO;
    }
    
    while (1) {
        git_oid oid;
        if (git_revwalk_next(&oid, walk) != GIT_OK) {
            break;
        }
        
        git_commit *gitCommit = NULL;
        if (git_commit_lookup(&gitCommit, self.gitRepository, &oid) == GIT_OK) {
            RPCommit *commit = [[RPCommit alloc] initWithGitCommit:gitCommit];
            if (!callback(commit)) {
                break;
            }
        }
    }
    
    git_revwalk_free(walk);
    
    return YES;
}

@end
