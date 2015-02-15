//
//  RPReference.h
//  Repo
//
//  Created by Charles Osmer on 2/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

#pragma clang assume_nonnull begin

typedef struct git_reference git_reference;

@interface RPReference : NSObject

/// Assumes ownership of `reference`.
- (instancetype)initWithGitReference:(git_reference *)reference NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) git_reference *gitReference RP_RETURNS_INTERIOR_POINTER;

@property(nullable, nonatomic, strong, readonly) NSString *name;

@end

#pragma clang assume_nonnull end
