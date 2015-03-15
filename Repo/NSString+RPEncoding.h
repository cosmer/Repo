//
//  NSString+RPEncoding.h
//  Repo
//
//  Created by Charles Osmer on 1/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (RPEncoding)

+ (nullable NSString *)rp_stringWithData:(NSData *)data
                       preferredEncoding:(nullable const NSStringEncoding *)preferredEncoding
                            usedEncoding:(nullable NSStringEncoding *)usedEncoding;

@end

NS_ASSUME_NONNULL_END
