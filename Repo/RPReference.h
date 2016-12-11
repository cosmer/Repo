//
//  RPReference.h
//  Repo
//
//  Created by Charles Osmer on 2/15/15.
//  Copyright (c) 2015 Charles Osmer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RPTypes.h"
#import "RPMacros.h"

@class RPRepo;
@class RPObject;
@class RPOID;

typedef NS_ENUM(NSInteger, RPReferenceNamespace) {
    RPReferenceNamespaceUnknown,
    RPReferenceNamespaceBranch,
    RPReferenceNamespaceRemote,
    RPReferenceNamespaceTag,
    RPReferenceNamespaceNote,
};

NS_ASSUME_NONNULL_BEGIN

typedef struct git_reference git_reference;

@interface RPReference : NSObject

+ (nullable instancetype)lookupName:(NSString *)name inRepo:(RPRepo *)repo error:(NSError **)error;
+ (nullable instancetype)lookupShortName:(NSString *)name inRepo:(RPRepo *)repo error:(NSError **)error;

+ (nullable instancetype)upstreamReferenceForReferenceNamed:(NSString *)name inRepo:(RPRepo *)repo error:(NSError **)error;

/// \return All references in the repository.
+ (nullable NSArray<RPReference *> *)referencesInRepo:(RPRepo *)repo error:(NSError **)error;

- (instancetype)init NS_UNAVAILABLE;

/// Assumes ownership of `reference`.
- (instancetype)initWithGitReference:(git_reference *)reference NS_DESIGNATED_INITIALIZER;

- (nullable RPObject *)peelToType:(RPObjectType)type error:(NSError **)error;

/// Iteratively peels a symbolic reference until it resolves to a direct reference to an OID.
- (nullable RPReference *)resolveWithError:(NSError **)error;

/// \returns The receiver's remote tracking branch.
- (nullable RPReference *)upstream;

@property(nonatomic, readonly) git_reference *gitReference RP_RETURNS_INTERIOR_POINTER;

@property(nonatomic, readonly) BOOL isSymbolic;

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, strong, readonly) NSString *shortName;

@property(nullable, nonatomic, strong, readonly) RPOID *oid;

@property(nonatomic, readonly) RPReferenceNamespace referenceNamespace;

@end

NS_ASSUME_NONNULL_END
