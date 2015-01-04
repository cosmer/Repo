//
//  RPBlob.h
//  Repo
//
//  Created by Charles Osmer on 11/21/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPRepo;
@class RPOID;

typedef struct git_object git_object;

@interface RPBlob : NSObject

/// Assumes ownership of `object`.
- (instancetype)initWithGitObject:(git_object *)object inRepo:(RPRepo *)repo NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

- (NSString *)content;

@property(nonatomic, readonly) git_object *gitObject RP_RETURNS_INTERIOR_POINTER;
@property(nonatomic, strong, readonly) RPRepo *repo;

@end
