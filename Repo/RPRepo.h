//
//  RPRepo.h
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

#pragma clang assume_nonnull begin

typedef struct git_repository git_repository;

@interface RPRepo : NSObject

/// \return YES if there appears to be a git repository at `url`.
+ (BOOL)isRepositoryAtURL:(NSURL *)url;

/// Should be called once at startup before any other methods in the framework.
+ (nullable NSError *)startup;

- (instancetype)initWithGitRepository:(git_repository *)repository NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithURL:(NSURL *)url error:(NSError **)error;

/// Get the value of the 'encoding' attributes.
/// \return A string encoding name, or nil if no attribute is set for `path`.
- (nullable NSString *)stringEncodingNameForPath:(NSString *)path;

@property(nonatomic, readonly) git_repository *gitRepository RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) NSString *path;
@property(nonatomic, strong, readonly) NSString *workingDirectory;

@end

#pragma clang assume_nonnull end
