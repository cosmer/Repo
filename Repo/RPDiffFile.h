//
//  RPDiffFile.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPOID;

typedef NS_ENUM(NSInteger, RPFileMode) {
    RPFileModeUnreadable        = 0000000,
    RPFileModeTree              = 0040000,
    RPFileModeBlob              = 0100644,
    RPFileModeBlobExecutable    = 0100755,
    RPFileModeLink              = 0120000,
    RPFileModeCommit            = 0160000,
};

/// RPDiffFile is immutable and thread safe.
@interface RPDiffFile : NSObject

/// Path to the receiver relative to the working directory of the repository.
@property(nonatomic, strong, readonly) NSString *path;
/// The receiver's git OID.
@property(nonatomic, strong, readonly) RPOID *oid;

/// Describes the file type; commit, blob, tree, etc.
@property(nonatomic, readonly) RPFileMode mode;

/// The receiver is treated as binary data.
@property(nonatomic, readonly) BOOL isBinary;
/// The receiver is treated as text.
@property(nonatomic, readonly) BOOL isText;
/// The receiver's id is known to be correct.
@property(nonatomic, readonly) BOOL hasValidID;

@end
