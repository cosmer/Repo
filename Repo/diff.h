//
//  diff.h
//  Repo
//
//  Created by Charles Osmer on 6/6/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#ifndef __Repo__diff__
#define __Repo__diff__

#include <git2/types.h>

int show_conflicts(git_repository *repo, git_index *index, const char *our_name, const char *their_name);

#endif /* defined(__Repo__diff__) */
