//
//  RPSubmodule.h
//  Repo
//
//  Created by Charles Osmer on 1/6/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPRepo;

typedef struct git_submodule git_submodule;

@interface RPSubmodule : NSObject

/// Assumes ownership of `submodule`.
- (instancetype)initWithGitSubmodule:(git_submodule *)submodule NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithRepo:(RPRepo *)repo path:(NSString *)path error:(NSError **)error;

@property(nonatomic, readonly) git_submodule *gitSubmodule RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, readonly) BOOL isWorkingDirectoryDirty;

@end
