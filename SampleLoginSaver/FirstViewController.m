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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateDoorStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Door Handler Methods

- (BOOL)isKeychainUnlock {
    if ([NSDictionary dictionaryFromKeychainWithKey:kKeychainKey]) {
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
