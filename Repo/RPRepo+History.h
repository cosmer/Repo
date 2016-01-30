//
//  RPRepo+History.h
//  Repo
//
//  Created by Charles Osmer on 9/2/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Repo/Repo.h>

@class RPRevWalker;
@class RPOID;

typedef NS_OPTIONS(NSUInteger, RPHistorySortOptions) {
    RPHistorySortOptionsTopological    = 1 << 0,
    RPHistorySortOptionsTime           = 1 << 1,
    RPHistorySortOptionsReverse        = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface RPRepo (History)

- (nullable RPRevWalker *)revWalkerFromRef:(NSString *)ref
                               sortOptions:(RPHistorySortOptions)options
                                     error:(NSError **)error;

- (nullable RPRevWalker *)revWalkerFromOID:(RPOID *)oid
                               sortOptions:(RPHistorySortOptions)options
                                     error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
