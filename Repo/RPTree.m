//
//  RPTree.m
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPTree.h"

#import "RPOID.h"
#import "RPRepo.h"
#import "NSError+RPGitErrors.h"

#import <git2/tree.h>
#import <git2/errors.h>

@implementation RPTree

+ (instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(repo != nil);
    
    git_tree *tree = NULL;
    int gitError = git_tree_lookup(&tree, repo.gitRepository, oid.gitOID);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to lookup tree with id %@", oid.stringValue];
        }
        return nil;
    }
    
    return [[self alloc] initWithGitTree:tree];
}

- (void)dealloc
{
    git_tree_free(_gitTree);
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitTree:(git_tree *)tree
{
    NSParameterAssert(tree != NULL);
    if ((self = [super init])) {
        _gitTree = tree;
    }
    return self;
}

- (RPOID *)oid
{
    const git_oid *oid = git_tree_id(self.gitTree);
    return [[RPOID alloc] initWithGitOID:oid];
}

- (RPOID *)oidOfEntryAtPath:(NSString *)path error:(NSError **)error
{
    NSParameterAssert(path != nil);

    git_tree_entry *entry = NULL;
    int gitError = git_tree_entry_bypath(&entry, self.gitTree, path.UTF8String);
    if (gitError != GIT_OK) {
        if (gitError == GIT_ENOTFOUND) {
            return [[RPOID alloc] init];
        }

        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    const git_oid *gitOID = git_tree_entry_id(entry);
    RPOID *oid = [[RPOID alloc] initWithGitOID:gitOID];

    git_tree_entry_free(entry);

    return oid;
}

@end
