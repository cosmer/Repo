//
//  RPCleanup.h
//  Repo
//
//  Created by Charles Osmer on 12/11/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#define CLEANUP_GIT_BUF __attribute__ ((__cleanup__(git_buf_free)))
