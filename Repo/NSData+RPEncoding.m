//
//  NSData+RPEncoding.m
//  Repo
//
//  Created by Charles Osmer on 1/19/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "NSData+RPEncoding.h"

#import <unicode/ucsdet.h>

#import <limits.h>

@implementation NSData (RPEncoding)

- (CFStringEncoding)rp_detectStringEncoding
{
    if (self.length > (NSUInteger)INT_MAX) {
        return kCFStringEncodingInvalidId;
    }
    
    UErrorCode status = U_ZERO_ERROR;

    UCharsetDetector *detector = ucsdet_open(&status);
    if (U_FAILURE(status)) {
        return kCFStringEncodingInvalidId;
    }
    
    ucsdet_setText(detector, self.bytes, (int32_t)self.length, &status);
    if (U_FAILURE(status)) {
        ucsdet_close(detector);
        return kCFStringEncodingInvalidId;
    }
    
    const UCharsetMatch *match = ucsdet_detect(detector, &status);
    if (!match || U_FAILURE(status)) {
        ucsdet_close(detector);
        return kCFStringEncodingInvalidId;
    };
    
    const char *name = ucsdet_getName(match, &status);
    if (!name || U_FAILURE(status)) {
        ucsdet_close(detector);
        return kCFStringEncodingInvalidId;
    }
    
    CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)@(name));
    ucsdet_close(detector);

    return encoding;
}

@end
