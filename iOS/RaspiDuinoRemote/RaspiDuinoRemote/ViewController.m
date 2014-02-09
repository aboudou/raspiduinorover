//
//  ViewController.m
//  RaspiDuinoRemote
//
//  Created by Arnaud Boudou on 10/01/2014.
//  Copyright (c) 2014 Arnaud Boudou. All rights reserved.
//

#import "ViewController.h"
#import "SettingsViewController.h"

@interface ViewController ()

@end

@implementation ViewController


#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.btnLight.layer.borderWidth=1.0f;
    self.btnLight.layer.cornerRadius=5;
    self.btnLight.layer.borderColor=[[UIColor blackColor] CGColor];

    self.streamView.layer.borderWidth=1.0f;
    self.streamView.layer.cornerRadius=5;
    self.streamView.layer.borderColor=[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f] CGColor];
    
    [self setLightButtonStatus:NO];

    [self.lblPanDegrees setText:@""];
    [self.lblTiltDegrees setText:@""];

    self.panBackground.layer.borderWidth=1.0f;
    self.panBackground.layer.cornerRadius=5;
    self.panBackground.layer.borderColor=[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f] CGColor];
    self.tiltBackground.layer.borderWidth=1.0f;
    self.tiltBackground.layer.cornerRadius=5;
    self.tiltBackground.layer.borderColor=[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f] CGColor];

    [self.pvMotorA setProgress:0.0f];
    [self.pvMotorB setProgress:0.0f];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    transform = CGAffineTransformTranslate(transform, 0.0f, -1.0f);
    self.pvMotorA.transform = transform;
    self.pvMotorB.transform = transform;
    
    [self.status setText:@"Not connected"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Load user defaults
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.host"] != nil) {
        _currentHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.host"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.port"] != nil) {
        _currentPort = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.port"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.mjpegUrl"] != nil) {
        _currentMjpegUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.aboudou.raspiduinorover.mjpegUrl"];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions (rover moves)

- (IBAction)goForward:(id)sender {
    [self darkenButton:sender];
    [self sendCommand:@"forward"];
}


- (IBAction)goReverse:(id)sender {
    [self darkenButton:sender];
    [self sendCommand:@"reverse"];
}


- (IBAction)turnLeft:(id)sender {
    [self darkenButton:sender];
    [self sendCommand:@"left"];
}


- (IBAction)turnRight:(id)sender {
    [self darkenButton:sender];
    [self sendCommand:@"right"];
}


- (IBAction)stop:(id)sender {
    [sender setAlpha:0.5f];
    [self sendCommand:@"stop"];
}


#pragma mark - Actions (camera moves)

- (IBAction)servoUp:(id)sender {
    [self darkenButton:sender];
    _tiltServoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(timerFireMethod:)
                                                     userInfo:@"servoTiltUp"
                                                      repeats:YES];
}

- (IBAction)servoDown:(id)sender {
    [self darkenButton:sender];
    _tiltServoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(timerFireMethod:)
                                                     userInfo:@"servoTiltDown"
                                                      repeats:YES];
}

- (IBAction)servoLeft:(id)sender {
    [self darkenButton:sender];
    _panServoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(timerFireMethod:)
                                                    userInfo:@"servoPanLeft"
                                                     repeats:YES];
}

- (IBAction)servoRight:(id)sender {
    [self darkenButton:sender];
    _panServoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(timerFireMethod:)
                                                    userInfo:@"servoPanRight"
                                                     repeats:YES];
}


- (IBAction)servoCenter:(id)sender {
    [sender setAlpha:0.5f];
    [self sendCommand:@"servoCenter"];
}


- (IBAction)servoStop:(id)sender {
    [sender setAlpha:0.5f];
    [_tiltServoTimer invalidate];
    [_panServoTimer invalidate];
}


#pragma mark - Actions (misc)


- (IBAction)switchLight:(id)sender {
    if (_connectInProgress) {
        if (self.btnLight.alpha == 0.5f) {
            [self setLightButtonStatus:YES];
        } else {
            [self setLightButtonStatus:NO];
        }

        [_dataTimer invalidate];
        [self sendCommand:@"light"];
        [self startTimer];
    }
}


- (IBAction)darkenButton:(id)sender {
    [sender setAlpha:1.0f];
}


- (IBAction)doConnect:(id)sender {
    [self doDisconnect:nil];
    [self initNetworkCommunication];
    _connectInProgress = YES;
    
    [self.status setText:@"Connection in progress…"];
    [self performSelectorInBackground:@selector(waitForConnection:) withObject:nil];
    
    if ([_currentMjpegUrl length] > 0) {
        // Wait 1.5 second after connection in order to let video stream start
        _videoStreamTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                             target:self
                                                           selector:@selector(startVideoStream)
                                                           userInfo:nil
                                                            repeats:NO];

    }
}


- (IBAction)doDisconnect:(id)sender {
    [_dataTimer invalidate];
    
    [self sendCommand:@"reset"];
    [_outputStream close];
    [_inputStream close];
    
    _connectInProgress = NO;
    
    [self.streamView stop];
    
    [self.status setText:@"Not connected"];
    
    [self setLightButtonStatus:NO];
    [self.lblPanDegrees setText:@""];
    [self.lblTiltDegrees setText:@""];
    [self.pvMotorA setProgress:0.0f];
    [self.pvMotorB setProgress:0.0f];
}


- (IBAction)openSettings:(id)sender {
    // Disconnect
    [self doDisconnect:nil];
    
    // Open settings view
    SettingsViewController *settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:settingsController];
    [controller.navigationBar setHidden:YES];
    
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Misc (Network related)


- (void)timerFireMethod:(NSTimer *)timer {
    [self sendCommand:timer.userInfo];
}


- (void) sendCommand:(NSString *)command {
    if (_connectInProgress) {
        NSData *data = [[NSData alloc] initWithData:[command dataUsingEncoding:NSASCIIStringEncoding]];
        [_outputStream write:[data bytes] maxLength:[data length]];
    }
}


- (void) waitForConnection:(id) sender {
    @autoreleasepool {
        // Connect to RaspiDuinoRover server
        
        while (([_outputStream streamStatus] != NSStreamStatusOpen && [_outputStream streamStatus] != NSStreamStatusError) && _connectInProgress) {
            [self.status performSelectorOnMainThread:@selector(setText:) withObject:@"Connection in progress…" waitUntilDone:YES];
        }
        if ([_outputStream streamStatus] == NSStreamStatusOpen) {
            [self.status performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"Connected to %@:%@", _currentHost, _currentPort] waitUntilDone:YES];
        } else if ([_outputStream streamStatus] == NSStreamStatusError) {
            [self.status performSelectorOnMainThread:@selector(setText:) withObject:@"Could not connect to RaspiDuinoRover" waitUntilDone:YES];
        } else {
            [self.status performSelectorOnMainThread:@selector(setText:) withObject:@"Not connected to RaspiDuinoRover" waitUntilDone:YES];
        }
    }
}


- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)CFBridgingRetain(_currentHost), [_currentPort intValue], &readStream, &writeStream);
    _outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    _inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_outputStream open];
    [_inputStream open];
    
    [_inputStream setDelegate:self];
    
    [self startTimer];
}


- (void)startVideoStream {
    NSURL *url = [NSURL URLWithString:_currentMjpegUrl];
    self.streamView.url = url;
    [self.streamView play];
    [_videoStreamTimer invalidate];
}


- (void)startTimer {
    _dataTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(getServerData:)
                                                userInfo:nil
                                                 repeats:YES];
}


- (void)getServerData:(id)sender {
    [self sendCommand:@"getData"];
}



#pragma mark - Misc (UI related)


- (void) setLightButtonStatus:(BOOL) lightOn {
    if (lightOn) {
        self.btnLight.alpha = 1.0f;
        [self.btnLight setImage:[UIImage imageNamed:@"lighton.png"] forState:UIControlStateNormal];
        [self.btnLight setImage:[UIImage imageNamed:@"lighton.png"] forState:UIControlStateSelected];
    } else {
        self.btnLight.alpha = 0.5f;
        [self.btnLight setImage:[UIImage imageNamed:@"lightoff.png"] forState:UIControlStateNormal];
        [self.btnLight setImage:[UIImage imageNamed:@"lightoff.png"] forState:UIControlStateSelected];
    }
}


- (void) updateUIWithServerData:(NSString *)data {
    // Split output data
    NSArray *dataItems = [data componentsSeparatedByString:@"#"];
    NSString *lightState = [dataItems objectAtIndex:0];
    NSString *motorCurrentA= [dataItems objectAtIndex:1];
    NSString *motorCurrentB = [dataItems objectAtIndex:2];
    NSString *panAngle = [dataItems objectAtIndex:3];
    NSString *tiltAngle = [dataItems objectAtIndex:4];
    
    if ([lightState isEqualToString:@"0"]) {
        [self setLightButtonStatus:NO];
    } else {
        [self setLightButtonStatus:YES];
    }
    
    [self.lblPanDegrees setText:panAngle];
    [self.lblTiltDegrees setText:tiltAngle];
    
    // Current is given by motor shield with a linear voltage :
    //  - 0 volt means 0 ampere (value from server : 0)
    //  - 3.3 volts means 2 amperes (value from server : 168) <-- max continuous current allowed by L298 motor driver
    //  - 5 volt means 8,25 amperes (value from server : 255) <-- largely over L298 motor driver electrical specifications
    float progressA = ([motorCurrentA floatValue] / 255.0f);
    float progressB = ([motorCurrentB floatValue] / 255.0f);
    
    if (progressA > (168.0f / 255.0f)) { // over 2 amperes
        [self.pvMotorA setProgressTintColor:[UIColor blackColor]];
    } else if (progressA > ((168.0f / 255.0f) * 0.9)) { // over 1.8 amperes (90% of 2A)
        [self.pvMotorA setProgressTintColor:[UIColor redColor]];
    } else if (progressA > ((168.0f / 255.0f) * 0.75)) { // over 1.5 amperes (75% of 2A)
        [self.pvMotorA setProgressTintColor:[UIColor orangeColor]];
    } else {
        [self.pvMotorA setProgressTintColor:[UIColor greenColor]];
    }

    if (progressB > (168.0f / 255.0f)) { // over 2 amperes
        [self.pvMotorB setProgressTintColor:[UIColor blackColor]];
    } else if (progressB > ((168.0f / 255.0f) * 0.9)) { // over 1.8 amperes (90% of 2A)
        [self.pvMotorB setProgressTintColor:[UIColor redColor]];
    } else if (progressB > ((168.0f / 255.0f) * 0.75)) { // over 1.5 amperes (75% of 2A)
        [self.pvMotorB setProgressTintColor:[UIColor orangeColor]];
    } else {
        [self.pvMotorB setProgressTintColor:[UIColor greenColor]];
    }
    
    [self.pvMotorA setProgress:progressA animated:YES];
    [self.pvMotorB setProgress:progressB animated:YES];

}

#pragma mark - NSStreamDelegate

-(void)stream:(NSStream*)theStream handleEvent:(NSStreamEvent)streamEvent {
 	switch(streamEvent){
 		case NSStreamEventOpenCompleted:
            break;
    
        case NSStreamEventHasBytesAvailable:
            if (theStream == _inputStream) {
                uint8_t buffer[1024];
                long len;
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output =[[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        if (nil!= output) {
                            //NSLog(@"%@", output);
                            [self performSelectorOnMainThread:@selector(updateUIWithServerData:) withObject:output waitUntilDone:NO];
                        }
                    }
                }
            }
            break;
        
        case NSStreamEventErrorOccurred:
            break;
 		
        case NSStreamEventEndEncountered:
            break;
 		
        default:
            break;
	}
}

@end
