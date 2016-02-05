//
//  RPConflict.h
//  Repo
//
//  Created by Charles Osmer on 2/4/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPOID;

typedef struct git_index git_index;
typedef struct git_index_entry git_index_entry;

NS_ASSUME_NONNULL_BEGIN;

@interface RPConflictEntry : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithOID:(RPOID *)oid path:(NSString *)path NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithGitIndexEntry:(const git_index_entry *)entry;

@property(nonatomic, strong, readonly) RPOID *oid;
@property(nonatomic, strong, readonly) NSString *path;

@end

@interface RPConflict : NSObject

+ (NSArray<RPConflict *> *)conflictsFromGitIndex:(git_index *)index;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAncestor:(RPConflictEntry *)ancestor
                            ours:(RPConflictEntry *)ours
                          theirs:(RPConflictEntry *)theirs NS_DESIGNATED_INITIALIZER;

@property(nonatomic, strong, readonly) RPConflictEntry *ancestor;
@property(nonatomic, strong, readonly) RPConflictEntry *ours;
@property(nonatomic, strong, readonly) RPConflictEntry *theirs;

@end

NS_ASSUME_NONNULL_END;
