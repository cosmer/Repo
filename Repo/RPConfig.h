//
//  RPConfig.h
//  Repo
//
//  Created by Charles Osmer on 1/26/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

#pragma clang assume_nonnull begin

@class RPRepo;

typedef struct git_config git_config;

@interface RPConfig : NSObject

/// Assumes ownership of `config`.
- (instancetype)initWithGitConfig:(git_config *)config NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithRepo:(RPRepo *)repo error:(NSError **)error;

/// \return String value, or nil if no value is set.
- (nullable NSString *)stringWithName:(NSString *)name;

@property(nonatomic, readonly) git_config *gitConfig RP_RETURNS_INTERIOR_POINTER;

@end

#pragma clang assume_nonnull end
