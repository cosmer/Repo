//
//  RPConflict.m
//  Repo
//
//  Created by Charles Osmer on 2/4/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import "RPConflict.h"

#import "RPRepo.h"
#import "RPBlob.h"
#import "RPOID.h"
#import "NSError+RPGitErrors.h"

#import <git2/errors.h>
#import <git2/index.h>
#import <git2/merge.h>

@implementation RPConflictEntry

- (instancetype)initWithOID:(RPOID *)oid path:(NSString *)path
{
    NSParameterAssert(oid != nil);
    NSParameterAssert(path != nil);
    if ((self = [super init])) {
        _oid = oid;
        _path = [path copy];
    }
    return self;
}

- (instancetype)initWithGitIndexEntry:(const git_index_entry *)entry
{
    NSParameterAssert(entry != NULL);
    RPOID *oid = [[RPOID alloc] initWithGitOID:&entry->id];
    NSString *path = [[NSString alloc] initWithUTF8String:entry->path ?: ""];
    return [self initWithOID:oid path:path];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ oid = %@, path = %@ }", self.oid.shortStringValue, self.path];
}

@end

@implementation RPConflict

+ (NSArray *)conflictsFromGitIndex:(git_index *)index
{
    NSParameterAssert(index != NULL);
    
    if (!git_index_has_conflicts(index)) {
        return @[];
    }
    
    git_index_conflict_iterator *it = NULL;
    if (git_index_conflict_iterator_new(&it, index) != GIT_OK) {
        return @[];
    }
    
    NSMutableArray *conflicts = [[NSMutableArray alloc] init];
    
    const git_index_entry *gitAncestor = NULL;
    const git_index_entry *gitOurs = NULL;
    const git_index_entry *gitTheirs = NULL;
    while (git_index_conflict_next(&gitAncestor, &gitOurs, &gitTheirs, it) == GIT_OK) {
        RPConflictEntry *ancestor = nil;
        if (gitAncestor) {
            ancestor = [[RPConflictEntry alloc] initWithGitIndexEntry:gitAncestor];
        }
        
        RPConflictEntry *ours = nil;
        if (gitOurs) {
            ours = [[RPConflictEntry alloc] initWithGitIndexEntry:gitOurs];
        }
        
        RPConflictEntry *theirs = nil;
        if (gitTheirs) {
            theirs = [[RPConflictEntry alloc] initWithGitIndexEntry:gitTheirs];
        }
        
        RPConflict *conflict = [[RPConflict alloc] initWithAncestor:ancestor ours:ours theirs:theirs];
        [conflicts addObject:conflict];
    }
    
    git_index_conflict_iterator_free(it);
    
    return conflicts;
}

- (instancetype)initWithAncestor:(RPConflictEntry *)ancestor
                            ours:(RPConflictEntry *)ours
                          theirs:(RPConflictEntry *)theirs
{
    if ((self = [super init])) {
        _ancestor = ancestor;
        _ours = ours;
        _theirs = theirs;
    }
    return self;
}

- (NSString *)description
{
    NSString *ancestor = [NSString stringWithFormat:@"{ ancestor = %@ }", self.ancestor.description];
    NSString *ours = [NSString stringWithFormat:@"{ ours     = %@ }", self.ours.description];
    NSString *theirs = [NSString stringWithFormat:@"{ theirs   = %@ }", self.theirs.description];
    return [@[@"conflict = ", ancestor, ours, theirs] componentsJoinedByString:@",\r"];
}

- (NSData *)mergeInRepo:(RPRepo *)repo error:(NSError **)error
{
    NSParameterAssert(repo != nil);
    
    if (!self.ours) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, missing our side"];
        }
        return nil;
    }
    
    if (!self.theirs) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, missing their side"];
        }
        return nil;
    }
    
    RPBlob *ourBlob = [[RPBlob alloc] initWithOID:self.ours.oid inRepo:repo error:error];
    if (!ourBlob) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, our blob is missing"];
        }
        return nil;
    }
    
    RPBlob *theirBlob = [[RPBlob alloc] initWithOID:self.theirs.oid inRepo:repo error:error];
    if (!theirBlob) {
        if (error) {
            *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, their blob is missing"];
        }
        return nil;
    }
    
    git_merge_file_input ourInput = GIT_MERGE_FILE_INPUT_INIT;
    ourInput.ptr = ourBlob.rawContent;
    ourInput.size = ourBlob.rawSize;
    ourInput.path = self.ours.path.UTF8String;
    
    git_merge_file_input theirInput = GIT_MERGE_FILE_INPUT_INIT;
    theirInput.ptr = theirBlob.rawContent;
    theirInput.size = theirBlob.rawSize;
    theirInput.path = self.theirs.path.UTF8String;
    
    git_merge_file_options options = GIT_MERGE_FILE_OPTIONS_INIT;
    options.flags = GIT_MERGE_FILE_STYLE_DIFF3;
    
    int gitError = GIT_OK;
    git_merge_file_result result = { 0 };
    
    if (self.ancestor) {
        RPBlob *ancestorBlob = [[RPBlob alloc] initWithOID:self.ancestor.oid inRepo:repo error:error];
        if (!ancestorBlob) {
            if (error) {
                *error = [NSError rp_gitErrorForCode:GIT_EUSER description:@"Can't merge conflict, ancestor blob is missing"];
            }
            return nil;
        }
        
        git_merge_file_input ancestorInput = GIT_MERGE_FILE_INPUT_INIT;
        ancestorInput.ptr = ancestorBlob.rawContent;
        ancestorInput.size = ancestorBlob.rawSize;
        ancestorInput.path = self.ancestor.path.UTF8String;
        
        gitError = git_merge_file(&result, &ancestorInput, &ourInput, &theirInput, &options);
    }
    else {
        gitError = git_merge_file(&result, NULL, &ourInput, &theirInput, &options);
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
