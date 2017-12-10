//
//  Repo.h
//  Repo
//
//  Created by Charles Osmer on 11/16/14.
//  Copyright (c) 2014 Charles Osmer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for Repo.
FOUNDATION_EXPORT double RepoVersionNumber;

//! Project version string for Repo.
FOUNDATION_EXPORT const unsigned char RepoVersionString[];

#import <Repo/RPTypes.h>
#import <Repo/RPRepo.h>
#import <Repo/RPRepo+Merge.h>
#import <Repo/RPBlame.h>
#import <Repo/RPBranch.h>
#import <Repo/RPCommit.h>
#import <Repo/RPConfig.h>
#import <Repo/RPConflict.h>
#import <Repo/RPDiff.h>
#import <Repo/RPDiffDelta.h>
#import <Repo/RPDiffFile.h>
#import <Repo/RPDiffFindOptions.h>
#import <Repo/RPDiffStats.h>
#import <Repo/RPObject.h>
#import <Repo/RPOID.h>
#import <Repo/RPIndex.h>
#import <Repo/RPBlob.h>
#import <Repo/RPReference.h>
#import <Repo/RPSignature.h>
#import <Repo/RPStash.h>
#import <Repo/RPSubmodule.h>
#import <Repo/RPTree.h>
#import <Repo/RPTreeEntry.h>
#import <Repo/RPLineDiff.h>
#import <Repo/NSError+RPGitErrors.h>
#import <Repo/RPMacros.h>
#import <Repo/RPFileTime.h>
#import <Repo/RPTag.h>
