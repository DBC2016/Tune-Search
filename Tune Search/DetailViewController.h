//
//  DetailViewController.h
//  Tune Search
//
//  Created by Demond Childers on 4/26/16.
//  Copyright © 2016 Demond Childers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface DetailViewController : UIViewController<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *currentTuneDict;

@end





