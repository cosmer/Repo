//
//  NSString+RPEncoding.m
//  Repo
//
//  Created by Charles Osmer on 1/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import "NSString+RPEncoding.h"

@implementation NSString (RPEncoding)

+ (NSArray *)rp_fallbackEncodings
{
    static NSArray *encodings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodings = @[@(NSUTF8StringEncoding),
                      @(NSISOLatin1StringEncoding),
                      @(NSISOLatin2StringEncoding),
                      @(NSWindowsCP1252StringEncoding),
                      @(NSMacOSRomanStringEncoding)];
    });
    return encodings;
}

+ (NSString *)rp_stringWithData:(NSData *)data preferredEncoding:(const NSStringEncoding *)preferredEncoding usedEncoding:(NSStringEncoding *)usedEncoding
{
    NSParameterAssert(data != nil);
    
    if (preferredEncoding) {
        NSString *string = [[NSString alloc] initWithData:data encoding:*preferredEncoding];
        if (string) {
            if (usedEncoding) {
                *usedEncoding = *preferredEncoding;
            }
            return string;
        }
    }
    
    for (id object in [self rp_fallbackEncodings]) {
        NSStringEncoding encoding = [object unsignedIntegerValue];
        if (preferredEncoding && *preferredEncoding == encoding) {
            continue;
        }
        
        NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
        if (string) {
            if (usedEncoding) {
                *usedEncoding = encoding;
            }
            return string;
        }
    }
    return nil;
}

@end
