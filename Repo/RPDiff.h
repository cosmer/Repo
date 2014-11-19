//
//  RPDiff.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPRepo;
@class RPDiffDelta;

typedef struct git_diff git_diff;

@interface RPDiff : NSObject

+ (instancetype)diffIndexToWorkingDirectoryInRepo:(RPRepo *)repo error:(NSError **)error;

- (instancetype)initWithGitDiff:(git_diff *)diff repo:(RPRepo *)repo NS_DESIGNATED_INITIALIZER;

- (void)enumerateDeltasUsingBlock:(void (^)(RPDiffDelta *delta))block;

@property(nonatomic, readonly) git_diff *gitDiff RP_RETURNS_INTERIOR_POINTER;
@property(nonatomic, strong, readonly) RPRepo *repo;

@property(nonatomic, readonly) NSUInteger deltaCount;

@end
