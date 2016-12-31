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
@class RPTreeEntry;

typedef struct git_tree git_tree;

NS_ASSUME_NONNULL_BEGIN

@interface RPTree : NSObject

+ (nullable instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithGitTree:(git_tree *)tree NS_DESIGNATED_INITIALIZER;

- (RPTreeEntry *)entryAtIndex:(NSInteger)index;

/// \return The entry's oid, or a zero oid if the entry doesn't exist.
- (nullable RPOID *)oidOfEntryAtPath:(NSString *)path error:(NSError **)error;

@property(nonatomic, readonly) git_tree *gitTree RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, strong, readonly) RPOID *oid;

@property(nonatomic, readonly) NSInteger entryCount;

@end

NS_ASSUME_NONNULL_END
