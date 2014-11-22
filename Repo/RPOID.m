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

- (BOOL)isZero
{
    return git_oid_iszero(self.gitOID) != 0;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }

    if (![object isKindOfClass:RPOID.class]) {
        return NO;
    }
    
    RPOID *other = object;
    return git_oid_equal(self.gitOID, other.gitOID) != 0;
}

- (NSUInteger)hash
{
    return [[NSData dataWithBytesNoCopy:(void *)self.gitOID->id length:GIT_OID_RAWSZ freeWhenDone:NO] hash];
}

@end
