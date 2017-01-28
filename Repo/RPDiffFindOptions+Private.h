//
//  RPDiffFindOptions+Private.h
//  Repo
//
//  Created by Charles Osmer on 1/28/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import "RPDiffFindOptions.h"

#import <git2/diff.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPDiffFindOptions ()

@property(nonatomic, readonly) git_diff_find_options gitOptions;

@end

NS_ASSUME_NONNULL_END
