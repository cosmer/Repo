//
//  RPRevWalker.h
//  Repo
//
//  Created by Charles Osmer on 10/18/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPRepo;
@class RPOID;

typedef struct git_revwalk git_revwalk;
typedef struct git_oid git_oid;

typedef NS_OPTIONS(NSUInteger, RPRevWalkSortOptions) {
    RPRevWalkSortOptionsTopological    = 1 << 0,
    RPRevWalkSortOptionsTime           = 1 << 1,
    RPRevWalkSortOptionsReverse        = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface RPRevWalker : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `revwalk`.
- (instancetype)initWithGitRevWalk:(git_revwalk *)revwalk NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithRepo:(RPRepo *)repo error:(NSError **)error;

- (nullable RPOID *)next;
- (BOOL)nextGitOID:(git_oid *)oid;

- (BOOL)pushCommit:(RPOID *)oid error:(NSError **)error;
- (BOOL)pushReference:(NSString *)reference error:(NSError **)error;

- (BOOL)hideCommit:(RPOID *)oid error:(NSError **)error;

- (void)sortBy:(RPRevWalkSortOptions)options;

/// No parents other than the first for each commit will be enumerated.
- (void)simplifyFirstParent;

/// Count commits by repeatedly calling `next`.
- (NSInteger)count;

@property(nonatomic, readonly) git_revwalk *gitRevwalk RP_RETURNS_INTERIOR_POINTER;

@end

NS_ASSUME_NONNULL_END
