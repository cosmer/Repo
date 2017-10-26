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
@class RPOID;
@class RPIndex;
@class RPObject;
@class RPDiffDelta;

typedef struct git_repository git_repository;

@interface RPRepo : NSObject

/// \return Resolved repository URL, or nil if no repository was found.
+ (nullable NSURL *)discoverRepositoryAtURL:(NSURL *)url;

/// Should be called once at startup before any other methods in the framework.
+ (BOOL)startupWithError:(NSError **)error;

/// Assumes ownership of `repository`.
- (instancetype)initWithGitRepository:(git_repository *)repository NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initWithURL:(NSURL *)url error:(NSError **)error;

/// Get the value of the 'encoding' attributes.
/// \return A string encoding name, or nil if no attribute is set for `path`.
- (nullable NSString *)stringEncodingNameForPath:(NSString *)path;

/// \return The reference pointed at by HEAD.
- (nullable RPReference *)head;

/// \return Index owned by the repository.
- (nullable RPIndex *)indexWithError:(NSError **)error;

/// \return The merge base of two commits.
- (nullable RPOID *)mergeBaseOfOID:(RPOID *)oid1 withOID:(RPOID *)oid2 error:(NSError **)error;

/// Replace a file in the workspace with the version of the file in the index.
- (BOOL)forceCheckoutFileFromIndex:(nullable RPIndex *)index atPath:(NSString *)path error:(NSError **)error;

/// Stage changes in diff delta.
- (BOOL)stageDiffDelta:(RPDiffDelta *)delta error:(NSError **)error;

/// Unstage changes in diff delta.
- (BOOL)unstageDiffDelta:(RPDiffDelta *)delta error:(NSError **)error;

/// Find a single object, as specified by a revision string.
- (nullable RPObject *)parseSingleRevision:(NSString *)spec error:(NSError **)error;

/// \return YES if the submodule's status indicates its working directory is dirty.
- (BOOL)isSubmoduleWorkingDirectoryDirty:(NSString *)path;

@property(nonatomic, readonly) git_repository *gitRepository RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) NSString *path;
@property(nonatomic, strong, readonly) NSString *workingDirectory;

@property(nullable, nonatomic, strong, readonly) NSString *originURL;

@end

NS_ASSUME_NONNULL_END
