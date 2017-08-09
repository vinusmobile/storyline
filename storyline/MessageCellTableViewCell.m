//
//  MessageCellTableViewCell.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "MessageCellTableViewCell.h"

static UIImage *selfImage = nil;
static UIImage *otherImage = nil;

typedef enum {
    PPMessageThreadCellLeft,
    PPMessageThreadCellRight,
    PPMessageThreadCellNoBubble
} CellPosition;

@interface MessageCellTableViewCell () {
    CellPosition bubblePosition;
    
    CGRect bubbleFrame;
    UIButton *bubbleButton;
    
    UILabel *contentLabel;
    
    UILabel *timestampLabel;
    
    NSString *senderID;
    
    UIView *typingIndicatorView;
    UIView *dot1;
    UIView *dot2;
    UIView *dot3;
}

@end

@implementation MessageCellTableViewCell

+ (void) createBubbleCacheIfNeeded {
    if (selfImage == nil) {
        selfImage = [[UIImage imageNamed:@"MessageThreadMeBubble"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        otherImage = [[UIImage imageNamed:@"MessageThreadPartnerBubble"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIEdgeInsets selfInset = UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 16.0f);
        UIEdgeInsets otherInset = UIEdgeInsetsMake(8.0f, 16.0f, 8.0f, 8.0f);
        selfImage = [selfImage resizableImageWithCapInsets:selfInset resizingMode:UIImageResizingModeStretch];
        otherImage = [otherImage resizableImageWithCapInsets:otherInset resizingMode:UIImageResizingModeStretch];
    }
}

+ (void) clearBubbleCache {
    selfImage = nil;
    otherImage = nil;
}

-(void) prepareForReuse {
    [super prepareForReuse];
    timestampLabel.text = nil;
    bubbleButton.hidden = NO;
    _message = nil;
    
    contentLabel.hidden = NO;
    typingIndicatorView.hidden = YES;
    [self stopAnimation];
}

//  setup all properties in one function
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [MessageCellTableViewCell createBubbleCacheIfNeeded];
        if ([reuseIdentifier isEqualToString:kPPMessageThreadCellLeft]) {
            bubblePosition = PPMessageThreadCellLeft;
            bubbleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [bubbleButton setBackgroundImage:otherImage forState:UIControlStateNormal];
            [bubbleButton setBackgroundImage:otherImage forState:UIControlStateHighlighted];
            bubbleButton.tintColor = [UIColor str_paleGreyColor];
            
            [bubbleButton addTarget:self action:@selector(bubblePressed:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if ([reuseIdentifier isEqualToString:kPPMessageThreadCellRight]) {
            bubblePosition = PPMessageThreadCellRight;
            bubbleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [bubbleButton setBackgroundImage:selfImage forState:UIControlStateNormal];
            [bubbleButton setBackgroundImage:selfImage forState:UIControlStateHighlighted];
            bubbleButton.tintColor = [UIColor str_purplyColor];

            [bubbleButton addTarget:self action:@selector(bubblePressed:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            bubblePosition = PPMessageThreadCellNoBubble;
        }
        
        contentLabel = [[UILabel alloc] init];
        [self.textLabel.superview addSubview:contentLabel];
        [self.textLabel.superview bringSubviewToFront:contentLabel];
        contentLabel.backgroundColor = [UIColor clearColor];
        
        if (bubbleButton) {
            [contentLabel.superview addSubview:bubbleButton];
            [contentLabel.superview bringSubviewToFront:contentLabel];
            contentLabel.userInteractionEnabled = NO;
        }
        
        //        self.selectedBackgroundView = self.backgroundView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (bubblePosition == PPMessageThreadCellNoBubble) {
            contentLabel.frame = CGRectMake(0, 0, self.width, 30);
            contentLabel.textAlignment = NSTextAlignmentCenter;
            contentLabel.textColor = [UIColor colorWithWhite:188/255.0f alpha:1.0f];
            contentLabel.font = [UIFont systemFontOfSize:16.0f];
        } else {
            typingIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30.0f, 20.0f)];
            typingIndicatorView.backgroundColor = [UIColor clearColor];
            dot1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5.0f, 5.0f)];
            dot1.backgroundColor = [UIColor colorWithWhite:210.0f/255.0f alpha:1.0f];
            dot1.centerY = typingIndicatorView.height/2;
            dot1.centerX = typingIndicatorView.width/2;
            dot1.layer.cornerRadius = dot1.height/2;
            dot1.layer.masksToBounds = YES;
            [typingIndicatorView addSubview:dot1];
            
            dot2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5.0f, 5.0f)];
            dot2.backgroundColor = [UIColor colorWithWhite:190.0f/255.0f alpha:1.0f];
            dot2.centerY = typingIndicatorView.height/2;
            dot2.centerX = dot1.left - 5.0f;
            dot2.layer.cornerRadius = dot2.height/2;
            dot2.layer.masksToBounds = YES;
            [typingIndicatorView addSubview:dot2];
            
            dot3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5.0f, 5.0f)];
            dot3.backgroundColor = [UIColor colorWithWhite:230.0f/255.0f alpha:1.0f];
            dot3.centerY = typingIndicatorView.height/2;
            dot3.centerX = dot1.right + 5.0f;
            dot3.layer.cornerRadius = dot3.height/2;
            dot3.layer.masksToBounds = YES;
            [typingIndicatorView addSubview:dot3];
            [self addSubview:typingIndicatorView];
            typingIndicatorView.hidden = YES;
            
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
            contentLabel.font = [UIFont systemFontOfSize:16.0f];
            
            if(bubblePosition == PPMessageThreadCellRight) {
                contentLabel.textColor = [UIColor whiteColor];
                
                timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 12)];
                timestampLabel.font = [UIFont systemFontOfSize:10.0f weight:UIFontWeightLight];
                timestampLabel.textColor = [UIColor colorWithWhite:182/255.0f alpha:1.0f];
                timestampLabel.textAlignment = NSTextAlignmentRight;
                
                [self addSubview:timestampLabel];
            } else if(bubblePosition == PPMessageThreadCellLeft) {
                contentLabel.textColor = [UIColor blackColor];
                
                timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 12)];
                timestampLabel.font = [UIFont systemFontOfSize:10.0f weight:UIFontWeightLight];
                timestampLabel.textColor = [UIColor colorWithWhite:182/255.0f alpha:1.0f];
                timestampLabel.textAlignment = NSTextAlignmentLeft;
                [self addSubview:timestampLabel];
                
//                avatarButton = [[PZAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
//                [self addSubview:avatarButton];
            }

            timestampLabel.font = [UIFont systemFontOfSize:10.0f weight:UIFontWeightLight];
        }
        contentLabel.numberOfLines = 0;
        timestampLabel.hidden = YES;
    }
    return self;
}

-(void)bubblePressed:(id)sender {
    
}

-(void)configureWithWithMessage:(Message *)message {
    _message = message;
    self.text = message.text;
    contentLabel.hidden = NO;

    if(bubblePosition != PPMessageThreadCellNoBubble) {
        typingIndicatorView.hidden = YES;
        
        if(!message.text) {
            bubbleButton.hidden = YES;
        } else {
            bubbleButton.hidden = NO;
        }
    }
    [self stopAnimation];
}

-(void)configureForTypingDelay {
    contentLabel.hidden = YES;
    typingIndicatorView.hidden = NO;
    [self startAnimation];
}

-(void)startAnimation {
    dot2.backgroundColor = [UIColor colorWithWhite:190.0f/255.0f alpha:1.0f];
    dot1.backgroundColor = [UIColor colorWithWhite:210.0f/255.0f alpha:1.0f];
    dot3.backgroundColor = [UIColor colorWithWhite:230.0f/255.0f alpha:1.0f];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
            dot2.backgroundColor = [UIColor colorWithWhite:210.0f/255.0f alpha:1.0f];
            dot1.backgroundColor = [UIColor colorWithWhite:230.0f/255.0f alpha:1.0f];
            dot3.backgroundColor = [UIColor colorWithWhite:190.0f/255.0f alpha:1.0f];
        } completion:^(BOOL finished) {
            dot2.backgroundColor = [UIColor colorWithWhite:190.0f/255.0f alpha:1.0f];
            dot1.backgroundColor = [UIColor colorWithWhite:210.0f/255.0f alpha:1.0f];
            dot3.backgroundColor = [UIColor colorWithWhite:230.0f/255.0f alpha:1.0f];
        }];
    }];
}

-(void)stopAnimation {
    [dot1.layer removeAllAnimations];
    [dot2.layer removeAllAnimations];
    [dot3.layer removeAllAnimations];
}

#pragma mark -
- (void)setText:(NSString *)text {
    if (bubblePosition != PPMessageThreadCellNoBubble) {
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.text = text;
    } else {
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.text = text;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+(CGFloat)heightForText:(NSString*)text {
    return [self sizeForText:text].height;
}

+(CGSize)sizeForText:(NSString*)text {
    NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    CGRect labelBounds = [text boundingRectWithSize:CGSizeMake(240, 0)
                                            options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                         attributes:attr
                                            context:nil];
    return CGSizeMake(ceilf(labelBounds.size.width), ceilf(labelBounds.size.height));
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (bubblePosition != PPMessageThreadCellNoBubble) {
        CGSize textSize;
        if(typingIndicatorView.hidden) {
            textSize = [MessageCellTableViewCell sizeForText:contentLabel.text];
            float xOffset = 0.0f;
            if(textSize.width < 20.0f) {
                xOffset = (20.0f - textSize.width)/2;
                textSize.width = 20.0f;
            }
            
            contentLabel.frame = CGRectMake(0, 0, textSize.width, textSize.height);
            bubbleFrame = CGRectMake(0.0f, 0, textSize.width + 26, textSize.height + VPADDING);
            
            bubbleButton.frame = bubbleFrame;
            contentLabel.centerY = bubbleButton.centerY;
            
            if(bubblePosition == PPMessageThreadCellLeft) {
                bubbleButton.left = 20.0f;
                contentLabel.left = bubbleButton.left + 17 + xOffset;
                timestampLabel.left = bubbleButton.right + 5;
            } else {
                bubbleButton.right = self.width - 20.0f;
                contentLabel.right = bubbleButton.right - 17 + xOffset;
                timestampLabel.right = bubbleButton.left - 5;
            }

        } else {
            textSize = typingIndicatorView.size;
            bubbleFrame = CGRectMake(0.0f, 0, textSize.width + 26, textSize.height + VPADDING);
            bubbleButton.frame = bubbleFrame;
            typingIndicatorView.centerY = bubbleButton.centerY;
            if(bubblePosition == PPMessageThreadCellLeft) {
                bubbleButton.left = 20.0f;
                typingIndicatorView.left = bubbleButton.left + 17;
                timestampLabel.left = bubbleButton.right + 5;
            } else {
                bubbleButton.right = self.width - 20.0f;
                typingIndicatorView.right = bubbleButton.right - 17;
                timestampLabel.right = bubbleButton.left - 5;
            }
        }
        timestampLabel.bottom = bubbleButton.bottom;

        
    } else {
        contentLabel.frame = CGRectMake(20, 0, self.width-40, self.height);
    }
}

@end
