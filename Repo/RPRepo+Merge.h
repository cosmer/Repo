//
//  RPRepo+Merge.h
//  Repo
//
//  Created by Charles Osmer on 2/14/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import <Repo/Repo.h>

@class RPConflictEntry;

NS_ASSUME_NONNULL_BEGIN

@interface RPRepo (Merge)

- (nullable NSData *)mergeConflictEntriesWithAncestor:(nullable RPConflictEntry *)ancestor
                                                 ours:(RPConflictEntry *)ours
                                               theirs:(RPConflictEntry *)theirs
                                                error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
