//
//  RPOID.m
//  Repo
//
//  Created by Charles Osmer on 11/18/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPOID.h"

#import <git2/oid.h>

@interface RPOID () {
    git_oid _oid;
}

@end

@implementation RPOID

- (instancetype)initWithGitOID:(const git_oid *)oid
{
    if ((self = [super init])) {
        git_oid_cpy(&_oid, oid);
    }
    return self;
}

- (const git_oid *)gitOID
{
    return &_oid;
}

@end
