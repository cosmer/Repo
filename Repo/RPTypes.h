//
//  RPTypes.h
//  Repo
//
//  Created by Charles Osmer on 3/29/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RPObjectType) {
    RPObjectTypeAny         = -2,
    RPObjectTypeBad         = -1,
    RPObjectTypeCommit      = 1,
    RPObjectTypeTree        = 2,
    RPObjectTypeBlob        = 3,
    RPObjectTypeTag         = 4,
    RPObjectTypeOfsDelta    = 6,
    RPObjectTypeRefDelta    = 7,
};

typedef NS_OPTIONS(NSUInteger, RPBranchType) {
    RPBranchTypeLocal   = 1,
    RPBranchTypeRemote  = 2,
    RPBranchTypeAll     = RPBranchTypeLocal | RPBranchTypeRemote,
};

NSString *RPObjectTypeName(RPObjectType type);
NSString *RPBranchTypeName(RPBranchType type);

NS_ASSUME_NONNULL_END
