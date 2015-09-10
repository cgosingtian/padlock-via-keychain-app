//
//  NSDictionary+Keychain.h
//  LODs
//
//  Created by Chase Gosingtian on 1/26/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Keychain)

+ (NSDictionary *)dictionaryFromKeychainWithKey:(NSString *)keychainItemID;
- (BOOL)saveToKeychainWithKey:(NSString *)keychainItemID;
- (BOOL)deleteFromKeychainWithKey:(NSString *)keychainItemID;

@end
