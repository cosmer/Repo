//
//  RPLineDiff.m
//  Repo
//
//  Created by Charles Osmer on 5/7/16.
//  Copyright © 2016 Charles Osmer. All rights reserved.
//

#import "RPLineDiff.h"

#import "xinclude.h"

_Static_assert(RPLineDiffOptionNeedMinimal == XDF_NEED_MINIMAL, "");
_Static_assert(RPLineDiffOptionIgnoreWhitespace == XDF_IGNORE_WHITESPACE, "");
_Static_assert(RPLineDiffOptionIgnoreWhitespaceChange == XDF_IGNORE_WHITESPACE_CHANGE, "");
_Static_assert(RPLineDiffOptionIgnoreWhitespaceAtEOL == XDF_IGNORE_WHITESPACE_AT_EOL, "");
_Static_assert(RPLineDiffOptionPatienceDiff == XDF_PATIENCE_DIFF, "");
_Static_assert(RPLineDiffOptionHistogramDiff == XDF_HISTOGRAM_DIFF, "");
_Static_assert(RPLineDiffOptionIndentHeuristic == XDF_INDENT_HEURISTIC, "");

@implementation RPLineDiff

+ (BOOL)diffOfString1:(NSString *)string1 string2:(NSString *)string2 options:(RPLineDiffOption)options callback:(RPLineDiffCallback)callback
{
    NSParameterAssert(string1 != nil);
    NSParameterAssert(string2 != nil);
    NSParameterAssert(callback != nil);
    
    mmfile_t file1 = {0};
    file1.ptr = (char *)string1.UTF8String;
    file1.size = strlen(file1.ptr);
    
    mmfile_t file2 = {0};
    file2.ptr = (char *)string2.UTF8String;
    file2.size = strlen(file2.ptr);
    
    xpparam_t xpp = {0};
    xpp.flags = (unsigned long)options;
    
    xdfenv_t xe = {0};
    if (xdl_prepare_env(&file1, &file2, &xpp, &xe) < 0) {
        return NO;
    }
    
    if (xdl_do_diff(&file1, &file2, &xpp, &xe) < 0 ||
        xdl_change_compact(&xe.xdf1, &xe.xdf2, xpp.flags) < 0 ||
        xdl_change_compact(&xe.xdf2, &xe.xdf1, xpp.flags) < 0) {
        xdl_free_env(&xe);
        return NO;
    }
    
    BOOL r = [self enumerateDiffsFromFile1:&xe.xdf1 file2:&xe.xdf2 callback:callback];
        
    xdl_free_env(&xe);
    
    return r;
}

static BOOL addLine(const xrecord_t *rec, RPLineChange change, RPLineDiffCallback callback)
{
    NSString *line = [[NSString alloc] initWithBytes:rec->ptr length:rec->size encoding:NSUTF8StringEncoding];
    if (!line) {
        return NO;
    }

    callback(line, change);
    return YES;
}

+ (BOOL)enumerateDiffsFromFile1:(const xdfile_t *)file1 file2:(const xdfile_t *)file2 callback:(RPLineDiffCallback)callback
{
    long i1 = 0;
    long i2 = 0;
    
    const long count1 = file1->nrec;
    const long count2 = file2->nrec;
    
    while (i1 < count1 && i2 < count2) {
        const xrecord_t *rec1 = file1->recs[i1];
        if (file1->rchg[i1]) {
            if (!addLine(rec1, RPLineChangeDelete, callback)) {
                return NO;
            }
            
            i1++;
            continue;
        }
        
        const xrecord_t *rec2 = file2->recs[i2];
        if (file2->rchg[i2]) {
            if (!addLine(rec2, RPLineChangeInsert, callback)) {
                return NO;
            }
            
            i2++;
            continue;
        }
        
        // If any whitespace was ignored, rec1 and rec2 may not be equal.
        // Use rec2 since it represents the 'new' side of the diff.
        addLine(rec2, RPLineChangeEqual, callback);
        
        i1++;
        i2++;
    }
    
    for (; i1 < count1; i1++) {
        assert(file1->rchg[i1]);
        const xrecord_t *rec = file1->recs[i1];
        if (!addLine(rec, RPLineChangeDelete, callback)) {
            return NO;
        }
    }
    
    for (; i2 < count2; i2++) {
        assert(file2->rchg[i2]);
        const xrecord_t *rec = file2->recs[i2];
        if (!addLine(rec, RPLineChangeInsert, callback)) {
            return NO;
        }
    }
    
    return YES;
}

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"%@ not available", NSStringFromSelector(_cmd)];
    return nil;
}

@end
