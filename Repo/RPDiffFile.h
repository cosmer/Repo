//
//  RPDiffFile.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Repo/RPTypes.h>
#import <Repo/RPFileTime.h>

NS_ASSUME_NONNULL_BEGIN

@class RPOID;

/// RPDiffFile is immutable and thread safe.
@interface RPDiffFile : NSObject

/// Path to the receiver relative to the working directory of the repository.
@property(nonatomic, strong, readonly) NSString *path;
/// The receiver's git OID.
@property(nonatomic, strong, readonly) RPOID *oid;

/// Describes the file type; commit, blob, tree, etc.
@property(nonatomic, readonly) RPFileMode mode;

/// The receiver's creation time.
@property(nonatomic, readonly) RPFileTime ctime;
/// The receiver's modification time.
@property(nonatomic, readonly) RPFileTime mtime;

/// File size in bytes. Not guaranteed to be set.
@property(nonatomic, readonly) int64_t size;

/// The receiver is treated as binary data.
@property(nonatomic, readonly) BOOL isBinary;
/// The receiver is treated as text.
@property(nonatomic, readonly) BOOL isText;
/// The receiver's id is known to be correct.
@property(nonatomic, readonly) BOOL hasValidID;
/// A file exists at this side of the delta.
@property(nonatomic, readonly) BOOL fileExists;

@end

NS_ASSUME_NONNULL_END
