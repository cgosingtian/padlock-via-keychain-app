//
//  NSDictionary+Keychain.m
//  LODs
//
//  Created by Chase Gosingtian on 1/26/15.
//
//

@import Security;
#import "NSDictionary+Keychain.h"

NSString* const kWarriorListHashKey = @"warriorListHash";
NSString* const kWarriorListHashCountKey = @"warriorListHashCount";

@implementation NSDictionary (Keychain)

+ (NSDictionary *)dictionaryFromKeychainWithKey:(NSString *)keychainItemID
{
    // Create the query that will provide the attributes of the Keychain Item we want...
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"SampleLoginSaver",                     (__bridge id)kSecAttrGeneric,
                           keychainItemID,                          (__bridge id)kSecAttrAccount,
                           (__bridge id)kSecAttrAccessibleAfterFirstUnlock,  (__bridge id)kSecAttrAccessible,
                           (__bridge id)kSecClassGenericPassword,            (__bridge id)kSecClass,
                           [[NSBundle mainBundle] bundleIdentifier],(__bridge id)kSecAttrService,
                           (__bridge id)kSecMatchLimitOne,                   (__bridge id)kSecMatchLimit,
                           (__bridge id)kCFBooleanTrue,                      (__bridge id)kSecReturnAttributes,
                           nil];

    NSDictionary *queryDictionary = nil;
    CFTypeRef queryResult = (__bridge CFTypeRef)queryDictionary;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, &queryResult);
    
    if (!queryResult)
    {
        NSLog(@"NSDictionary+Keychain: [Status: %ld] No result found. Returning nil...", (long)osStatus);
        return nil;
    }
    
    // Given the attributes of the Keychain Item, we ask the Keychain to provide the actual item...
    if (osStatus == noErr)
    {
        NSMutableDictionary *valueQuery = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)queryResult];
    
        [valueQuery setObject:(__bridge id)kSecClassGenericPassword  forKey:(__bridge id)kSecClass];
        [valueQuery setObject:(__bridge id)kCFBooleanTrue            forKey:(__bridge id)kSecReturnData];
    
        NSData *valueData = nil;
        CFTypeRef valueDataResult = (__bridge CFTypeRef)valueData;
        OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)valueQuery, &valueDataResult);
        
        // If item was found...
        if(result == noErr)
        {
            // Deserialize the data into a dictionary
            NSError *error;
            NSDictionary *storedDictionary = [NSPropertyListSerialization propertyListWithData:(__bridge NSData *)valueDataResult
                                                                                       options:NSPropertyListImmutable
                                                                                        format:NULL
                                                                                         error:&error];
            
            if(!storedDictionary)
            {
                NSLog(@"NSDictionary+Keychain: Failed to serialize loaded dictionary with error: %@", error);
                return nil;
            }

            NSLog(@"NSDictionary+Keychain: SUCCESS; Loaded dictionary from keychain with ID: %@", keychainItemID);
            return storedDictionary;
        }
        else
        {
            NSLog(@"NSDictionary+Keychain: Failed to load dictionary with query: %@ [%ld]", query, (long)osStatus);
            return nil;
        }
    
        return nil;
    } else
    {
        NSLog(@"NSDictionary+Keychain: Failed to retrieve query attributes; returning nil. [Status Code: %ld]", (long)osStatus);
        return nil;
    }
}

- (BOOL)saveToKeychainWithKey:(NSString *)keychainItemID
{
    NSError *error = nil;
    
    NSData *serializedDictionary = [NSPropertyListSerialization dataWithPropertyList:self
                                                                              format:NSPropertyListXMLFormat_v1_0
                                                                             options:0
                                                                               error:&error];
    
    if(!error) {
        [self deleteFromKeychainWithKey:keychainItemID];

        NSDictionary *storageQuery = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"SampleLoginSaver",                      (__bridge id)kSecAttrGeneric,
                                      keychainItemID,                          (__bridge id)kSecAttrAccount,
                                      (__bridge id)kSecAttrAccessibleAfterFirstUnlock,  (__bridge id)kSecAttrAccessible,
                                      serializedDictionary,                    (__bridge id)kSecValueData,
                                      (__bridge id)kSecClassGenericPassword,            (__bridge id)kSecClass,
                                      [[NSBundle mainBundle] bundleIdentifier],(__bridge id)kSecAttrService,
                                      nil];
        
        OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)storageQuery, nil);
        
        if(osStatus != noErr) {
            // error
            NSLog(@"NSDictionary+Keychain: [%ld] Failed to save dictionary: %@ with storage query: %@", (long)osStatus, self, storageQuery);
            return NO;
        }
    } else
    {
        NSLog(@"NSDictionary+Keychain: Serialization of dictionary %@ failed with error: %@.", self, error.description);
    }
    
    //DEBUG
    NSLog(@"NSDictionary+Keychain: SUCCESS; Saved dictionary to keychain with key %@", keychainItemID);
    return YES;
}

- (BOOL)deleteFromKeychainWithKey:(NSString *)keychainItemID
{
    // Setup Keychain query properties
    NSDictionary *deleteQuery = [NSDictionary dictionaryWithObjectsAndKeys:
                                 keychainItemID,                        (__bridge id)kSecAttrAccount,
                                 (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                                 (__bridge id)kSecMatchLimitOne,        (__bridge id)kSecMatchLimit,
                                 (__bridge id)kCFBooleanTrue,           (__bridge id)kSecReturnAttributes,
                                 nil];

    NSDictionary *item = nil;
    
    CFTypeRef itemResult = (__bridge CFTypeRef)item;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)deleteQuery, &itemResult);

    if(osStatus != noErr) {
        // error
        NSLog(@"NSDictionary+Keychain: Failed to load ID %@ for deletion.", keychainItemID);
    }

    // If there is something to delete...
    if (itemResult)
    {
        NSMutableDictionary *mutableDeleteQuery = [(__bridge NSDictionary *)itemResult mutableCopy];
        [mutableDeleteQuery setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

        osStatus = SecItemDelete((__bridge CFDictionaryRef)mutableDeleteQuery);
    
        if(osStatus != noErr) {
            NSLog(@"NSDictionary+Keychain: Failed to delete ID %@, dictionary: %@ with delete query: %@", keychainItemID, self, deleteQuery);
        }

        NSLog(@"NSDictionary+Keychain: SUCCESS; Deleted dictionary from keychain with key %@", keychainItemID);
        return YES;
    }
    
    NSLog(@"NSDictionary+Keychain: No item to delete for item ID: %@.", keychainItemID);
    return NO;
}

@end
