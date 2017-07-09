//
//  RPCleanup.m
//  Repo
//
//  Created by Charles Osmer on 7/9/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import "RPCleanup.h"

#import <git2/odb.h>

void cleanup_git_odb_free(git_odb **odb)
{
    git_odb_free(*odb);
}
