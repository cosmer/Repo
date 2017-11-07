//
//  Utilities.c
//  Repo
//
//  Created by Charles Osmer on 4/25/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import "Utilities.h"

#import <stdlib.h>
#import <assert.h>

#import <git2/strarray.h>

const char *remove_prefix(const char *string, const char *prefix)
{
    assert(string != NULL);
    assert(prefix != NULL);

    if (!*prefix) {
        return string;
    }

    for (; *prefix && *string; ++prefix, ++string) {
        if (*prefix != *string) {
            return NULL;
        }
    }

    if (!*string && *prefix) {
        return NULL;
    }

    return string;
}

void copy_to_git_str_array(git_strarray *array, NSArray<NSString *> *strings)
{
    if (strings.count > 0) {
        array->count = (size_t)strings.count;
        array->strings = malloc(strings.count*sizeof(array->strings[0]));

        for (NSUInteger i = 0; i < strings.count; i++) {
            array->strings[i] = strdup(strings[i].UTF8String);
        }
    }
    else {
        array->count = 0;
        array->strings = NULL;
    }
}

void free_git_str_array(git_strarray *array)
{
    if (!array) {
        return;
    }

    if (array->strings) {
        for (size_t i = 0; i < array->count; i++) {
            free(array->strings[i]);
        }

        free(array->strings);
    }

    array->count = 0;
    array->strings = NULL;
}
