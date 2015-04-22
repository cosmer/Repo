//
//  RPCommit.h
//  Repo
//
//  Created by Charles Osmer on 4/20/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPOID;
@class RPRepo;

typedef struct git_commit git_commit;

NS_ASSUME_NONNULL_BEGIN

@interface RPCommit : NSObject

+ (instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

/// Assumes ownership of `commit`.
- (instancetype)initWithGitCommit:(git_commit *)commit NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) git_commit *gitCommit RP_RETURNS_INTERIOR_POINTER;

@end

NS_ASSUME_NONNULL_END
