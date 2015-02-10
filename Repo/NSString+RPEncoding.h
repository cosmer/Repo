//
//  NSString+RPEncoding.h
//  Repo
//
//  Created by Charles Osmer on 1/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang assume_nonnull begin

@interface NSString (RPEncoding)

+ (nullable NSString *)rp_stringWithData:(NSData *)data
                       preferredEncoding:(nullable const NSStringEncoding *)preferredEncoding
                            usedEncoding:(nullable NSStringEncoding *)usedEncoding;

@end

#pragma clang assume_nonnull end
