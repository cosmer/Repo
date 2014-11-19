//
//  RPOID.h
//  Repo
//
//  Created by Charles Osmer on 11/18/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"

typedef struct git_oid git_oid;

@interface RPOID : NSObject

- (instancetype)initWithGitOID:(const git_oid *)oid NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) const git_oid *gitOID RP_RETURNS_INTERIOR_POINTER;

@end
