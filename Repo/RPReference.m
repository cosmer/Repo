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
#import "NSError+RPGitErrors.h"

#import <git2/buffer.h>
#import <git2/refs.h>
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

- (void)dealloc
{
    git_reference_free(_gitReference);
}

- (instancetype)initWithGitReference:(git_reference *)reference
{
    NSParameterAssert(reference != NULL);
    if ((self = [super init])) {
        _gitReference = reference;
    }
    return self;
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

@end
