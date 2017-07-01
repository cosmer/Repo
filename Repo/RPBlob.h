//
//  RPBlob.h
//  Repo
//
//  Created by Charles Osmer on 11/21/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class RPRepo;
@class RPOID;
@class RPCommit;

typedef struct git_object git_object;

@interface RPBlob : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `object`.
- (instancetype)initWithGitObject:(git_object *)object inRepo:(RPRepo *)repo NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

- (nullable instancetype)initWithCommit:(RPCommit *)commit path:(NSString *)path inRepo:(RPRepo *)repo error:(NSError **)error;

@property(nonatomic, readonly) git_object *gitObject RP_RETURNS_INTERIOR_POINTER;
@property(nonatomic, strong, readonly) RPRepo *repo;

@property(nonatomic, readonly) int64_t rawSize;
@property(nonatomic, readonly) const char *rawContent RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) NSData *data;

@end

NS_ASSUME_NONNULL_END
