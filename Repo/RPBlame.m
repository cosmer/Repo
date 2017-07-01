//
//  RPBlame.m
//  Repo
//
//  Created by Charles Osmer on 6/9/17.
//  Copyright © 2017 Charles Osmer. All rights reserved.
//

#import "RPBlame.h"

#import "RPRepo.h"
#import "RPOID.h"
#import "RPSignature.h"
#import "RPMacros.h"
#import "NSError+RPGitErrors.h"

#import <git2/blame.h>
#import <git2/errors.h>

@interface RPBlame ()

- (instancetype)initWithGitBlame:(git_blame *)blame NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) RP_RETURNS_INTERIOR_POINTER git_blame *gitBlame;

@end

@interface RPBlameHunk ()

- (instancetype)initWithGitBlameHunk:(const git_blame_hunk *)hunk NS_DESIGNATED_INITIALIZER;

@end

@implementation RPBlame

+ (nullable RPBlame *)blameFile:(NSString *)filePath
                     fromCommit:(nullable RPOID *)from
                       toCommit:(nullable RPOID *)to
                         inRepo:(RPRepo *)repo
                          error:(NSError **)error
{
    NSParameterAssert(filePath != nil);
    NSParameterAssert(repo != nil);

    git_blame_options options = GIT_BLAME_OPTIONS_INIT;
    if (from) {
        git_oid_cpy(&options.oldest_commit, from.gitOID);
    }
    if (to) {
        git_oid_cpy(&options.newest_commit, to.gitOID);
    }

    git_blame *blame = NULL;
    if (git_blame_file(&blame, repo.gitRepository, filePath.UTF8String, &options) != GIT_OK) {
        if (error) {
            *error = [NSError rp_lastGitError];
        }
        return nil;
    }

    return [[RPBlame alloc] initWithGitBlame:blame];
}

- (instancetype)initWithGitBlame:(git_blame *)blame
{
    NSParameterAssert(blame != NULL);
    if ((self = [super init])) {
        _gitBlame = blame;
    }
    return self;
}

- (void)dealloc
{
    git_blame_free(_gitBlame);
}

- (uint32_t)hunkCount
{
    return git_blame_get_hunk_count(self.gitBlame);
}

- (RPBlameHunk *)hunkAtIndex:(uint32_t)index
{
    const git_blame_hunk *hunk = git_blame_get_hunk_byindex(self.gitBlame, index);
    return [[RPBlameHunk alloc] initWithGitBlameHunk:hunk];
}

@end

@implementation RPBlameHunk

- (instancetype)initWithGitBlameHunk:(const git_blame_hunk *)hunk
{
    NSParameterAssert(hunk != NULL);
    if ((self = [super init])) {
        _range = NSMakeRange(hunk->final_start_line_number - 1, hunk->lines_in_hunk);
        _commit = [[RPOID alloc] initWithGitOID:&hunk->final_commit_id];
        _signature = [[RPSignature alloc] initWithGitSignature:hunk->final_signature];
    }
    return self;
}

@end
