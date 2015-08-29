//
//  RPStash.m
//  Repo
//
//  Created by Charles Osmer on 8/20/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPStash.h"

#import "RPRepo.h"
#import "RPOID.h"
#import "RPFunctions.h"
#import "NSError+RPGitErrors.h"

#import <git2/oid.h>
#import <git2/checkout.h>
#import <git2/stash.h>
#import <git2/errors.h>

@implementation RPStash

+ (NSArray<RPStash *> *)stashesInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSMutableArray *stashes = [[NSMutableArray alloc] init];
    int gitError = git_stash_foreach_block(repo.gitRepository, ^int(size_t index, const char *message, const git_oid *stash_id) {
        RPOID *oid = [[RPOID alloc] initWithGitOID:stash_id];
        RPStash *stash = [[RPStash alloc] initWithIndex:index message:@(message) oid:oid];
        [stashes addObject:stash];
        return 0;
    });
    
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to enumerate stashes"];
        }
        return nil;
    }
    
    return stashes;
}


+ (BOOL)dropStashWithCommitOID:(RPOID *)commitOID inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(commitOID != nil);
    NSParameterAssert(repo != nil);
    
    __block size_t stashIndex = 0;
    int gitError = git_stash_foreach_block(repo.gitRepository, ^int(size_t index, const char *message, const git_oid *stash_id) {
        (void)message; // silence unused parameter warning
        
        if (git_oid_cmp(commitOID.gitOID, stash_id) == 0) {
            stashIndex = index;
            return GIT_EUSER;
        }
        
        return 0;
    });
    
    if (gitError != GIT_EUSER) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Couldn't find stash with oid %@", commitOID];
        }
        return NO;
    }
    
    return [self dropStashAtIndex:stashIndex inRepo:repo error:error];
}

+ (BOOL)dropStashAtIndex:(size_t)index inRepo:(RPRepo *)repo error:(NSError **)error
{
    int gitError = git_stash_drop(repo.gitRepository, index);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to drop stash at index %@", @(index)];
        }
        return NO;
    }
    return YES;
}

- (instancetype)initWithIndex:(size_t)index message:(NSString *)message oid:(RPOID *)oid
{
    NSParameterAssert(message != nil);
    NSParameterAssert(oid != nil);
    if ((self = [super init])) {
        _index = index;
        _message = [message copy];
        _commitOID = oid;
    }
    return self;
}

@end
