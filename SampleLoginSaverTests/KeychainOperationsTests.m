//
//  KeychainOperationsTests.m
//  SampleLoginSaver
//
//  Created by Chase Gosingtian on 9/10/15.
//  Copyright (c) 2015 KLab Cyscorpions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDictionary+Keychain.h"

NSString * const kTestDictionaryValueKey = @"kTestDictionaryValueKey";
static NSString * const kTestKeychainID = @"kTestKeychainID";

@interface KeychainOperationsTests : XCTestCase
@property (nonatomic, strong) NSMutableDictionary *testDictionary;

@end

@implementation KeychainOperationsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveKeychain {
    NSString *password = @"password";
    NSMutableDictionary *testDictionary = [[NSMutableDictionary alloc] init];
    [testDictionary setObject:password forKey:kTestDictionaryValueKey];
    
    BOOL result = [testDictionary saveToKeychainWithKey:kTestKeychainID];

    XCTAssertTrue(result, @"Saving to Keychain must be successful for value %@, value key %@, keychain ID %@", password, kTestDictionaryValueKey, kTestKeychainID);
}

- (void)testSaveRetrieveKeychain {
    NSString *password = @"password";
    NSMutableDictionary *testDictionary = [[NSMutableDictionary alloc] init];
    [testDictionary setObject:password forKey:kTestDictionaryValueKey];
    [testDictionary saveToKeychainWithKey:kTestKeychainID];
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryFromKeychainWithKey:kTestKeychainID];
    
    XCTAssertNotNil(resultDictionary, @"The saved Keychain item must be retrievable and not nil.");
}

- (void)testSaveUpdateKeychain {
    NSString *password = @"password";
    NSMutableDictionary *testDictionary = [[NSMutableDictionary alloc] init];
    [testDictionary setObject:password forKey:kTestDictionaryValueKey];
    [testDictionary saveToKeychainWithKey:kTestKeychainID];
    
    NSString *updatedPassword = @"updatedPassword";
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    [updateDictionary setObject:updatedPassword forKey:kTestDictionaryValueKey];
    [updateDictionary saveToKeychainWithKey:kTestKeychainID];
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryFromKeychainWithKey:kTestKeychainID];
    
    NSString *resultPassword = [resultDictionary objectForKey:kTestDictionaryValueKey];
    
    XCTAssertTrue([resultPassword isEqualToString:updatedPassword], @"If the Keychain item already exists, using saveToKeychainWithKey: must update the value correctly.");
}

- (void)testDeleteKeychain
{
    NSString *password = @"password";
    NSMutableDictionary *testDictionary = [[NSMutableDictionary alloc] init];
    [testDictionary setObject:password forKey:kTestDictionaryValueKey];
    [testDictionary saveToKeychainWithKey:kTestKeychainID];
    
    [testDictionary deleteFromKeychainWithKey:kTestKeychainID];
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryFromKeychainWithKey:kTestKeychainID];
    
    XCTAssertNil(resultDictionary, @"Retrieving a deleted keychain item must return nil.");
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
