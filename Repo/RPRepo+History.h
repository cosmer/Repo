//
//  RPRepo+History.h
//  Repo
//
//  Created by Charles Osmer on 9/2/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Repo/Repo.h>

typedef NS_OPTIONS(NSUInteger, RPHistorySortOptions) {
    RPHistorySortOptionsTopological    = 1 << 0,
    RPHistorySortOptionsTime           = 1 << 1,
    RPHistorySortOptionsReverse        = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface RPRepo (History)

- (BOOL)walkHistoryFromRef:(NSString *)ref
               sortOptions:(RPHistorySortOptions)options
                  callback:(BOOL(^)(RPCommit *))callback
                     error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
