//
//  RPBlob.m
//  Repo
//
//  Created by Charles Osmer on 11/21/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPBlob.h"

#import "RPRepo.h"
#import "RPOID.h"
#import "NSString+RPEncoding.h"
#import "NSError+RPGitErrors.h"

#import <git2/blob.h>
#import <git2/errors.h>

@interface RPBlob ()

@property(nonatomic, readonly) git_blob *gitBlob;
@property(nonatomic, readonly) git_off_t size;

@end

@implementation RPBlob

- (void)dealloc
{
    git_object_free(_gitObject);
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

- (instancetype)initWithGitObject:(git_object *)object inRepo:(RPRepo *)repo
{
    NSParameterAssert(object != NULL);
    NSParameterAssert(repo != nil);
    if ((self = [super init])) {
        _gitObject = object;
        _repo = repo;
    }
    return self;
}

- (instancetype)initWithOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(repo != nil);
    
    git_object *object = NULL;
    int gitError = git_object_lookup(&object, repo.gitRepository, oid.gitOID, GIT_OBJ_BLOB);
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to lookup blob %@", oid];
        }
        return nil;
    }
    
    return [self initWithGitObject:object inRepo:repo];
}

- (git_blob *)gitBlob
{
    return (git_blob *)self.gitObject;
}

- (git_off_t)size
{
    return git_blob_rawsize(self.gitBlob);
}

- (NSData *)data
{
    const void *content = git_blob_rawcontent(self.gitBlob);
    return [NSData dataWithBytes:content length:self.size];
}

- (NSString *)stringWithPreferredEncoding:(const NSStringEncoding *)preferredEncoding usedEncoding:(NSStringEncoding *)usedEncoding
{
    if (self.size <= 0) {
        if (usedEncoding) {
            *usedEncoding = (preferredEncoding ? *preferredEncoding : NSUTF8StringEncoding);
        }
        return @"";
    }
    
    void *content = (void *)git_blob_rawcontent(self.gitBlob);
    NSData *data = [NSData dataWithBytesNoCopy:content length:self.size freeWhenDone:NO];
    
    return [NSString rp_stringWithData:data preferredEncoding:preferredEncoding usedEncoding:usedEncoding];
}

@end
