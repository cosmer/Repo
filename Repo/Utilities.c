//
//  Utilities.c
//  Repo
//
//  Created by Charles Osmer on 4/25/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#include "Utilities.h"

#include <stdlib.h>
#include <assert.h>

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
