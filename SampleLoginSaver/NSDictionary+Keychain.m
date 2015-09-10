//
//  NSDictionary+Keychain.m
//  LODs
//
//  Created by Chase Gosingtian on 1/26/15.
//
//

@import Security;
#import "NSDictionary+Keychain.h"

@implementation NSDictionary (Keychain)

#pragma mark - Keychain Search Query Creation

+ (NSMutableDictionary *)dictionaryForSearchWithKey:(NSString *)keychainItemID
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    // Keychain item type: Generic Password
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Uniquely identify this keychain accessor
    [searchDictionary setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:(__bridge id)kSecAttrService];
    
    // Uniquely identify the account accessing the keychain
    [searchDictionary setObject:@"SampleLoginSaver" forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:keychainItemID forKey:(__bridge id)kSecAttrAccount];
    
    // Add security attributes
    [searchDictionary setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
    
    return searchDictionary;
}

#pragma mark - Keychain Retrieval

+ (NSDictionary *)dictionaryFromKeychainWithKey:(NSString *)keychainItemID
{
    NSData *data = [self dataFromKeychainWithKey:keychainItemID];
    return [self dictionaryFromData:data];
}

+ (NSData *)dataFromKeychainWithKey:(NSString *)keychainItemID
{
    // Initialize search dictionary
    NSMutableDictionary *searchDictionary = [NSDictionary dictionaryForSearchWithKey:keychainItemID];
    
    // Limit search results to one
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Require keychain's attributes to be returned as CFData/NSData
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    // Perform search
    NSData *resultData = nil;
    CFDataRef foundData = NULL;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef *)&foundData);
    
    if (osStatus == noErr) {
        // __bridge_transfer means that we're not just casting to NSData; we're also transferring
        // ownership from "CF" (CFTypeRef) to "NS" (NSData). This means that ARC will automatically
        // release resultData. If we didn't do this, we'd have to CFRelease(foundDictionary)
        resultData = (__bridge_transfer NSData *)foundData;
        
        return resultData;
    } else {
        // If keychain search failed
        resultData = nil;
        NSLog(@"NSDictionary+Keychain: [Search] Encountered keychain error: %ld", (long)osStatus);
    }
    
    return nil;
}

#pragma mark - Keychain Data-Dictionary Serialization

+ (NSDictionary *)dictionaryFromData:(NSData *)data
{
    if (!data)
    {
        return nil;
    }
    
    // Deserialize the data into a dictionary
    NSError *error;
    NSDictionary *storedDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    
    // If deserialization failed
    if(!storedDictionary) {
        NSLog(@"NSDictionary+Keychain: [Data Serialization] Failed to serialize loaded dictionary with error: %@", error);
        return nil;
    }
    
    NSLog(@"NSDictionary+Keychain: [Data Serialization] SUCCESS; returning dictionary: %@; from data: %@", storedDictionary, data);
    return storedDictionary;
}

+ (NSData *)dataFromDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return nil;
    }
    
    // Serialize self to data
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    if(!error) {
        NSLog(@"NSDictionary+Keychain: [Dictionary Serialization] Serialization of dictionary %@ successful; returning data: %@.", dictionary, data);
        return data;
    } else {
        NSLog(@"NSDictionary+Keychain: [Dictionary Serialization] Serialization of dictionary %@ failed with error: %@.", dictionary, error.description);
    }
    
    return nil;
}

#pragma mark - Keychain Saving

- (BOOL)saveToKeychainWithKey:(NSString *)keychainItemID
{
    // Serialize self to data
    NSData *data = [NSDictionary dataFromDictionary:self];
    
    if(data) {
        // Initialize search dictionary
        NSMutableDictionary *searchDictionary = [NSDictionary dictionaryForSearchWithKey:keychainItemID];
        
        // Set the Keychain item's data
        [searchDictionary setObject:data forKey:(__bridge id)kSecValueData];
        
        // Try to add the item
        OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, nil);
        
        if(osStatus == errSecSuccess) {
            return YES;
        } else if (osStatus == errSecDuplicateItem) {
            // If the item already exists, update it instead
            return [NSDictionary updateKeychainData:data forKey:keychainItemID];
        } else {
            NSLog(@"NSDictionary+Keychain: [%ld] Failed to save dictionary: %@ with storage query: %@", (long)osStatus, self, searchDictionary);
            return NO;
        }
    }
    
    return NO;
}

+ (BOOL)updateKeychainData:(NSData *)data forKey:(NSString *)keychainItemID
{
    NSMutableDictionary *searchDictionary = [NSDictionary dictionaryForSearchWithKey:keychainItemID];
    
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
    
    OSStatus osStatus = SecItemUpdate((__bridge CFDictionaryRef)(searchDictionary), (__bridge CFDictionaryRef)(updateDictionary));
    
    if (osStatus == errSecSuccess) {
        NSLog(@"NSDictionary+Keychain: Successfully updated Keychain ID: %@", keychainItemID);
        return YES;
    } else {
        NSLog(@"NSDictionary+Keychain: [%ld] Failed to update Keychain ID: %@ with storage query: %@, update query: %@", (long)osStatus, keychainItemID, searchDictionary, updateDictionary);
        return NO;
    }
}

#pragma mark - Keychain Deletion

- (BOOL)deleteFromKeychainWithKey:(NSString *)keychainItemID
{
    NSDictionary *searchDictionary = [NSDictionary dictionaryForSearchWithKey:keychainItemID];
    
    OSStatus osStatus = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);

    if(osStatus == noErr) {
        NSLog(@"NSDictionary+Keychain: SUCCESS; Deleted dictionary from keychain with key %@ and delete query %@", keychainItemID, searchDictionary);
        return YES;
    } else {
        NSLog(@"NSDictionary+Keychain: Failed to delete ID %@, dictionary: %@ with delete query: %@", keychainItemID, self, searchDictionary);
    }
    
    NSLog(@"NSDictionary+Keychain: No item to delete for item ID: %@.", keychainItemID);
    return NO;
}

@end
