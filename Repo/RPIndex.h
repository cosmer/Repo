//
//  RPIndex.h
//  Repo
//
//  Created by Charles Osmer on 4/20/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

typedef struct git_index git_index;

NS_ASSUME_NONNULL_BEGIN

@interface RPIndex : NSObject

/// Assumes ownership of `index`.
- (instancetype)initWithGitIndex:(git_index *)index NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) git_index *gitIndex RP_RETURNS_INTERIOR_POINTER;

@end

NS_ASSUME_NONNULL_END
