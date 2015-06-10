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

@end
