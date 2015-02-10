//
//  NSData+RPEncoding.h
//  Repo
//
//  Created by Charles Osmer on 1/19/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang assume_nonnull begin

@interface NSData (RPEncoding)

- (CFStringEncoding)rp_detectStringEncoding;

@end

#pragma clang assume_nonnull end
