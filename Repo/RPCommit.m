//
//  RPCommit.m
//  Repo
//
//  Created by Charles Osmer on 4/20/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPCommit.h"

#import "RPOID.h"
#import "RPRepo.h"
#import "RPSignature.h"
#import "RPTree.h"
#import "NSError+RPGitErrors.h"

#import <git2/commit.h>
#import <git2/errors.h>

static NSStringEncoding stringEncodingWithName(const char *name)
{
    if (name) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)@(name));
        if (encoding != kCFStringEncodingInvalidId) {
            return CFStringConvertNSStringEncodingToEncoding(encoding);
        }
    }
    return NSUTF8StringEncoding;
}

@interface RPCommit () {
    RPOID *_oid;
}

@end

@implementation RPCommit

+ (instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(repo != nil);
    
    git_commit *commit = NULL;
    int gitError = git_commit_lookup(&commit, repo.gitRepository, oid.gitOID);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[RPCommit alloc] initWithGitCommit:commit];
}

- (void)dealloc
{
    git_commit_free(_gitCommit);
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitCommit:(git_commit *)commit
{
    NSParameterAssert(commit != nil);
    if ((self = [super init])) {
        _gitCommit = commit;
    }
    return self;
}

- (NSString *)message
{
    const char *message = git_commit_message(self.gitCommit);
    if (!message) {
        return nil;
    }
    
    const char *encodingName = git_commit_message_encoding(self.gitCommit);
    const NSStringEncoding encoding = stringEncodingWithName(encodingName);

    return [[NSString alloc] initWithCString:message encoding:encoding];
}

- (NSString *)summary
{
    const char *summary = git_commit_summary(self.gitCommit);
    if (!summary) {
        return nil;
    }
    
    const char *encodingName = git_commit_message_encoding(self.gitCommit);
    const NSStringEncoding encoding = stringEncodingWithName(encodingName);
    
    return [[NSString alloc] initWithCString:summary encoding:encoding];
}

- (RPSignature *)author
{
    const git_signature *sig = git_commit_author(self.gitCommit);
    return [[RPSignature alloc] initWithGitSignature:sig];
}

- (RPSignature *)committer
{
    const git_signature *sig = git_commit_committer(self.gitCommit);
    return [[RPSignature alloc] initWithGitSignature:sig];
}

- (int64_t)time
{
    return git_commit_time(self.gitCommit);
}

- (NSInteger)parentCount
{
    return git_commit_parentcount(self.gitCommit);
}

- (RPOID *)oid
{
    if (!_oid) {
        const git_oid *oid = git_commit_id(self.gitCommit);
        _oid = [[RPOID alloc] initWithGitOID:oid];
    }

    return _oid;
}

- (RPOID *)treeOID
{
    const git_oid *oid = git_commit_tree_id(self.gitCommit);
    return [[RPOID alloc] initWithGitOID:oid];
}

- (RPCommit *)parentAtIndex:(NSInteger)index error:(NSError **)error
{
    if (index < 0 || index >= self.parentCount) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid parent index (%@)", @(index)];
    }

    git_commit *parent = NULL;
    int gitError = git_commit_parent(&parent, self.gitCommit, (unsigned int)index);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    
    return [[RPCommit alloc] initWithGitCommit:parent];
}

- (RPOID *)parentOIDAtIndex:(NSInteger)index
{
    const git_oid *oid = git_commit_parent_id(self.gitCommit, (unsigned int)index);
    if (!oid) {
        return nil;
    }
    return [[RPOID alloc] initWithGitOID:oid];
}

- (RPTree *)tree:(NSError **)error
{
    git_tree *tree = NULL;
    int gitError = git_commit_tree(&tree, self.gitCommit);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    return [[RPTree alloc] initWithGitTree:tree];
}

@end
