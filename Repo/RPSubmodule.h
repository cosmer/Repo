//
//  RPSubmodule.h
//  Repo
//
//  Created by Charles Osmer on 1/6/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class RPRepo;

typedef struct git_submodule git_submodule;

@interface RPSubmodule : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `submodule`.
- (instancetype)initWithGitSubmodule:(git_submodule *)submodule NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithRepo:(RPRepo *)repo path:(NSString *)path error:(NSError **)error;

- (nullable RPRepo *)openWithError:(NSError **)error;

@property(nonatomic, readonly) git_submodule *gitSubmodule RP_RETURNS_INTERIOR_POINTER;

@end

NS_ASSUME_NONNULL_END
