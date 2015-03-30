//
//  RPReference.m
//  Repo
//
//  Created by Charles Osmer on 2/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPReference.h"

#import "RPObject.h"
#import "NSError+RPGitErrors.h"

#import <git2/buffer.h>
#import <git2/branch.h>
#import <git2/refs.h>
#import <git2/errors.h>

@implementation RPReference

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
    const char *name = NULL;
    if (git_branch_name(&name, self.gitReference) != GIT_OK) {
        return nil;
    }
    
    return (name ? @(name) : nil);
}

- (RPObject *)peelToType:(RPObjectType)type error:(NSError **)error
{
    git_object *object = NULL;
    int gitError = git_reference_peel(&object, self.gitReference, (git_otype)type);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError
                                     description:@"Couldn't peel reference %@ to type %@", self.name, RPObjectTypeName(type)];
        }
        return nil;
    }
    
    return [[RPObject alloc] initWithGitObject:object];
}

@end
