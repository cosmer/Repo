//
//  RPDiffFindOptions.h
//  Repo
//
//  Created by Charles Osmer on 1/28/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(uint32_t, RPDiffFindFlag) {
    RPDiffFindFlagFindByConfig                  = 0,
    RPDiffFindFlagFindRenames                   = 1u << 0,
    RPDiffFindFlagFindRenamesFromRewrites       = 1u << 1,
    RPDiffFindFlagFindCopies                    = 1u << 2,
    RPDiffFindFlagFindCopiesFromUnmodified      = 1u << 3,
    RPDiffFindFlagFindRewrites                  = 1u << 4,
    RPDiffFindFlagBreakRewrites                 = 1u << 5,
    RPDiffFindFlagFindForUntracked              = 1u << 6,
    RPDiffFindFlagFindAll                       = 0x0ff,

    RPDiffFindFlagIgnoreLeadingWhitespace       = 0,
    RPDiffFindFlagIgnoreWhitespace              = 1u << 12,
    RPDiffFindFlagDontIgnoreWhitespace          = 1u << 13,
    RPDiffFindFlagExactMatchOnly                = 1u << 14,

    RPDiffFindFlagBreakRewritesForRenamesOnly   = 1u << 15,

    RPDiffFindFlagRemoveUnmodified              = 1u << 16,
};

@interface RPDiffFindOptions : NSObject

@property(nonatomic) RPDiffFindFlag flags;

@property(nonatomic) uint16_t renameThreshold;
@property(nonatomic) uint16_t renameFromRewriteThreshold;
@property(nonatomic) uint16_t copyThreshold;
@property(nonatomic) uint16_t breakRewriteThreshold;

@property(nonatomic) size_t renameLimit;

@property(nonatomic) int64_t maxFileSize;

@end

NS_ASSUME_NONNULL_END
