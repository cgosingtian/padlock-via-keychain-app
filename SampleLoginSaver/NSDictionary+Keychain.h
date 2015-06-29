//
//  NSDictionary+Keychain.h
//  LODs
//
//  Created by Chase Gosingtian on 1/26/15.
//
//  This category allows the saving, loading, and deletion of NSDictionary objects
//  to the Keychain. An "item ID" is required to determine the identity of an object
//  for the processes above - define them as constants here.
//

#import <Foundation/Foundation.h>

extern NSString* const kWarriorListHashKey;
extern NSString* const kWarriorListHashCountKey;

@interface NSDictionary (Keychain)

+ (NSDictionary *)dictionaryFromKeychainWithKey:(NSString *)keychainItemID;
- (BOOL)saveToKeychainWithKey:(NSString *)keychainItemID;
- (BOOL)deleteFromKeychainWithKey:(NSString *)keychainItemID;

@end
