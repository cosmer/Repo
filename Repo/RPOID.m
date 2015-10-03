//
//  RPOID.m
//  Repo
//
//  Created by Charles Osmer on 11/18/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPOID.h"

#import "NSError+RPGitErrors.h"

#import <git2/oid.h>
#import <git2/errors.h>

@interface RPOID () {
    git_oid _oid;
}

@end

@implementation RPOID

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitOID:(const git_oid *)oid
{
    NSParameterAssert(oid != NULL);
    if ((self = [super init])) {
        git_oid_cpy(&_oid, oid);
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string error:(NSError **)error
{
    NSParameterAssert(string != nil);
    
    git_oid oid;
    int gitError = git_oid_fromstr(&oid, string.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Couldn't parse oid '%@'", string];
        }
        return nil;
    }
    
    return [self initWithGitOID:&oid];
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

- (NSString *)stringValue
{
    char buf[GIT_OID_HEXSZ + 1];
    char *p = git_oid_tostr(buf, sizeof(buf), &_oid);
    return [NSString stringWithUTF8String:p];
}

- (NSString *)shortStringValue
{
    return [self.stringValue substringToIndex:7];
}

- (NSString *)description
{
    return self.stringValue;
}

@end
