//
//  RPCommitWalker.h
//  Repo
//
//  Created by Charles Osmer on 10/18/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPRepo;
@class RPRevWalker;
@class RPCommit;

NS_ASSUME_NONNULL_BEGIN

@interface RPCommitWalker : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithRevWalker:(RPRevWalker *)revWalker repo:(RPRepo *)repo NS_DESIGNATED_INITIALIZER;

- (nullable RPCommit *)next;

@property(nonatomic, strong, readonly) RPRevWalker *revWalker;
@property(nonatomic, strong, readonly) RPRepo *repo;

@end

NS_ASSUME_NONNULL_END
