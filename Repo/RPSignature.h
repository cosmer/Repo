//
//  RPSignature.h
//  Repo
//
//  Created by Charles Osmer on 10/3/15.
//  Copyright © 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct git_signature git_signature;

NS_ASSUME_NONNULL_BEGIN

@interface RPSignature : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithGitSignature:(const git_signature *)signature NS_DESIGNATED_INITIALIZER;

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, copy, readonly) NSString *email;
@property(nonatomic, copy, readonly) NSDate *date;

@end

NS_ASSUME_NONNULL_END
