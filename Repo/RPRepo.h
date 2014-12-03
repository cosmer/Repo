//
//  RPRepo.h
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

typedef struct git_repository git_repository;

@interface RPRepo : NSObject

/// \return YES if there appears to be a git repository at `url`.
+ (BOOL)isRepositoryAtURL:(NSURL *)url;

/// Should be called once at startup before any other methods in the framework.
+ (NSError *)startup;

- (instancetype)initWithGitRepository:(git_repository *)repository NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error;

@property(nonatomic, readonly) git_repository *gitRepository RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) NSString *path;
@property(nonatomic, strong, readonly) NSString *workingDirectory;

@end
