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
#import "NSError+RPGitErrors.h"

#import <git2/oid.h>
#import <git2/checkout.h>
#import <git2/stash.h>
#import <git2/errors.h>

static int stash_callback(size_t index, const char* cmessage, const git_oid *stash_id, void *payload);

@implementation RPStash

+ (NSArray<RPStash *> *)stashesInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSMutableArray *stashes = [[NSMutableArray alloc] init];
    
    int gitError = git_stash_foreach(repo.gitRepository, stash_callback, (__bridge void *)stashes);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to enumerate stashes"];
        }
        return nil;
    }
    
    return stashes;
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

static int stash_callback(size_t index, const char* cmessage, const git_oid *stash_id, void *payload)
{
    NSString *message = cmessage ? @(cmessage) : @"";
    RPOID *oid = [[RPOID alloc] initWithGitOID:stash_id];
    
    NSMutableArray *stashes = (__bridge NSMutableArray *)payload;
    RPStash *stash = [[RPStash alloc] initWithIndex:index message:message oid:oid];
    [stashes addObject:stash];
    
    return 0;
}
