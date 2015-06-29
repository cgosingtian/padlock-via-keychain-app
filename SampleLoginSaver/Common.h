//
//  Common.h
//  SampleLoginSaver
//
//  Created by Chase Gosingtian on 5/18/15.
//  Copyright (c) 2015 KLab Cyscorpions, Inc. All rights reserved.
//

#ifndef SampleLoginSaver_Common_h
#define SampleLoginSaver_Common_h

static NSString * const kStatusAwaiting = @"Awaiting input.";
static NSString * const kStatusExisting = @"Password exists. Input previous password to delete.";
static NSString * const kStatusFailedExisting = @"Input did not match previous password. Input previous password to delete existing password.";
static NSString * const kStatusSaved = @"Password saved.";
static NSString * const kStatusFailed = @"Password saving failed.";
static NSString * const kStatusDeleted = @"Password deleted. Awaiting input.";

static NSString * const kKeychainKey = @"SampleLoginSaverKeychain";
static NSString * const kKeychainDictionaryKey = @"Keychain Password";

#endif
