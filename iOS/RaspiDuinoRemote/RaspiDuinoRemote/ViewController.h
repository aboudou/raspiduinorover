//
//  ViewController.h
//  RaspiDuinoRemote
//
//  Created by Arnaud Boudou on 10/01/2014.
//  Copyright (c) 2014 Arnaud Boudou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionJpegImageView.h"

@interface ViewController : UIViewController <NSStreamDelegate> {
    BOOL _connectInProgress;
    
    NSOutputStream *_outputStream;
    NSInputStream *_inputStream;
    
    NSString *_currentHost;
    NSString *_currentPort;
    NSString *_currentMjpegUrl;
    
    NSTimer *_dataTimer;
    NSTimer *_panServoTimer;
    NSTimer *_tiltServoTimer;
    NSTimer *_videoStreamTimer;
}

@property(nonatomic, strong) IBOutlet UIButton *connect;
@property(nonatomic, strong) IBOutlet UIButton *disconnect;
@property(nonatomic, strong) IBOutlet UILabel *status;

@property(nonatomic, strong) IBOutlet UIButton *btnForward;
@property(nonatomic, strong) IBOutlet UIButton *btnReverse;
@property(nonatomic, strong) IBOutlet UIButton *btnLeft;
@property(nonatomic, strong) IBOutlet UIButton *btnRight;
@property(nonatomic, strong) IBOutlet UIButton *btnStop;

@property(nonatomic, strong) IBOutlet UIButton *btnLight;

@property(nonatomic, strong) IBOutlet UIButton *btnServoUp;
@property(nonatomic, strong) IBOutlet UIButton *btnServoDown;
@property(nonatomic, strong) IBOutlet UIButton *btnServoLeft;
@property(nonatomic, strong) IBOutlet UIButton *btnServoRight;
@property(nonatomic, strong) IBOutlet UIButton *btnServoCenter;

@property(nonatomic, strong) IBOutlet UIButton *btnSettings;

@property(nonatomic, strong) IBOutlet UILabel *lblPanDegrees;
@property(nonatomic, strong) IBOutlet UILabel *lblTiltDegrees;
@property(nonatomic, strong) IBOutlet UIImageView *panBackground;
@property(nonatomic, strong) IBOutlet UIImageView *tiltBackground;

@property(nonatomic, strong) IBOutlet UIProgressView *pvMotorA;
@property(nonatomic, strong) IBOutlet UIProgressView *pvMotorB;

@property(nonatomic, strong) IBOutlet MotionJpegImageView *streamView;

- (IBAction)doConnect:(id)sender;
- (IBAction)doDisconnect:(id)sender;

- (IBAction)goForward:(id)sender;
- (IBAction)goReverse:(id)sender;
- (IBAction)turnLeft:(id)sender;
- (IBAction)turnRight:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)servoUp:(id)sender;
- (IBAction)servoDown:(id)sender;
- (IBAction)servoLeft:(id)sender;
- (IBAction)servoRight:(id)sender;
- (IBAction)servoCenter:(id)sender;
- (IBAction)servoStop:(id)sender;

- (IBAction)switchLight:(id)sender;

- (IBAction)darkenButton:(id)sender;

- (IBAction)openSettings:(id)sender;

@end