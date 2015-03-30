//
//  RPTree.h
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

@class RPOID;
@class RPRepo;

typedef struct git_tree git_tree;

NS_ASSUME_NONNULL_BEGIN

@interface RPTree : NSObject

+ (nullable instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

- (instancetype)initWithGitTree:(git_tree *)tree NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) git_tree *gitTree RP_RETURNS_INTERIOR_POINTER;

@end

NS_ASSUME_NONNULL_END
