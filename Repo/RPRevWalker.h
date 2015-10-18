//
//  RPRevWalker.h
//  Repo
//
//  Created by Charles Osmer on 10/18/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPOID;

typedef struct git_revwalk git_revwalk;
typedef struct git_oid git_oid;

NS_ASSUME_NONNULL_BEGIN

@interface RPRevWalker : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `revwalk`.
- (instancetype)initWithGitRevWalk:(git_revwalk *)revwalk NS_DESIGNATED_INITIALIZER;

- (nullable RPOID *)next;
- (BOOL)nextGitOID:(git_oid *)oid;

@property(nonatomic, readonly) git_revwalk *gitRevwalk RP_RETURNS_INTERIOR_POINTER;

@end

NS_ASSUME_NONNULL_END