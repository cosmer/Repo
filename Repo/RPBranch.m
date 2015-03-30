//
//  RPBranch.m
//  Repo
//
//  Created by Charles Osmer on 3/22/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPBranch.h"

#import "RPRepo.h"
#import "RPReference.h"
#import "NSError+RPGitErrors.h"

#import <git2/errors.h>
#import <git2/types.h>
#import <git2/buffer.h>
#import <git2/branch.h>
#import <git2/refs.h>

@implementation RPBranch

+ (NSArray *)branchesInRepo:(RPRepo *)repo withTypes:(RPBranchType)types error:(NSError **)error
{
    git_branch_iterator *iterator = NULL;
    int gitError = git_branch_iterator_new(&iterator, repo.gitRepository, (git_branch_t)types);
    if (gitError < GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to get branches for repo"];
        }
        return nil;
    }
    
    NSArray *branches = [self branchesFromIterator:iterator];
    git_branch_iterator_free(iterator);
    
    return branches;
}

+ (NSArray *)branchesFromIterator:(git_branch_iterator *)iterator
{
    NSMutableArray *branches = [[NSMutableArray alloc] init];
    
    git_branch_t type = 0;
    git_reference *ref = NULL;
    
    while (git_branch_next(&ref, &type, iterator) == GIT_OK) {
        const char *name = NULL;
        if (git_branch_name(&name, ref) != GIT_OK) {
            git_reference_free(ref);
            continue;
        }
        
        BOOL isHEAD = git_branch_is_head(ref) ? YES : NO;
        
        [branches addObject:[[RPBranch alloc] initWithName:@(name) type:(RPBranchType)type isHEAD:isHEAD]];
        git_reference_free(ref);
    }
    
    return branches;
}

- (instancetype)initWithName:(NSString *)name type:(RPBranchType)type isHEAD:(BOOL)isHEAD
{
    NSParameterAssert(name != nil);
    if ((self = [super init])) {
        _name = name;
        _type = type;
        _isHEAD = isHEAD;
    }
    return self;
}

- (RPReference *)lookupReferenceInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);

    git_reference *ref = NULL;
    int gitError = git_branch_lookup(&ref, repo.gitRepository, self.name.UTF8String, (git_branch_t)self.type);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to lookup reference for branch %@", self.name];
        }
        return nil;
    }
    
    return [[RPReference alloc] initWithGitReference:ref];
}

- (NSString *)description
{
    if (self.isHEAD) {
        return [NSString stringWithFormat:@"Branch { %@, %@, HEAD }", self.name, RPBranchTypeName(self.type)];
    }
    else {
        return [NSString stringWithFormat:@"Branch { %@, %@ }", self.name, RPBranchTypeName(self.type)];
    }
}

@end
