//
//  RPTag.h
//  Repo
//
//  Created by Charles Osmer on 4/24/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPMacros.h"
#import "RPTypes.h"

@class RPRepo;
@class RPOID;
@class RPObject;

typedef struct git_tag git_tag;

NS_ASSUME_NONNULL_BEGIN

/// \return YES to continue enumeration, NO to stop enumeration.
typedef BOOL(^RPTagCallback)(const char *name, const char *shortname, RPOID *oid);

@interface RPTag : NSObject

+ (nullable instancetype)lookupOID:(RPOID *)oid inRepo:(RPRepo *)repo error:(NSError **)error;

+ (void)enumerateTagsInRepo:(RPRepo *)repo callback:(RP_NO_ESCAPE RPTagCallback)callback;

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `tag`.
- (instancetype)initWithGitTag:(git_tag *)tag NS_DESIGNATED_INITIALIZER;

- (nullable RPObject *)peelWithError:(NSError **)error;

@property(nonatomic, readonly) git_tag *gitTag RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, readonly) RPObjectType targetType;

@end

NS_ASSUME_NONNULL_END
