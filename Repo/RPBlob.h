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

typedef struct git_object git_object;

@interface RPBlob : NSObject

/// Assumes ownership of `object`.
- (instancetype)initWithGitObject:(git_object *)object inRepo:(RPRepo *)repo NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

- (nullable NSString *)stringWithPreferredEncoding:(nullable const NSStringEncoding *)preferredEncoding
                                      usedEncoding:(nullable NSStringEncoding *)usedEncoding;

@property(nonatomic, readonly) git_object *gitObject RP_RETURNS_INTERIOR_POINTER;
@property(nonatomic, strong, readonly) RPRepo *repo;

@end

NS_ASSUME_NONNULL_END
