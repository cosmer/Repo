//
//  RPFunctions.h
//  Repo
//
//  Created by Charles Osmer on 8/28/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct git_oid git_oid;
typedef struct git_repository git_repository;

typedef int (^stash_block)(size_t index, const char *message, const git_oid *stash_id);

int git_stash_foreach_block(git_repository *repo, stash_block block);
