//
//  SecondViewController.m
//  SampleLoginSaver
//
//  Created by Chase Gosingtian on 5/15/15.
//  Copyright (c) 2015 KLab Cyscorpions, Inc. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UILabel *keychainStatusLabel;
@property (weak, nonatomic) IBOutlet UITextView *keychainTextBox;

@end

@implementation SecondViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateKeychainStatus];
}

#pragma mark - Keychain Status Checking

- (void)updateKeychainStatus {
    if ([self isKeychainPasswordExisting]) {
        self.keychainStatusLabel.text = kStatusExisting;
    } else {
        self.keychainStatusLabel.text = kStatusAwaiting;
    }
}

#pragma mark - Keyboard Handling

- (IBAction)dismissKeyboardOnTap:(id)sender
{
    [[self view] endEditing:YES];
}

#pragma mark - Button Functionalities

- (IBAction)deleteKeychainPassword:(id)sender {
    NSDictionary *existingDictionary = [NSDictionary dictionaryFromKeychainWithKey:kKeychainKey];
    
    if (existingDictionary) {
        if ([existingDictionary deleteFromKeychainWithKey:kKeychainKey]) {
            self.keychainStatusLabel.text = kStatusDeleted;
        
            self.keychainTextBox.text = @"";
        } else {
            self.keychainStatusLabel.text = @"Delete failed.";
        }
    } else {
        self.keychainStatusLabel.text = @"Nothing to delete.";
    }
}

- (IBAction)submitKeychainPassword:(id)sender {
    
    // If you input the same password, delete it
    if ([self isKeychainPasswordExisting]) {
        NSString *textInput = self.keychainTextBox.text;
        
        NSDictionary *existingDictionary = [NSDictionary dictionaryFromKeychainWithKey:kKeychainKey];
        NSString *existingPassword = [existingDictionary objectForKey:kKeychainDictionaryKey];
        
        BOOL samePasswordInput = [textInput isEqualToString:existingPassword];

        if (samePasswordInput) {
            [existingDictionary deleteFromKeychainWithKey:kKeychainKey];
            
            self.keychainStatusLabel.text = kStatusDeleted;
            self.keychainTextBox.text = @"";
        } else {
            self.keychainStatusLabel.text = kStatusFailedExisting;
        }

        return;
    }
    
    // Save the password if there's no previous entry
    [self saveToKeychainWithKey:kKeychainKey passwordString:self.keychainTextBox.text];
    
    NSDictionary *keychainTest = [NSDictionary dictionaryFromKeychainWithKey:kKeychainKey];
    
    if (keychainTest) {
        self.keychainStatusLabel.text = kStatusSaved;
        self.keychainTextBox.text = @"";
    } else {
        self.keychainStatusLabel.text = kStatusFailed;
    }
}

#pragma mark - Helper Methods

- (void)saveToKeychainWithKey:(NSString *)keychainItemID passwordString:(NSString *)passwordString {
    NSMutableDictionary *passwordDictionary = [[NSMutableDictionary alloc] init];
    [passwordDictionary setObject:passwordString forKey:kKeychainDictionaryKey];
    [passwordDictionary saveToKeychainWithKey:keychainItemID];
}

- (BOOL)isKeychainPasswordExisting {
    NSDictionary *keychainDictionary = [NSDictionary dictionaryFromKeychainWithKey:kKeychainKey];
    
    if (keychainDictionary && [keychainDictionary objectForKey:kKeychainDictionaryKey]) {
        return YES;
    } else {
        return NO;
    }
}


@end
