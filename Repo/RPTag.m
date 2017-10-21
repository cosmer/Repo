//
//  RPTag.m
//  Repo
//
//  Created by Charles Osmer on 4/24/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import "RPTag.h"

#import "RPRepo.h"
#import "RPOID.h"
#import "RPObject.h"
#import "RPFunctions.h"
#import "Utilities.h"
#import "NSError+RPGitErrors.h"

#import <git2/tag.h>
#import <git2/errors.h>

#define TAGS_PREFIX "refs/tags/"

static const char *extract_shortname(const char *name)
{
    const char *shortname = remove_prefix(name, TAGS_PREFIX);
    return shortname ? shortname : name;
}

@implementation RPTag

+ (nullable instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(repo != nil);

    git_tag *tag = NULL;
    if (git_tag_lookup(&tag, repo.gitRepository, oid.gitOID) != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    return [[RPTag alloc] initWithGitTag:tag];
}

+ (void)enumerateTagsInRepo:(RPRepo *)repo callback:(RPTagCallback)callback
{
    NSParameterAssert(repo != nil);
    NSParameterAssert(callback != nil);
    git_tag_foreach_block(repo.gitRepository, ^int(const char *name, const git_oid *tag_id) {
        const char *shortname = extract_shortname(name);
        RPOID *oid = [[RPOID alloc] initWithGitOID:tag_id];
        return callback(name, shortname, oid) ? GIT_OK : GIT_EUSER;
    });
}

- (void)dealloc
{
    git_tag_free(_gitTag);
}

- (instancetype)initWithGitTag:(git_tag *)tag
{
    NSParameterAssert(tag != NULL);
    if ((self = [super init])) {
        _gitTag = tag;
    }
    return self;
}

- (RPObjectType)targetType
{
    return (RPObjectType)git_tag_target_type(self.gitTag);
}

- (nullable RPObject *)peelWithError:(NSError **)error
{
    git_object *object = NULL;
    if (git_tag_peel(&object, self.gitTag) != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }
    return [[RPObject alloc] initWithGitObject:object];
}

@end
