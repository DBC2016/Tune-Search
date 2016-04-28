//
//  TuneCollectionViewCell.h
//  Tune Search
//
//  Created by Demond Childers on 4/27/16.
//  Copyright © 2016 Demond Childers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TuneCollectionViewCell : UICollectionViewCell


@property (nonatomic, weak) IBOutlet UIImageView *tuneImageView;
@property (nonatomic, weak) IBOutlet UILabel     *tuneNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *tuneTextField;
@property (nonatomic, weak) IBOutlet UILabel     *artistNameLabel;



@end


