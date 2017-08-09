//
//  RechargeButton.m
//  storyline
//
//  Created by Jimmy Xu on 11/9/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "RechargeButton.h"

@interface RechargeButton () {
    
    
}

@property (nonatomic, weak) UILabel *amountLabel;

@end

@implementation RechargeButton

-(void)awakeFromNib {
    [super awakeFromNib];
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    amountLabel.font = self.titleLabel.font;
    amountLabel.textColor = self.titleLabel.textColor;
    self.amountLabel = amountLabel;
    [self addSubview:amountLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)configureWithCost:(int)cost {
    [self setTitle:@"Recharge Now" forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"batteryIcon"] forState:UIControlStateNormal];
    
    self.amountLabel.text = [NSString stringWithFormat:@"%d", cost];
    
    [self.titleLabel sizeToFit];
    [self.amountLabel sizeToFit];
    
    if(cost == 0) {
        self.amountLabel.hidden = YES;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    float contentWidth = self.titleLabel.width + 13.0f + self.imageView.width + (self.amountLabel.hidden?0:13.0f+self.amountLabel.width);
    
    self.titleLabel.left = self.width/2 - contentWidth/2;
    self.imageView.left = self.titleLabel.right + 13.0f;
    self.amountLabel.left = self.imageView.right + 13.0f;
    self.amountLabel.centerY = self.height/2;
}

@end
