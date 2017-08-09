//
//  MessageCellTableViewCell.h
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "Character.h"

#define kPPMessageThreadCellLeft @"PartnerCell"
#define kPPMessageThreadCellRight @"SelfCell"
#define kPPMessageThreadCellCenter @"CenterCell"

#define VPADDING 15.0f
#define HPADDING 30.0f

@interface MessageCellTableViewCell : UITableViewCell

+(CGFloat)heightForText:(NSString*)text;

+(void) clearBubbleCache;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

-(void) configureWithWithMessage:(Message*)message;
-(void)configureForTypingDelay;

@property (nonatomic, weak) Message *message;
@property (nonatomic,strong) NSString *text;

@property (nonatomic, weak) UINavigationController *navigationController;


@end
