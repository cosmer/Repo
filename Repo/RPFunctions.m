//
//  RPFunctions.m
//  Repo
//
//  Created by Charles Osmer on 8/28/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPFunctions.h"

#import <git2/oid.h>
#import <git2/checkout.h>
#import <git2/stash.h>
#import <git2/tag.h>

static int stash_callback(size_t index, const char* message, const git_oid *stash_id, void *payload)
{
    stash_block block = (__bridge stash_block)payload;
    return block(index, message, stash_id);
}

int git_stash_foreach_block(git_repository *repo, stash_block block)
{
    return git_stash_foreach(repo, stash_callback, (__bridge void *)block);
}

static int tag_callback(const char *name, git_oid *oid, void *payload)
{
    tag_block block = (__bridge tag_block)payload;
    return block(name, oid);
}

int git_tag_foreach_block(git_repository *repo, tag_block block)
{
    return git_tag_foreach(repo, tag_callback, (__bridge void *)block);
}
