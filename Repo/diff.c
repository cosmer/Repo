//
//  diff.cpp
//  Repo
//
//  Created by Charles Osmer on 6/6/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#include "diff.h"

#include "vector.h"

#include <git2/errors.h>
#include <git2/index.h>
#include <git2/odb.h>
#include <git2/merge.h>

#include <assert.h>
#include <string.h>

int show_conflicts(git_repository *repo, git_index *index, const char *our_name, const char *their_name)
{
    assert(repo && index && our_name && their_name);
    
    if (!git_index_has_conflicts(index)) {
        return GIT_OK;
    }
    
    int error = GIT_OK;
    
    vector *resolved = vector_init();
    git_index_conflict_iterator *it = NULL;
    git_odb *odb = NULL;
    
    error = git_index_conflict_iterator_new(&it, index);
    if (error != GIT_OK) {
        goto done;
    }
    
    error = git_repository_odb(&odb, repo);
    if (error != GIT_OK) {
        goto done;
    }
    
    git_merge_file_options options = GIT_MERGE_FILE_OPTIONS_INIT;
    options.flags = GIT_MERGE_FILE_STYLE_DIFF3;
    
    options.our_label = our_name;
    options.their_label = their_name;
    options.ancestor_label = "common ancestor";
    
    while (1) {
        const git_index_entry *ancestor = NULL;
        const git_index_entry *ours = NULL;
        const git_index_entry *theirs = NULL;

        int r = git_index_conflict_next(&ancestor, &ours, &theirs, it);
        if (r == GIT_ITEROVER) {
            break;
        }
        
        if (r != GIT_OK) {
            error = r;
            break;
        }
        
        if (!ancestor || !ours || !theirs) {
            continue;
        }
        
        char *path = NULL;
        
        git_merge_file_result result = {0};
        r = git_merge_file_from_index(&result, repo, ancestor, ours, theirs, &options);
        if (r != GIT_OK) {
            goto cleanup;
        }
        
        git_index_entry entry = {{0}};
        entry.file_size = result.len;
        entry.mode = ours->mode;
        
        path = strdup(ours->path ?: "");
        entry.path = path;
        
        r = git_odb_write(&entry.id, odb, result.ptr, result.len, GIT_OBJ_BLOB);
        if (r != GIT_OK) {
            goto cleanup;
        }
        
        r = git_index_add(index, &entry);
        if (r != GIT_OK) {
            goto cleanup;
        }
        
    cleanup:
        
        if (path && r == GIT_OK) {
            vector_append(resolved, path);
        }
        else {
            free(path);
        }
        
        git_merge_file_result_free(&result);
    }
    
done:
    
    for (size_t i = 0; i < vector_size(resolved); i++) {
        git_index_conflict_remove(index, vector_get(resolved, i));
    }
    
    vector_free(resolved);
    git_index_conflict_iterator_free(it);
    git_odb_free(odb);
    
    return error;
}
