//
//  RPIndex.m
//  Repo
//
//  Created by Charles Osmer on 4/20/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "RPIndex.h"

#import <git2/index.h>

@implementation RPIndex

- (void)dealloc
{
    git_index_free(_gitIndex);
}

- (instancetype)initWithGitIndex:(git_index *)index
{
    NSParameterAssert(index != NULL);
    if ((self = [super init])) {
        _gitIndex = index;
    }
    return self;
}

@end
