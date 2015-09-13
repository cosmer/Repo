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

+ (nullable instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `commit`.
- (instancetype)initWithGitCommit:(git_commit *)commit NS_DESIGNATED_INITIALIZER;

/// \return The first parent of `self` or nil.
- (nullable RPCommit *)lookupParent:(NSError **)error;

@property(nonatomic, readonly) git_commit *gitCommit RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, copy, readonly, nullable) NSString *message;
@property(nonatomic, copy, readonly, nullable) NSString *summary;
@property(nonatomic, copy, readonly) NSString *author;
@property(nonatomic, copy, readonly) NSDate *date;
@property(nonatomic, readonly) NSInteger parentCount;

@property(nonatomic, strong, readonly) RPOID *oid;

@end

NS_ASSUME_NONNULL_END
