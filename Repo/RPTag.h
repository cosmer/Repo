//
//  RPTag.h
//  Repo
//
//  Created by Charles Osmer on 4/24/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPRepo;
@class RPOID;

NS_ASSUME_NONNULL_BEGIN

/// \return YES to continue enumeration, NO to stop enumeration.
typedef BOOL(^RPTagCallback)(const char *name, const char *shortname, RPOID *oid);

@interface RPTag : NSObject

+ (void)enumerateTagsInRepo:(RPRepo *)repo callback:(RPTagCallback)callback;

@end

NS_ASSUME_NONNULL_END
