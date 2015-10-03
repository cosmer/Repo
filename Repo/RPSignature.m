//
//  RPSignature.m
//  Repo
//
//  Created by Charles Osmer on 10/3/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import "RPSignature.h"

#import <git2/signature.h>

@implementation RPSignature

- (instancetype)initWithGitSignature:(const git_signature *)signature
{
    NSParameterAssert(signature != NULL);
    if ((self = [super init])) {
        _name = @(signature->name ?: "");
        _email = @(signature->email ?: "");
        _date = [NSDate dateWithTimeIntervalSince1970:signature->when.time];
    }
    return self;
}

@end
