//
//  DetailViewController.m
//  Tune Search
//
//  Created by Demond Childers on 4/26/16.
//  Copyright © 2016 Demond Childers. All rights reserved.
//

#import "DetailViewController.h"
#import <Social/Social.h>

@interface DetailViewController ()




@end





@implementation DetailViewController


#pragma mark - Interactivity Methods



-(IBAction)emailButtonPressed:(id)sender {
    NSLog(@"Email");
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setSubject:[NSString stringWithFormat:@"%@ Music is the best ever",[_currentTuneDict objectForKey:@"artistName"]]];
        [mailVC setMessageBody:@"Do you think %@ is the best ever?" isHTML:false];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
