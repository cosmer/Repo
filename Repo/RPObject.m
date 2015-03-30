//
//  RPObject.m
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPObject.h"

#import "RPOID.h"

#import <git2/object.h>

@implementation RPObject

- (void)dealloc
{
    git_object_free(_gitObject);
}

- (instancetype)initWithGitObject:(git_object *)gitObject
{
    NSParameterAssert(gitObject != NULL);
    if ((self = [super init])) {
        _gitObject = gitObject;
    }
    return self;
}

- (RPOID *)OID
{
    const git_oid *oid = git_object_id(self.gitObject);
    return [[RPOID alloc] initWithGitOID:oid];
}

@end
