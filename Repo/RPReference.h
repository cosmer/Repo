//
//  RPReference.h
//  Repo
//
//  Created by Charles Osmer on 2/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPTypes.h"
#import "RPMacros.h"

@class RPObject;

NS_ASSUME_NONNULL_BEGIN

typedef struct git_reference git_reference;

@interface RPReference : NSObject

/// Assumes ownership of `reference`.
- (instancetype)initWithGitReference:(git_reference *)reference NS_DESIGNATED_INITIALIZER;

- (nullable RPObject *)peelToType:(RPObjectType)type error:(NSError **)error;

@property(nonatomic, readonly) git_reference *gitReference RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, strong, readonly) NSString *shortName;

@end

NS_ASSUME_NONNULL_END
