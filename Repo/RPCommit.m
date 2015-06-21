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

@implementation RPCommit

+ (instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(repo != nil);
    
    git_commit *commit = NULL;
    int gitError = git_commit_lookup(&commit, repo.gitRepository, oid.gitOID);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to lookup commit %@", oid];
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

@end
