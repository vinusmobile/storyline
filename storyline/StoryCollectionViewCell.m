//
//  StoryCollectionViewCell.m
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "StoryCollectionViewCell.h"
#import "WebImageView.h"
#import "ConversationMarker+CoreDataClass.h"

@interface StoryCollectionViewCell () {
    BOOL forProfile;
}

@property (nonatomic, weak) IBOutlet WebImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UILabel *series;

@end
@implementation StoryCollectionViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    self.series.hidden = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(1.0f, 0.9f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    self.gradientView.layer.mask = gradientLayer;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView stopLoadingImage];
    self.series.hidden = YES;
}

- (void)configureWithDict:(NSDictionary*)dict {
    [self.imageView loadImageForURL:dict[@"image_url"]];
    self.title.text = dict[@"title"];
    forProfile = NO;
    
    if(dict[@"author"]) {
        self.author.text = [NSString stringWithFormat:@"Written by %@", dict[@"author"][@"name"]];
    } else {
        self.author.text = [NSString stringWithFormat:@"Written by Anonymous"];
    }
    
    [self setNeedsLayout];
}

- (void)configureWithMarker:(ConversationMarker*)marker {
    [self.imageView loadImageForURL:marker.image_url];
    self.title.text = marker.title;
    forProfile = YES;
    
    if(marker.author_name) {
        self.author.text = [NSString stringWithFormat:@"Written by %@", marker.author_name];
    } else {
        self.author.text = [NSString stringWithFormat:@"Written by Anonymous"];
    }
    
    if(marker.series_total > 0) {
        self.series.hidden = NO;
        self.series.text = [NSString stringWithFormat:@"Chapter %d of %d", marker.series_current, marker.series_total];
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(1.0f, 1.0f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.0f);
    self.gradientView.layer.mask = gradientLayer;
    
    [self setNeedsLayout];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor, (id)[UIColor clearColor].CGColor, nil];
    if(forProfile) {
        gradientLayer.startPoint = CGPointMake(1.0f, 1.0f);
        gradientLayer.endPoint = CGPointMake(1.0f, 0.0f);
    } else {
        gradientLayer.startPoint = CGPointMake(1.0f, 0.9f);
        gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    }
    self.gradientView.layer.mask = gradientLayer;
    
    CGRect authorBounds = [self.author.text boundingRectWithSize:CGSizeMake(self.width - 22, 0)
                                            options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                         attributes:@{NSFontAttributeName: self.author.font}
                                            context:nil];

    CGRect titleBounds = [self.title.text boundingRectWithSize:CGSizeMake(self.width - 22, 0)
                                                         options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                      attributes:@{NSFontAttributeName: self.title.font}
                                                         context:nil];
    
    self.author.frame = CGRectMake(0, 0, ceilf(authorBounds.size.width), ceilf(authorBounds.size.height));
    self.title.frame = CGRectMake(0, 0, ceilf(titleBounds.size.width), ceilf(titleBounds.size.height));
    
    self.author.left = 11;
    self.title.left = 11;
    self.series.left = 11;
    
    if(self.series.hidden) {
        self.author.bottom = self.height - 12;
        self.title.bottom = self.author.top - 3;
    } else {
        self.series.bottom = self.height - 3;
        self.author.bottom = self.series.top - 3;
        self.title.bottom = self.author.top - 3;
    }
    
}

@end
