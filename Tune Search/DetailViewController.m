//
//  DetailViewController.m
//  Tune Search
//
//  Created by Demond Childers on 4/26/16.
//  Copyright © 2016 Demond Childers. All rights reserved.
//

#import "DetailViewController.h"
#import <Social/Social.h>
#import <SafariServices/SafariServices.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface DetailViewController ()


@property (nonatomic, weak)   IBOutlet UIWebView               *tuneWebView;

@property (nonatomic, strong) IBOutlet UIButton                *tunePlayPauseButton;
@property (nonatomic, strong) IBOutlet UIButton                *tuneResetButton;
@property (nonatomic, strong) IBOutlet AVPlayer                *tunePlayer;
@property (nonatomic, strong) IBOutlet UIImageView             *tuneImageView;




@end

CGFloat lastScale;
CGFloat firstX;
CGFloat firsty;
CGFloat lastRotation;




@implementation DetailViewController

#pragma mark -Web Methods



//-(IBAction)showWebsitePressed:(id)sender {
//    NSLog(@"Show Website");
//    NSURL *webURL = [[NSURL alloc] initWithString:@"https://itunes.apple.com/"];
//    [_myWebView loadRequest:[NSURLRequest requestWithURL:webURL]];
//    
//}



-(IBAction)openURLPressed:(id)sender {
    NSLog(@"Open URL");
    NSURL *myURL = [NSURL URLWithString:@"http://www.genius.com"];
    if ([[UIApplication sharedApplication] canOpenURL:myURL])  {
        NSLog(@"Can Open");
        [[UIApplication sharedApplication] openURL:myURL];
    } else {
        NSLog(@"Can't Open");
        
    }
    
}



#pragma mark- Guesture Methods



-(IBAction)imagePinched:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
        
    }
    CGFloat scale = 1.0 - (lastScale -gesture.scale);
    CGAffineTransform currentTransform = _tuneImageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [_tuneImageView setTransform:newTransform];
    lastScale = gesture.scale;
}

-(IBAction)imageRotated:(UIRotationGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        lastRotation = 0.0;
        return;
    }
    CGFloat rotation = 0.0 - (lastRotation - gesture.rotation);
    CGAffineTransform currentTransform = _tuneImageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
    [_tuneImageView setTransform:newTransform];
    
    lastRotation = gesture.rotation;
}




#pragma mark - Audio Interactivty Methods


- (IBAction)audioPlayPauseButtonPressed:(id)sender {
    NSLog(@"Play Preview");
    if ([[[_tunePlayPauseButton titleLabel] text] isEqualToString:@"Play"]) {
        NSLog(@"About to play");
        [_tunePlayPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [_tunePlayer play];
    } else {
        [_tunePlayPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        [_tunePlayer pause];
        
    }
}

- (IBAction)audioResetButtonPressed:(id)sender {
    NSLog(@"Reset");
    [_tunePlayer.currentItem seekToTime:kCMTimeZero];
}


-(void) playerItemDidReachEnd: (NSNotification *)notification {
    NSLog(@"Player Ended");
    AVPlayerItem *playerItemer = [notification object];
    if (playerItemer == _tunePlayer.currentItem) {
        [_tunePlayer.currentItem seekToTime:kCMTimeZero];
        [_tunePlayer pause];
    }
    
}




#pragma mark - Interactivity Methods



-(IBAction)emailButtonPressed:(id)sender {
    NSLog(@"Email");
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setSubject:[NSString stringWithFormat:@"%@ Music is the best ever",[_currentTuneDict objectForKey:@"artistName"]]];
        [mailVC setMessageBody:[NSString stringWithFormat:@"Do you think %@ is the best ever?",[_currentTuneDict objectForKey:@"artistName"]] isHTML:false];
        [mailVC setToRecipients:@[@"binkdetroit@gmail.com"]];
        [self.navigationController presentViewController:mailVC animated:true completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:true completion:nil];
}


-(IBAction)smsButtonPressed:(id)sender {
    NSLog(@"sms");
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *textVC = [[MFMessageComposeViewController alloc] init];
        textVC.body = [NSString stringWithFormat:@"I love this new song by %@",[_currentTuneDict objectForKey:@"artistName"]];
        textVC.messageComposeDelegate = self;
        [self.navigationController presentViewController:textVC animated:true completion:nil];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction)facebookButtonPressed:(id)sender {
    NSLog(@"facebook");
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *fbVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbVC setInitialText:[NSString stringWithFormat:@"Really feeling this new %@ album!",[_currentTuneDict objectForKey:@"artistName"]]];
        [self.navigationController presentViewController:fbVC animated:true completion:nil];
    }
}

-(IBAction)twitterButtonPressed:(id)sender {
    NSLog(@"twitter");
    
}

-(IBAction)whateverButtonPressed:(id)sender {
    NSLog(@"whatever");
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[[NSString stringWithFormat:@"I'm really feeling these songs by %@",[_currentTuneDict objectForKey:@"artistName"]]] applicationActivities:nil] ;
                                             
    [self.navigationController presentViewController:activityVC animated:true completion:nil];
    
                                            
}
    



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Got: %@",_currentTuneDict);
    NSString *previewString = [_currentTuneDict objectForKey:@"previewUrl"];
    NSLog(@"Preview:%@",previewString);
    NSURL *tunesURL = [NSURL URLWithString:previewString];
    _tunePlayer = [AVPlayer playerWithURL:tunesURL];
    _tunePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_tunePlayer currentItem]];
    
    NSString *filename = [NSString stringWithFormat:@"%@.jpg",[_currentTuneDict objectForKey:@"trackId"]];
    _tuneImageView.image = [UIImage imageNamed:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
