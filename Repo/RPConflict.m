//
//  RPConflict.m
//  Repo
//
//  Created by Charles Osmer on 2/4/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import "RPConflict.h"

#import "RPOID.h"

#import <git2/errors.h>
#import <git2/index.h>

static RPFileTime MakeFileTime(git_index_time indexTime)
{
    return (RPFileTime){
        .seconds = indexTime.seconds,
        .nanoseconds = indexTime.nanoseconds
    };
}

@implementation RPConflictEntry

- (instancetype)initWithGitIndexEntry:(const git_index_entry *)entry
{
    NSParameterAssert(entry != NULL);
    if ((self = [super init])) {
        _oid = [[RPOID alloc] initWithGitOID:&entry->id];
        _path = [[NSString alloc] initWithUTF8String:entry->path ?: ""];
        _mode = entry->mode;
        _mtime = MakeFileTime(entry->mtime);
        _ctime = MakeFileTime(entry->ctime);
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ oid = %@, path = %@, mode = %@ }",
            self.oid.shortStringValue, self.path, RPFileModeName(self.mode)];
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
    NSParameterAssert(ancestor || ours || theirs);

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

@end
