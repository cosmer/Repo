//
//  RPBlame.h
//  Repo
//
//  Created by Charles Osmer on 6/9/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPOID;
@class RPRepo;
@class RPBlameHunk;
@class RPSignature;

NS_ASSUME_NONNULL_BEGIN

@interface RPBlame : NSObject

+ (nullable RPBlame *)blameFile:(NSString *)filePath
                     fromCommit:(nullable RPOID *)from
                       toCommit:(nullable RPOID *)to
                         inRepo:(RPRepo *)repo
                          error:(NSError **)error;

- (instancetype)init NS_UNAVAILABLE;

- (RPBlameHunk *)hunkAtIndex:(uint32_t)index;

@property(nonatomic, readonly) uint32_t hunkCount;

@end

// RPBlameHunk is immutable and thread safe.
@interface RPBlameHunk : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, readonly) NSRange range;
@property(nonatomic, strong, readonly) RPOID *commit;
@property(nonatomic, strong, readonly) RPSignature *signature;

@end

NS_ASSUME_NONNULL_END
