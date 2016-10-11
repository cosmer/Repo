//
//  RPRepo+Merge.h
//  Repo
//
//  Created by Charles Osmer on 2/14/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import <Repo/Repo.h>

@class RPIndex;
@class RPCommit;
@class RPConflictEntry;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, RPMergeFileFlag) {
    RPMergeFileFlagDefault                  = 0,
    RPMergeFileFlagStyleMerge               = 1 << 0,
    RPMergeFileFlagStyleDiff3               = 1 << 1,
    RPMergeFileFlagSimplifyAlnum            = 1 << 2,
    RPMergeFileFlagIgnoreWhitespace         = 1 << 3,
    RPMergeFileFlagIgnoreWhitespaceChange   = 1 << 4,
    RPMergeFileFlagIgnoreWhitespaceEOL      = 1 << 5,
    RPMergeFileFlagDiffPatience             = 1 << 6,
    RPMergeFileFlagDiffMinimal              = 1 << 7,
};

@interface RPMergeFileOptions : NSObject

@property(nonatomic) RPMergeFileFlag flags;

@property(nullable, nonatomic, copy) NSString *ancestorLabel;
@property(nullable, nonatomic, copy) NSString *ourLabel;
@property(nullable, nonatomic, copy) NSString *theirLabel;

@end

@interface RPRepo (Merge)

/// \return An index that reflects the result of the merge.
- (nullable RPIndex *)mergeOurCommit:(RPCommit *)ourCommit
                     withTheirCommit:(RPCommit *)theirCommit
                               error:(NSError **)error;

- (nullable NSData *)mergeConflictEntriesWithAncestor:(nullable RPConflictEntry *)ancestor
                                                 ours:(RPConflictEntry *)ours
                                               theirs:(RPConflictEntry *)theirs
                                              options:(RPMergeFileOptions *)options
                                                error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
