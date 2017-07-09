//
//  RPCleanup.h
//  Repo
//
//  Created by Charles Osmer on 12/11/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

typedef struct git_odb git_odb;

void cleanup_git_odb_free(git_odb **odb);

#define CLEANUP_GIT_BUF __attribute__ ((__cleanup__(git_buf_free)))
#define CLEANUP_GIT_ODB __attribute__ ((__cleanup__(cleanup_git_odb_free)))
