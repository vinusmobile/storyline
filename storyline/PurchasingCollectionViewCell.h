//
//  PurchasingCollectionViewCell.h
//  storyline
//
//  Created by Jimmy Xu on 11/8/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchasingCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;
@property (nonatomic, weak) IBOutlet UILabel *numChargesLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;

@end
