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
#import "RPFunctions.h"
#import "Utilities.h"

#import <git2/errors.h>

#define TAGS_PREFIX "refs/tags/"

static const char *extract_shortname(const char *name)
{
    const char *shortname = remove_prefix(name, TAGS_PREFIX);
    return shortname ? shortname : name;
}

@implementation RPTag

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

@end
