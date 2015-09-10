//
//  NSDictionary+Keychain.h
//  LODs
//
//  Created by Chase Gosingtian on 1/26/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Keychain)

/**
 *  Retrieves a specific Keychain entry and returns it in NSDictionary format.
 *
 *  @param keychainItemID The Keychain item identifier.
 *
 *  @return The NSDictionary containing the Keychain item's values.
 */
+ (NSDictionary *)dictionaryFromKeychainWithKey:(NSString *)keychainItemID;

/**
 *  Saves an NSDictionary instance to the Keychain with a specific identifier.
 *
 *  @param keychainItemID The identifier that the NSDictionary should be identified as in the Keychain.
 *
 *  @return Success or failure of operation.
 */
- (BOOL)saveToKeychainWithKey:(NSString *)keychainItemID;

/**
 *  Deletes an NSDictionary instance from the Keychain through a specific identifer.
 *
 *  @param keychainItemID The identifier of the Keychain item to be deleted.
 *
 *  @return Success or failure of operation.
 */
- (BOOL)deleteFromKeychainWithKey:(NSString *)keychainItemID;

@end
