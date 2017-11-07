//
//  Utilities.h
//  Repo
//
//  Created by Charles Osmer on 4/25/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLEANUP_GIT_STR_ARRAY __attribute__ ((__cleanup__(free_git_str_array)))

typedef struct git_strarray git_strarray;

const char *remove_prefix(const char *str, const char *prefix);

void copy_to_git_str_array(git_strarray *array, NSArray<NSString *> *strings);
void free_git_str_array(git_strarray *array);
