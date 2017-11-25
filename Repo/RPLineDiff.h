//
//  RPLineDiff.h
//  Repo
//
//  Created by Charles Osmer on 5/7/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RPLineChange) {
    RPLineChangeEqual,
    RPLineChangeInsert,
    RPLineChangeDelete,
};

typedef NS_OPTIONS(NSUInteger, RPLineDiffOption) {
    RPLineDiffOptionNeedMinimal             = (1 << 1),

    RPLineDiffOptionIgnoreWhitespace        = (1 << 2),
    RPLineDiffOptionIgnoreWhitespaceChange  = (1 << 3),
    RPLineDiffOptionIgnoreWhitespaceAtEOL   = (1 << 4),
    
    RPLineDiffOptionPatienceDiff            = (1 << 5),
    RPLineDiffOptionHistogramDiff           = (1 << 6),
    
    RPLineDiffOptionIndentHeuristic         = (1 << 8),
};

typedef void(^RPLineDiffCallback)(NSString *line, RPLineChange change);

@interface RPLineDiff : NSObject

/// Invokes the callback for each line in the diff.
/// \return YES if the diff completed successfully, NO if an error occurred.
+ (BOOL)diffOfString1:(NSString *)string1 string2:(NSString *)string2 options:(RPLineDiffOption)options callback:(RPLineDiffCallback)callback;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
