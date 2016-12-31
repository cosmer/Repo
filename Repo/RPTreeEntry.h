//
//  RPTreeEntry.h
//  Repo
//
//  Created by Charles Osmer on 12/29/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPTypes.h"

@class RPOID;

typedef struct git_tree_entry git_tree_entry;

NS_ASSUME_NONNULL_BEGIN

/// RPTreeEntry is immutable and thread safe.
@interface RPTreeEntry : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Does *not* assume ownership of `entry`.
- (instancetype)initWithGitTreeEntry:(const git_tree_entry *)entry NS_DESIGNATED_INITIALIZER;

@property(nonatomic, strong, readonly) RPOID *oid;
@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) RPObjectType objectType;
@property(nonatomic, readonly) RPFileMode fileMode;

@end

NS_ASSUME_NONNULL_END
