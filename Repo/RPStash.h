//
//  RPStash.h
//  Repo
//
//  Created by Charles Osmer on 8/20/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPRepo;
@class RPOID;

NS_ASSUME_NONNULL_BEGIN

@interface RPStash : NSObject

+ (nullable NSArray<RPStash *> *)stashesInRepo:(RPRepo *)repo error:(NSError **)error;

+ (BOOL)dropStashWithCommitOID:(RPOID *)commitOID inRepo:(RPRepo *)repo error:(NSError **)error;

@property(nonatomic, readonly) size_t index;
@property(nonatomic, copy, readonly) NSString *message;
@property(nonatomic, strong, readonly) RPOID *commitOID;

@end

NS_ASSUME_NONNULL_END
