//
//  RPDiffFile+Private.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPDiffFile.h"

#import <git2/diff.h>

#pragma clang assume_nonnull begin

@interface RPDiffFile ()

- (instancetype)initWithGitDiffFile:(git_diff_file)diffFile NS_DESIGNATED_INITIALIZER;

@end

#pragma clang assume_nonnull end
