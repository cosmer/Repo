//
//  RPObject.h
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPOID;

typedef struct git_object git_object;

NS_ASSUME_NONNULL_BEGIN

@interface RPObject : NSObject

/// Assumes ownership of `gitObject`.
- (instancetype)initWithGitObject:(git_object *)gitObject NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) git_object *gitObject RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) RPOID *OID;

@end

NS_ASSUME_NONNULL_END
