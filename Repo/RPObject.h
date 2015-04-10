//
//  RPObject.h
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"
#import "RPTypes.h"

@class RPOID;
@class RPRepo;

typedef struct git_object git_object;

NS_ASSUME_NONNULL_BEGIN

@interface RPObject : NSObject

+ (nullable instancetype)lookupOID:(RPOID *)oid withType:(RPObjectType)type inRepo:(RPRepo *)repo error:(NSError **)error;

/// Assumes ownership of `gitObject`.
- (instancetype)initWithGitObject:(git_object *)gitObject NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)peelToType:(RPObjectType)type error:(NSError **)error;

@property(nonatomic, readonly) git_object *gitObject RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) RPOID *OID;

@end

NS_ASSUME_NONNULL_END
