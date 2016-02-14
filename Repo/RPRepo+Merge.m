//
//  RPRepo+Merge.m
//  Repo
//
//  Created by Charles Osmer on 2/14/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import "RPRepo+Merge.h"

#import "RPBlob.h"
#import "RPConflict.h"
#import "RPOID.h"
#import "NSError+RPGitErrors.h"

#import <git2/errors.h>
#import <git2/merge.h>

_Static_assert(RPMergeFileFlagDefault == GIT_MERGE_FILE_DEFAULT, "");
_Static_assert(RPMergeFileFlagStyleMerge == GIT_MERGE_FILE_STYLE_MERGE, "");
_Static_assert(RPMergeFileFlagStyleDiff3 == GIT_MERGE_FILE_STYLE_DIFF3, "");
_Static_assert(RPMergeFileFlagSimplifyAlnum == GIT_MERGE_FILE_SIMPLIFY_ALNUM, "");
_Static_assert(RPMergeFileFlagIgnoreWhitespace == GIT_MERGE_FILE_IGNORE_WHITESPACE, "");
_Static_assert(RPMergeFileFlagIgnoreWhitespaceChange == GIT_MERGE_FILE_IGNORE_WHITESPACE_CHANGE, "");
_Static_assert(RPMergeFileFlagIgnoreWhitespaceEOL == GIT_MERGE_FILE_IGNORE_WHITESPACE_EOL, "");
_Static_assert(RPMergeFileFlagDiffPatience == GIT_MERGE_FILE_DIFF_PATIENCE, "");
_Static_assert(RPMergeFileFlagDiffMinimal == GIT_MERGE_FILE_DIFF_MINIMAL, "");

@implementation RPRepo (Merge)

- (NSData *)mergeConflictEntriesWithAncestor:(RPConflictEntry *)ancestor
                                        ours:(RPConflictEntry *)ours
                                      theirs:(RPConflictEntry *)theirs
                                     options:(RPMergeFileOptions *)options
                                       error:(NSError **)error
{
    NSParameterAssert(ours != nil);
    NSParameterAssert(theirs != nil);
    
    RPBlob *ourBlob = [[RPBlob alloc] initWithOID:ours.oid inRepo:self error:error];
    if (!ourBlob) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, our blob is missing"];
        }
        return nil;
    }
    
    RPBlob *theirBlob = [[RPBlob alloc] initWithOID:theirs.oid inRepo:self error:error];
    if (!theirBlob) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, their blob is missing"];
        }
        return nil;
    }
    
    git_merge_file_input ourInput = GIT_MERGE_FILE_INPUT_INIT;
    ourInput.ptr = ourBlob.rawContent;
    ourInput.size = ourBlob.rawSize;
    ourInput.path = ours.path.UTF8String;
    
    git_merge_file_input theirInput = GIT_MERGE_FILE_INPUT_INIT;
    theirInput.ptr = theirBlob.rawContent;
    theirInput.size = theirBlob.rawSize;
    theirInput.path = theirs.path.UTF8String;
    
    git_merge_file_options gitOptions = GIT_MERGE_FILE_OPTIONS_INIT;
    gitOptions.flags = options.flags;
    gitOptions.ancestor_label = options.ancestorLabel.UTF8String;
    gitOptions.our_label = options.ourLabel.UTF8String;
    gitOptions.their_label = options.theirLabel.UTF8String;
    
    int gitError = GIT_OK;
    git_merge_file_result result = { 0 };
    
    if (ancestor) {
        RPBlob *ancestorBlob = [[RPBlob alloc] initWithOID:ancestor.oid inRepo:self error:error];
        if (!ancestorBlob) {
            if (error) {
                *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, ancestor blob is missing"];
            }
            return nil;
        }
        
        git_merge_file_input ancestorInput = GIT_MERGE_FILE_INPUT_INIT;
        ancestorInput.ptr = ancestorBlob.rawContent;
        ancestorInput.size = ancestorBlob.rawSize;
        ancestorInput.path = ancestor.path.UTF8String;
        
        gitError = git_merge_file(&result, &ancestorInput, &ourInput, &theirInput, &gitOptions);
    }
    else {
        gitError = git_merge_file(&result, NULL, &ourInput, &theirInput, &gitOptions);
    }
    
    if (gitError != GIT_OK) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:gitError description:@"Failed to merge conflict"];
        }
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:result.ptr length:result.len];
    git_merge_file_result_free(&result);
    
    return data;
}

@end

@implementation RPMergeFileOptions

@end
