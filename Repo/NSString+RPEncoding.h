//
//  NSString+RPEncoding.h
//  Repo
//
//  Created by Charles Osmer on 1/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RPEncoding)

+ (NSString *)rp_stringWithData:(NSData *)data preferredEncoding:(const NSStringEncoding *)preferredEncoding usedEncoding:(NSStringEncoding *)usedEncoding;

@end
