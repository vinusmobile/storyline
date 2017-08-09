//
//  PurchasingTableViewCell.m
//  storyline
//
//  Created by Jimmy Xu on 12/4/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "PurchasingTableViewCell.h"

@implementation PurchasingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.subtitleLabel.text = nil;
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.subtitleLabel.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    
    self.subtitleLabel.centerX = self.width/2 + 10.0f;
    self.titleLabel.centerX = self.width/2 + 10.0f;
    
    self.titleLabel.centerY = self.height/2;
    
    self.iconImageView.centerY = self.height/2;
    self.iconImageView.right = self.titleLabel.left - 7.0f;
    
    if(self.subtitleLabel.text.length > 0) {
        self.titleLabel.centerY = self.height/2 - 7.0f;
        self.subtitleLabel.top = self.titleLabel.bottom + 3.0f;
    }
}

@end
