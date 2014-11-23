//
//  RPDiffFile.h
//  Repo
//
//  Created by Charles Osmer on 11/17/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPOID;

/// RPDiffFile is immutable and thread safe.
@interface RPDiffFile : NSObject

/// Path to the receiver relative to the working directory of the repository.
@property(nonatomic, strong, readonly) NSString *path;
/// The receiver's git OID.
@property(nonatomic, strong, readonly) RPOID *oid;

/// The receiver is treated as binary data.
@property(nonatomic, readonly) BOOL isBinary;
/// The receiver is treated as text.
@property(nonatomic, readonly) BOOL isText;
/// The receiver's id is known to be correct.
@property(nonatomic, readonly) BOOL hasValidID;

@end
