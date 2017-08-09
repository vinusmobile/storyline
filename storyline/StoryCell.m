//
//  StoryCell.m
//  storyline
//
//  Created by Jimmy Xu on 12/5/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "StoryCell.h"
#import "WebImageView.h"

@interface StoryCell () {
    
}

@property (nonatomic, weak) IBOutlet WebImageView *webImageView;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *series;


@end

@implementation StoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.series.hidden = YES;

}

-(void)prepareForReuse {
    [super prepareForReuse];
    [self.webImageView stopLoadingImage];
    self.series.hidden = YES;
}

- (void)configureWithDict:(NSDictionary*)dict {
    [self.webImageView loadImageForURL:dict[@"image_url"]];
    self.title.text = dict[@"title"];
    
    if(dict[@"author"]) {
        self.author.text = [NSString stringWithFormat:@"Written by %@", dict[@"author"][@"name"]];
    } else {
        self.author.text = [NSString stringWithFormat:@"Written by Anonymous"];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
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
    
    self.author.left = self.webImageView.right + 7.0f;
    self.title.left = self.webImageView.right + 7.0f;
    self.series.left = self.webImageView.right + 7.0f;
    
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
