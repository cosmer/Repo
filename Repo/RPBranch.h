//
//  RPBranch.h
//  Repo
//
//  Created by Charles Osmer on 3/22/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPTypes.h"

@class RPRepo;
@class RPReference;

NS_ASSUME_NONNULL_BEGIN

/// RPDiffDelta is immutable and thread safe.
@interface RPBranch : NSObject

+ (nullable NSArray *)branchesInRepo:(RPRepo *)repo withTypes:(RPBranchType)types error:(NSError **)error;

- (nullable RPReference *)lookupReferenceInRepo:(RPRepo *)repo error:(NSError **)error;

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, readonly) RPBranchType type;
@property(nonatomic, readonly) BOOL isHEAD;

@end

NS_ASSUME_NONNULL_END
