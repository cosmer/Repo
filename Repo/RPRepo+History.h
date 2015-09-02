//
//  RPRepo+History.h
//  Repo
//
//  Created by Charles Osmer on 9/2/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Repo/Repo.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPRepo (History)

- (BOOL)walkHistoryFromRef:(NSString *)ref callback:(BOOL(^)(RPCommit *))callback error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
