//
//  RPRepo.h
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class RPReference;

typedef struct git_repository git_repository;

@interface RPRepo : NSObject

/// \return YES if there appears to be a git repository at `url`.
+ (BOOL)isRepositoryAtURL:(NSURL *)url;

/// Should be called once at startup before any other methods in the framework.
+ (nullable NSError *)startup;

/// Assumes ownership of `repository`.
- (instancetype)initWithGitRepository:(git_repository *)repository NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithURL:(NSURL *)url error:(NSError **)error;

/// Get the value of the 'encoding' attributes.
/// \return A string encoding name, or nil if no attribute is set for `path`.
- (nullable NSString *)stringEncodingNameForPath:(NSString *)path;

/// \return The reference pointed at by HEAD.
- (nullable RPReference *)head;

@property(nonatomic, readonly) git_repository *gitRepository RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) NSString *path;
@property(nonatomic, strong, readonly) NSString *workingDirectory;

@end

NS_ASSUME_NONNULL_END
