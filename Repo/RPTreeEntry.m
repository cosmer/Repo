//
//  RPTreeEntry.m
//  Repo
//
//  Created by Charles Osmer on 12/29/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import "RPTreeEntry.h"

#import "RPOID.h"

#import <git2/tree.h>

@implementation RPTreeEntry

- (instancetype)initWithGitTreeEntry:(const git_tree_entry *)entry
{
    NSParameterAssert(entry != NULL);
    if ((self = [super init])) {
        _oid = [[RPOID alloc] initWithGitOID:git_tree_entry_id(entry)];
        _name = @(git_tree_entry_name(entry) ?: "");
        _objectType = (RPObjectType)git_tree_entry_type(entry);
        _fileMode = (RPFileMode)git_tree_entry_filemode(entry);
    }
    return self;
}

@end
