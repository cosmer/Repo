//
//  NSData+RPEncoding.h
//  Repo
//
//  Created by Charles Osmer on 1/19/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (RPEncoding)

- (CFStringEncoding)rp_detectStringEncoding;

@end

NS_ASSUME_NONNULL_END
