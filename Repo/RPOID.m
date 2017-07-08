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

#define ELF_STEP(B) T1 = (H << 4) + B; T2 = T1 & 0xF0000000; if (T2) T1 ^= (T2 >> 24); T1 &= (~T2); H = T1;

static CFHashCode HashBytes(const uint8_t *bytes, SInt32 length)
{
    /* The ELF hash algorithm, used in the ELF object file format */
    UInt32 H = 0, T1, T2;
    SInt32 rem = length;
    while (3 < rem) {
        ELF_STEP(bytes[length - rem]);
        ELF_STEP(bytes[length - rem + 1]);
        ELF_STEP(bytes[length - rem + 2]);
        ELF_STEP(bytes[length - rem + 3]);
        rem -= 4;
    }
    switch (rem) {
        case 3:  ELF_STEP(bytes[length - 3]);
        case 2:  ELF_STEP(bytes[length - 2]);
        case 1:  ELF_STEP(bytes[length - 1]);
        case 0:  ;
    }
    return H;
}

#undef ELF_STEP

@interface RPOID () {
    git_oid _oid;
}

@end

@implementation RPOID

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithGitOID:(const git_oid *)oid length:(NSInteger)length
{
    NSParameterAssert(oid != NULL);
    NSParameterAssert(length > 0);
    NSParameterAssert(length <= GIT_OID_HEXSZ);
    if ((self = [super init])) {
        git_oid_cpy(&_oid, oid);
        _length = length;
    }
    return self;
}

- (instancetype)initWithGitOID:(const git_oid *)oid
{
    return [self initWithGitOID:oid length:GIT_OID_HEXSZ];
}

- (instancetype)initWithString:(NSString *)string error:(NSError **)error
{
    NSParameterAssert(string != nil);
    
    git_oid oid;
    int gitError = git_oid_fromstrp(&oid, string.UTF8String);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [self initWithGitOID:&oid length:GIT_OID_HEXSZ];
}

- (nullable instancetype)initWithPartialString:(NSString *)string error:(NSError **)error
{
    NSParameterAssert(string != nil);
    
    const char *utf8 = string.UTF8String;
    if (!utf8) {
        if (error) {
            *error = [NSError rp_repoErrorWithDescription:@"Couldn't parse oid %@", string];
        }
        return nil;
    }
    
    git_oid oid;
    int gitError = git_oid_fromstrp(&oid, utf8);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    NSInteger length = strlen(utf8);
    return [self initWithGitOID:&oid length:length];
}

- (const git_oid *)gitOID
{
    return &_oid;
}

- (NSComparisonResult)compare:(RPOID *)oid
{
    NSParameterAssert(oid != nil);
    
    const int r = git_oid_cmp(self.gitOID, oid.gitOID);
    if (r < 0) {
        return NSOrderedAscending;
    }
    if (r > 0) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (BOOL)hasPrefix:(RPOID *)oid
{
    NSParameterAssert(oid != nil);
    
    if (oid.length <= 0 || self.length <= 0) {
        return NO;
    }
    
    if (oid.length > self.length) {
        return NO;
    }
    
    return git_oid_ncmp(self.gitOID, oid.gitOID, oid.length) == 0;
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
    return HashBytes(self.gitOID->id, GIT_OID_RAWSZ);
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
    return [NSString stringWithFormat:@"%@ (%@)", self.stringValue, @(self.length)];
}

@end
