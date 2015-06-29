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

@property (assign, nonatomic) BOOL isKeychainExisting;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateKeychainStatus];
}

- (void)updateKeychainStatus {
    if ([self isKeychainPasswordExisting]) {
        self.keychainStatusLabel.text = kStatusExisting;
        _isKeychainExisting = YES;
    } else {
        self.keychainStatusLabel.text = kStatusAwaiting;
        _isKeychainExisting = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboardOnTap:(id)sender
{
    [[self view] endEditing:YES];
}

- (IBAction)submitKeychainPassword:(id)sender {
    
    if (_isKeychainExisting) {
        NSLog(@"KEYCHAIN EXISTING"); //DEBUG
        BOOL samePasswordInput = NO;
        
        NSString *textInput = self.keychainTextBox.text;
        
        NSDictionary *existingDictionary = [NSDictionary dictionaryFromKeychainWithKey:kKeychainKey];
        NSString *existingPassword = [existingDictionary objectForKey:kKeychainDictionaryKey];
        
        samePasswordInput = [textInput isEqualToString:existingPassword];
        NSLog(@"TEXTINPUT: %@ vs EXISTING: %@", textInput, existingPassword); //DEBUG
        if (samePasswordInput) {
            NSDictionary *dic = [NSDictionary dictionary];
            [dic deleteFromKeychainWithKey:kKeychainKey];
            
            self.keychainStatusLabel.text = kStatusDeleted;
            
            _isKeychainExisting = NO;
            self.keychainTextBox.text = @"";
        } else {
            self.keychainStatusLabel.text = kStatusFailedExisting;
        }
        NSLog(@"RETURNING"); //DEBUG
        return;
    }
    
    NSString *keychainKey = kKeychainKey;
    NSDictionary *keychainDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.keychainTextBox.text, kKeychainDictionaryKey, nil];
    [keychainDictionary saveToKeychainWithKey:keychainKey];
    
    NSDictionary *keychainTest = [NSDictionary dictionaryFromKeychainWithKey:keychainKey];
    NSLog(@"Testing password retrieval, retrieved: %@", keychainTest);
    
    if (keychainTest) {
        self.keychainStatusLabel.text = kStatusSaved;
        _isKeychainExisting = YES;
        self.keychainTextBox.text = @"";
    } else {
        self.keychainStatusLabel.text = kStatusFailed;
        _isKeychainExisting = NO;
    }
}

- (BOOL)isKeychainPasswordExisting {
    NSDictionary *keychainDictionary = [NSDictionary dictionaryFromKeychainWithKey:kKeychainKey];
    
    if (keychainDictionary) {
        return YES;
    } else {
        return NO;
    }
}


@end
