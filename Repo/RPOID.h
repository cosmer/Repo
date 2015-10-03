//
//  RPOID.h
//  Repo
//
//  Created by Charles Osmer on 11/18/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct git_oid git_oid;

@interface RPOID : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithGitOID:(const git_oid *)oid NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithString:(NSString *)string error:(NSError **)error;

@property(nonatomic, readonly) const git_oid *gitOID RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, readonly) BOOL isZero;

@property(nonatomic, strong, readonly) NSString *stringValue;
@property(nonatomic, strong, readonly) NSString *shortStringValue;

@end

NS_ASSUME_NONNULL_END
