//
//  RPDiffFile+Private.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import "RPDiffFile.h"

#import <git2/diff.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPDiffFile ()

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithGitDiffFile:(git_diff_file)diffFile NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
