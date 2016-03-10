//
//  RPReference.m
//  Repo
//
//  Created by Charles Osmer on 2/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPReference.h"

#import "RPRepo.h"
#import "RPObject.h"
#import "RPOID.h"
#import "NSError+RPGitErrors.h"

#import <git2/buffer.h>
#import <git2/refs.h>
#import <git2/branch.h>
#import <git2/errors.h>

@implementation RPReference

+ (instancetype)lookupName:(NSString *)name inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(name != nil);
    NSParameterAssert(repo != nil);
    
    git_reference *ref = NULL;
    int gitError = git_reference_lookup(&ref, repo.gitRepository, name.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to lookup reference %@", name];
        }
        return nil;
    }
    
    return [[RPReference alloc] initWithGitReference:ref];
}

+ (NSArray<RPReference *> *)referencesInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);

    git_reference_iterator *it = NULL;
    int gitError = git_reference_iterator_new(&it, repo.gitRepository);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to get references in repo"];
        }
        return nil;
    }
    
    NSMutableArray<RPReference *> *references = [[NSMutableArray alloc] init];
    
    git_reference *ref = NULL;
    while (true) {
        int r = git_reference_next(&ref, it);
        if (r != GIT_OK) {
            break;
        }
        
        [references addObject:[[RPReference alloc] initWithGitReference:ref]];
        ref = NULL;
    }
    
    return references;
}

- (void)dealloc
{
    git_reference_free(_gitReference);
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitReference:(git_reference *)reference
{
    NSParameterAssert(reference != NULL);
    if ((self = [super init])) {
        _gitReference = reference;
    }
    return self;
}

- (BOOL)isSymbolic
{
    return (git_reference_type(self.gitReference) == GIT_REF_SYMBOLIC);
}

- (NSString *)name
{
    const char *name = git_reference_name(self.gitReference);
    return (name ? @(name) : @"");
}

- (NSString *)shortName
{
    const char *name = git_reference_shorthand(self.gitReference);
    return (name ? @(name) : @"");
}

- (RPOID *)oid
{
    const git_oid *oid = git_reference_target(self.gitReference);
    if (!oid) {
        return nil;
    }
    return [[RPOID alloc] initWithGitOID:oid];
}

- (RPReferenceNamespace)referenceNamespace
{
    if (git_reference_is_remote(self.gitReference)) {
        return RPReferenceNamespaceRemote;
    }
    
    if (git_reference_is_branch(self.gitReference)) {
        return RPReferenceNamespaceBranch;
    }
    
    if (git_reference_is_tag(self.gitReference)) {
        return RPReferenceNamespaceTag;
    }
    
    if (git_reference_is_note(self.gitReference)) {
        return RPReferenceNamespaceNote;
    }
    
    return RPReferenceNamespaceUnknown;
}

- (RPObject *)peelToType:(RPObjectType)type error:(NSError **)error
{
    git_object *object = NULL;
    int gitError = git_reference_peel(&object, self.gitReference, (git_otype)type);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError
                                     description:@"Couldn't peel reference %@ to type %@", self.shortName, RPObjectTypeName(type)];
        }
        return nil;
    }
    
    return [[RPObject alloc] initWithGitObject:object];
}

- (RPReference *)resolve
{
    git_reference *resolved = NULL;
    if (git_reference_resolve(&resolved, self.gitReference) != GIT_OK) {
        return nil;
    }

    return [[RPReference alloc] initWithGitReference:resolved];
}

- (RPReference *)upstream
{
    git_reference *upstream = NULL;
    if (git_branch_upstream(&upstream, self.gitReference) != GIT_OK) {
        return nil;
    }
    
    return [[RPReference alloc] initWithGitReference:upstream];
}

@end
