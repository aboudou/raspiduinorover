//
//  SettingsViewController.m
//  raspiduinoroverPlus
//
//  Created by Arnaud Boudou on 26/12/2013.
//  Copyright (c) 2013 Arnaud Boudou. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Load user defaults
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.host"] != nil) {
        [self.host setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.host"]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.port"] != nil) {
        [self.port setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.port"]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.mjpegUrl"] != nil) {
        [self.mjpegUrl setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.mjpegUrl"]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction) saveAction:(id)sender {
    // Save user defaults
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.host text] forKey:@"com.aboudou.raspiduinorover.host"];
    [defaults setObject:[self.port text] forKey:@"com.aboudou.raspiduinorover.port"];
    [defaults setObject:[self.mjpegUrl text] forKey:@"com.aboudou.raspiduinorover.mjpegUrl"];
    [defaults synchronize];
    
    // Close view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancelAction:(id)sender {
    // Close view
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Misc

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.host resignFirstResponder];
    [self.port resignFirstResponder];
    [self.mjpegUrl resignFirstResponder];
}

@end
