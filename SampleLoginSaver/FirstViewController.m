//
//  FirstViewController.m
//  SampleLoginSaver
//
//  Created by Chase Gosingtian on 5/15/15.
//  Copyright (c) 2015 KLab Cyscorpions, Inc. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *doorKeychainImage;
@property (weak, nonatomic) IBOutlet UILabel *doorKeychainStatusLabel;

@end

@implementation FirstViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateDoorStatus];
}

#pragma mark - Door Handler Methods

- (BOOL)isKeychainUnlock {
    NSDictionary *existingDictionary = [NSDictionary dictionaryFromKeychainWithKey:kKeychainKey];
    
    if (existingDictionary && [existingDictionary objectForKey:kKeychainDictionaryKey]) {
        return YES;
    }
    
    return NO;
}

- (void)updateDoorStatus {
    if ([self isKeychainUnlock]) {
        [self unlockDoorKeychain];
    } else {
        [self lockDoorKeychain];
    }
}

- (void)unlockDoorKeychain {
    self.doorKeychainStatusLabel.textColor = [UIColor greenColor];
    self.doorKeychainStatusLabel.text = @"UNLOCKED";
    
    self.doorKeychainImage.image = [UIImage imageNamed:@"door_open"];
}

- (void)lockDoorKeychain {
    self.doorKeychainStatusLabel.textColor = [UIColor redColor];
    self.doorKeychainStatusLabel.text = @"LOCKED";
    
    self.doorKeychainImage.image = [UIImage imageNamed:@"door_close"];
}


@end
