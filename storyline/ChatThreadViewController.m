//
//  ChatThreadViewController.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "ChatThreadViewController.h"
#import "MessageCellTableViewCell.h"

#import "BatteryLowViewController.h"
#import "WebImageView.h"
#import "ConversationMarker+CoreDataClass.h"
#import "DataManager.h"
#import "Amplitude.h"
#import "ResourceManager.h"
#import "Appirater.h"
#import "MainScrollViewController.h"
#import "AppDelegate.h"

@interface ChatThreadViewController () <UITableViewDelegate, UITableViewDataSource, batteryLowProtocol> {
    BOOL finishedLayout;
    BOOL animationInProgress;
    
    int typingDelay;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (nonatomic, weak) IBOutlet UIView *footerView;

@property (nonatomic, weak) UIView *tableFooterView;

@property (nonatomic, weak) IBOutlet WebImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *firstMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UIButton *startStoryButton;
@property (weak, nonatomic) IBOutlet UILabel *seriesLabel;

@property (nonatomic, weak) IBOutlet WebImageView *footer_coverImageView;
@property (nonatomic, weak) IBOutlet UILabel *footer_readNextLabel;
@property (nonatomic, weak) IBOutlet UILabel *footer_titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *footer_authorLabel;
@property (weak, nonatomic) IBOutlet UIView *footer_gradientView;
@property (weak, nonatomic) IBOutlet UIButton *footer_startStoryButton;
@property (weak, nonatomic) IBOutlet UILabel *footer_seriesLabel;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)nextButtonAction:(id)sender;
- (IBAction)startStoryButtonAction:(id)sender;
- (IBAction)startNextStoryButtonAction:(id)sender;

@end

@implementation ChatThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    finishedLayout = NO;
    
    self.view.backgroundColor = [UIColor str_paleGreyBackgroundColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.startStoryButton.layer.borderColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f].CGColor;
    [self.startStoryButton setTitleColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.startStoryButton.layer.borderWidth = 1.0f;
    
    self.footer_startStoryButton.layer.borderColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f].CGColor;
    [self.footer_startStoryButton setTitleColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.footer_startStoryButton.layer.borderWidth = 1.0f;

    self.nextButton.layer.borderWidth = 1.0f;
    self.nextButton.layer.borderColor = [UIColor str_purplyColor].CGColor;
    [self.nextButton setTitleColor:[UIColor str_purplyColor] forState:UIControlStateNormal];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(startStoryButtonAction:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionUp;
    [self.headerView addGestureRecognizer:swipeDown];
        
    self.headerView.bottom = -1;
    self.bodyView.top = 0;
    self.footerView.hidden = YES;
    
    self.tableView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:1].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(1.0f, 1.0f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.4f);
    self.gradientView.layer.mask = gradientLayer;
    
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.frame = self.footer_gradientView.bounds;
    gradientLayer2.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:1].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer2.startPoint = CGPointMake(1.0f, 1.0f);
    gradientLayer2.endPoint = CGPointMake(1.0f, 0.4f);
    self.footer_gradientView.layer.mask = gradientLayer2;
}

- (BOOL)showingCover {
    return self.headerView.bottom > 0;
}

- (void)enableNextButton {
    self.nextButton.enabled = YES;
}

- (IBAction)nextButtonAction:(id)sender {
    if([DataManager  waitingOnBattery] && ![DataManager isSubscriptionActive]) {
        BatteryLowViewController *lowBat =
        [[UIStoryboard storyboardWithName:@"Main"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"battery_low"];
        lowBat.delegate = self;
        [self presentViewController:lowBat animated:YES completion:^{
        }];
    } else {
        if(self.conversation.messages.count > self.conversation.currentReadIndex + 1) {
            Message *currentMessageObject = self.conversation.messages[self.conversation.currentReadIndex];
            Message *nextMessageObject = self.conversation.messages[self.conversation.currentReadIndex+1];
            
            
            if([DataManager lowBatteryStartDate]) {
                [DataManager setLowBatteryStartDate:nil];
                [self showNextMessage];
            } else if(nextMessageObject.batteryLow || currentMessageObject.batteryLow) {
                if(nextMessageObject.batteryLow) {
                    self.conversation.currentReadIndex++;
                }
                
                if([DataManager isSubscriptionActive]) {
                    [self.tableView reloadData];
                    [self showNextMessage];
                } else {
                    [DataManager setLowBatteryStartDate:nil];
                    
                    BatteryLowViewController *lowBat =
                    [[UIStoryboard storyboardWithName:@"Main"
                                               bundle:NULL] instantiateViewControllerWithIdentifier:@"battery_low"];
                    lowBat.delegate = self;
                    [self presentViewController:lowBat animated:YES completion:^{
                        [self.tableView reloadData];
                    }];
                }
            } else {
                [self showNextMessage];
            }
            
            self.tableFooterView.hidden = YES;
        } else {
            //at end
            [[Amplitude instance] logEvent:@"Finished Story" withEventProperties:@{@"story_id":self.conversation.conversationID}];

            [Appirater userDidSignificantEvent:YES];
            
            [self showConversationEnd:YES];
        }
    }
}

#pragma mark -
-(void)batteryRecharged {
    if(self.conversation.messages.count > self.conversation.currentReadIndex + 1) {
        [self showNextMessage];
    } else {
        //at end
        [[Amplitude instance] logEvent:@"Finished Story" withEventProperties:@{@"story_id":self.conversation.conversationID}];
        [Appirater userDidSignificantEvent:YES];
        [self showConversationEnd:YES];
    }
}

-(void)showNextMessage {
    self.conversation.currentReadIndex++;
    
    Message *nextMessage = self.conversation.messages[self.conversation.currentReadIndex];
    if(nextMessage.typingDelay > 0) {
        typingDelay = nextMessage.typingDelay;
        [self performSelector:@selector(typingDelayEnd) withObject:nil afterDelay:typingDelay];
    }

    [UIView performWithoutAnimation:^{
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.conversation.currentReadIndex-1] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.conversation.currentReadIndex] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }];

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.conversation.currentReadIndex] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    self.nextButton.enabled = NO;
    self.nextButton.alpha = 0.5f;

    if(nextMessage.typingDelay == 0) {
        [UIView animateWithDuration:0.25f animations:^{
            self.nextButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            self.nextButton.enabled = YES;
        }];
    }
}

-(void)typingDelayEnd {
    typingDelay = 0.0f;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.conversation.currentReadIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.conversation.currentReadIndex] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    if(!self.nextButton.enabled) {
        [UIView animateWithDuration:0.25f animations:^{
            self.nextButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            self.nextButton.enabled = YES;
        }];
    }
}

- (void)showConversationEnd:(BOOL)animate {
    self.nextButton.hidden = YES;
    self.tableFooterView.hidden = NO;
    
    self.footer_readNextLabel.alpha = 1.0f;
    self.footerView.top = self.bodyView.height;
    self.footerView.height = 239.0f;
    self.footerView.hidden = NO;
    
    if(self.conversation.nextDict) {
        [self configureNextConversationWithDict:self.conversation.nextDict];
        
        if(animate) {
            animationInProgress = YES;
            [UIView animateWithDuration:0.25f animations:^{
                self.tableView.height = self.bodyView.height - self.footerView.height;
                self.footerView.bottom = self.bodyView.height;
                
                CGPoint newContentOffset = CGPointMake(0, [self.tableView contentSize].height -  self.tableView.bounds.size.height);
                [self.tableView setContentOffset:newContentOffset animated:NO];
            } completion:^(BOOL finished) {
                animationInProgress = NO;
            }];
        } else {
            self.tableView.height = self.bodyView.height - self.footerView.height;
            self.footerView.bottom = self.bodyView.height;
            
            CGPoint newContentOffset = CGPointMake(0, [self.tableView contentSize].height -  self.tableView.bounds.size.height);
            [self.tableView setContentOffset:newContentOffset animated:NO];
        }
    } else {
        self.tableView.height = self.bodyView.height;
        
        CGPoint newContentOffset = CGPointMake(0, [self.tableView contentSize].height -  self.tableView.bounds.size.height);
        [self.tableView setContentOffset:newContentOffset animated:NO];
    }
}

- (void)showStoryCover {
    if(animationInProgress) return;
    
    animationInProgress = YES;
    [UIView animateWithDuration:0.25f animations:^{
        self.headerView.top = 0;
        self.bodyView.top = self.view.height;
        [self.delegate setGradientViewColor:[UIColor colorWithWhite:(self.view.width/3)/self.view.width alpha:1.0f]];
    } completion:^(BOOL finished) {
        animationInProgress = NO;
    }];

}

- (void)scheduleReminderNotifications {
    [appDelegate cancelLocalNotificationsWithId:@"storyReminder1"];
    NSString *storyReminderText1 = [NSString stringWithFormat:@"You won't believe what's going to happen next in %@!", self.conversation.title];
    [appDelegate scheduleLocalNotificationWithMessage:storyReminderText1 afterTimeInterval:86400 notifierId:@"storyReminder1" userInfo:nil];
    
    [appDelegate cancelLocalNotificationsWithId:@"storyReminder2"];
    NSString *storyReminderText2 = [NSString stringWithFormat:@"You're just a few messages away from the big reveal in %@!", self.conversation.title];
    [appDelegate scheduleLocalNotificationWithMessage:storyReminderText2 afterTimeInterval:172800 notifierId:@"storyReminder2" userInfo:nil];
    
    [appDelegate cancelLocalNotificationsWithId:@"storyReminder5"];
    NSString *storyReminderText5 = [NSString stringWithFormat:@"She said what?! Find out by continuing in %@", self.conversation.title];
    [appDelegate scheduleLocalNotificationWithMessage:storyReminderText5 afterTimeInterval:432000 notifierId:@"storyReminder5" userInfo:nil];
}

- (IBAction)startStoryButtonAction:(id)sender {
    if(animationInProgress) return;
    
    [self scheduleReminderNotifications];
    
    animationInProgress = YES;
    [UIView animateWithDuration:0.25f animations:^{
        self.headerView.bottom = -1;
        self.bodyView.top = 0;
        [self.delegate setGradientViewColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
    } completion:^(BOOL finished) {
        animationInProgress = NO;
    }];
}

- (IBAction)startNextStoryButtonAction:(id)sender {
    if(animationInProgress) return;
    
    animationInProgress = YES;
    [UIView animateWithDuration:0.25f animations:^{
        self.tableView.bottom = 0;
        self.footerView.top = 0;
        self.footer_titleLabel.top -= 20;
        self.footer_authorLabel.top -= 20;
        self.footer_seriesLabel.top -= 20;
        self.footerView.height = self.bodyView.height;
        self.footer_readNextLabel.alpha = 0.0f;
        [self.delegate setGradientViewColor:[UIColor colorWithWhite:(self.view.width/3)/self.view.width alpha:1.0f]];
    } completion:^(BOOL finished) {
        self.startStoryButton.enabled = NO;
        
        [self configureWithTitle:self.conversation.nextDict[@"title"] withCoverImageURL:self.conversation.nextDict[@"image_url"] withAuthorName:self.conversation.nextDict[@"name"] withSeriesCurrent:0 withSeriesTotal:0 withFirstMessageText:@"Loading..."];
        
        [ResourceManager findPathForConversationID:self.conversation.nextDict[@"id"] complete:^(NSString *path) {
            animationInProgress = NO;

            NSData *data = [NSData dataWithContentsOfFile:path];
            NSDictionary *dict = [PPJSONSerialization JSONObjectWithData:data options:0 error:nil];
            Conversation *nextConversation = [Conversation deserialize:dict];
            
            self.conversation = nextConversation;
            self.headerView.top = 0;
            self.bodyView.top = self.view.height;
            self.tableView.top = 0;
            self.tableView.height = self.bodyView.height - 74;
            self.footerView.height = 200.0f;
            self.footer_readNextLabel.alpha = 1.0f;
        }];
    }];
}

- (void)setConversation:(Conversation *)conversation {
    _conversation = conversation;
    
    self.startStoryButton.enabled = YES;

    self.tableView.height = self.bodyView.height - 74;
    self.nextButton.hidden = NO;
    self.footerView.hidden = YES;
    [self configureWithConversation:conversation];
}

-(void)configureNextConversationWithDict:(NSDictionary*)dict {
    [self.footer_coverImageView loadImageForURL:dict[@"image_url"]];
    
    self.footer_titleLabel.text = dict[@"title"];
    NSString *authorName = @"Anonymous";
    if(dict[@"author"] && dict[@"author"][@"name"]) {
        authorName = dict[@"author"][@"name"];
    }
    self.footer_authorLabel.text = [NSString stringWithFormat:@"Written by %@", authorName];
    
    NSArray *series = dict[@"series"];
    if(series && series.count == 2) {
        self.footer_seriesLabel.text = [NSString stringWithFormat:@"Chapter %d of %d available", [series[0] intValue], [series[1] intValue]];
    } else {
        self.footer_seriesLabel.text = nil;
    }

    CGRect authorBounds = [self.footer_authorLabel.text boundingRectWithSize:CGSizeMake(self.view.width - 50, 0)
                                                              options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                           attributes:@{NSFontAttributeName: self.footer_authorLabel.font}
                                                              context:nil];
    
    CGRect titleBounds = [self.footer_titleLabel.text boundingRectWithSize:CGSizeMake(self.view.width - 50, 0)
                                                            options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                         attributes:@{NSFontAttributeName: self.footer_titleLabel.font}
                                                            context:nil];
    
    self.footer_authorLabel.frame = CGRectMake(0, 0, ceilf(authorBounds.size.width), ceilf(authorBounds.size.height));
    self.footer_titleLabel.frame = CGRectMake(0, 0, ceilf(titleBounds.size.width), ceilf(titleBounds.size.height));
    [self.footer_seriesLabel sizeToFit];
    
    self.footer_authorLabel.left = 26;
    self.footer_titleLabel.left = 26;
    self.footer_seriesLabel.left = 26;
    
    self.footer_seriesLabel.top = self.footer_startStoryButton.top - 95 + 40;
    
    if(self.footer_seriesLabel.text) {
        self.footer_authorLabel.bottom = self.footer_seriesLabel.top - 15;
    } else {
        self.footer_authorLabel.bottom = self.footer_startStoryButton.top - 125 + 40;
    }
    
    self.footer_titleLabel.bottom = self.footer_authorLabel.top - 2;
    self.footer_readNextLabel.bottom = self.footer_titleLabel.top - 2;
}

-(void)configureWithConversation:(Conversation*)conversation {
    Message *firstMessage = [conversation.messages firstObject];
    Character *sender;
    NSString *firstMessageText;
    
    if(conversation.summary) {
        firstMessageText = conversation.summary;
    } else if(firstMessage.characterID) {
        sender = conversation.characters[firstMessage.characterID];
        firstMessageText = [NSString stringWithFormat:@"%@: %@", sender.name, firstMessage.text];
    } else {
        firstMessageText = [NSString stringWithFormat:@"%@", firstMessage.text];
    }
    
    int seriesCurrent = 0;
    int seriesTotal = 0;
    if(conversation.seriesMarker.count == 2) {
        seriesCurrent = [conversation.seriesMarker[0] intValue];
        seriesTotal = [conversation.seriesMarker[1] intValue];
    }

    [self configureWithTitle:conversation.title withCoverImageURL:conversation.coverImageURL withAuthorName:conversation.authorName withSeriesCurrent:seriesCurrent withSeriesTotal:seriesTotal withFirstMessageText:firstMessageText];
    
    [self.tableView reloadData];
    if(conversation.messages.count > conversation.currentReadIndex + 1) {
        self.tableFooterView.hidden = YES;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.conversation.currentReadIndex] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    } else {
        [self showConversationEnd:NO];
    }
}

-(void)configureWithTitle:(NSString*)title
        withCoverImageURL:(NSString*)url
           withAuthorName:(NSString*)authorName
        withSeriesCurrent:(int)seriesCurrent
          withSeriesTotal:(int)seriesTotal
     withFirstMessageText:(NSString*)firstMessageText {

    [self.coverImageView loadImageForURL:url];
    self.titleLabel.text = title;
    
    if(!authorName) {
        authorName = @"Anonymous";
    }
    self.authorLabel.text = [NSString stringWithFormat:@"Written by %@", authorName];
    
    
    if(seriesTotal > 0) {
        self.seriesLabel.text = [NSString stringWithFormat:@"Chapter %d of %d available", seriesCurrent, seriesTotal];
    } else {
        self.seriesLabel.text = nil;
    }
    
    self.firstMessageLabel.text = firstMessageText;
    
    CGRect authorBounds = [self.authorLabel.text boundingRectWithSize:CGSizeMake(self.view.width - 50, 0)
                                                              options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                           attributes:@{NSFontAttributeName: self.authorLabel.font}
                                                              context:nil];
    
    CGRect titleBounds = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.view.width - 50, 0)
                                                            options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                         attributes:@{NSFontAttributeName: self.titleLabel.font}
                                                            context:nil];
    
    CGRect firstMessageBounds = [self.firstMessageLabel.text boundingRectWithSize:CGSizeMake(self.view.width - 50, 0)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                                       attributes:@{NSFontAttributeName: self.firstMessageLabel.font}
                                                                          context:nil];
    
    self.authorLabel.frame = CGRectMake(0, 0, ceilf(authorBounds.size.width), ceilf(authorBounds.size.height));
    self.titleLabel.frame = CGRectMake(0, 0, ceilf(titleBounds.size.width), ceilf(titleBounds.size.height));
    self.firstMessageLabel.frame = CGRectMake(0, 0, ceilf(firstMessageBounds.size.width), ceilf(firstMessageBounds.size.height));
    [self.seriesLabel sizeToFit];
    
    self.authorLabel.left = 26;
    self.titleLabel.left = 26;
    self.seriesLabel.left = 26;
    self.firstMessageLabel.left = 26;
    
    self.firstMessageLabel.bottom = self.firstMessageLabel.superview.height - 102;
    self.seriesLabel.bottom = self.firstMessageLabel.top - 7;
    
    if(self.seriesLabel.text) {
        self.authorLabel.bottom = self.seriesLabel.top - 15;
    } else {
        self.authorLabel.bottom = self.firstMessageLabel.top - 15;
    }
    
    self.titleLabel.bottom = self.authorLabel.top - 2;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 70)];
    self.tableFooterView = self.tableView.tableFooterView;
    self.tableFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *footerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, self.tableFooterView.width - 51, 18)];
    footerTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    footerTitleLabel.textColor = [UIColor darkGrayColor];
    footerTitleLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
    footerTitleLabel.text = [NSString stringWithFormat:@"\"%@\" written by", title];
    footerTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.tableFooterView addSubview:footerTitleLabel];
    
    UILabel *footerAuthorLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, self.tableFooterView.width - 51, 21)];
    footerAuthorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    footerAuthorLabel.textColor = [UIColor blackColor];
    footerAuthorLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
    footerAuthorLabel.textAlignment = NSTextAlignmentRight;
    footerAuthorLabel.text = [NSString stringWithFormat:@"%@", authorName];
    [self.tableFooterView addSubview:footerAuthorLabel];
    
    footerTitleLabel.right = self.tableFooterView.width - 17.0f;
    footerAuthorLabel.right = self.tableFooterView.width - 17.0f;
}

#pragma mark -
- (void)showStoryWithMarker:(ConversationMarker*)marker {
    self.startStoryButton.enabled = NO;

    [self configureWithTitle:marker.title withCoverImageURL:marker.image_url withAuthorName:marker.author_name withSeriesCurrent:marker.series_current withSeriesTotal:marker.series_total withFirstMessageText:@"Loading..."];
    
    [ResourceManager findPathForConversationID:marker.conversation_id complete:^(NSString *path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dict = [PPJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.conversation = [Conversation deserialize:dict];
        
        if(self.conversation.messages.count <= marker.index + 1) {
            //story is finished -- start from beginning
            self.conversation.currentReadIndex = 0;
        } else {
            self.conversation.currentReadIndex = marker.index;
        }
        
        [self.tableView reloadData];
        
        if(self.conversation.messages.count > self.conversation.currentReadIndex + 1) {
            self.tableFooterView.hidden = YES;
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.conversation.currentReadIndex] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        } else {
            [self showConversationEnd:NO];
        }
    }];
    

    self.headerView.top = 0;
    self.bodyView.top = self.view.height;
}

- (void)showStoryWithDict:(NSDictionary*)storyDict {
    self.startStoryButton.enabled = NO;

    [[Amplitude instance] logEvent:@"Opened New Story" withEventProperties:@{@"story_id":storyDict[@"id"]}];
    
    [self configureWithTitle:storyDict[@"title"] withCoverImageURL:storyDict[@"image_url"] withAuthorName:storyDict[@"name"] withSeriesCurrent:0 withSeriesTotal:0 withFirstMessageText:@"Loading..."];
    
    [ResourceManager findPathForConversationID:storyDict[@"id"] complete:^(NSString *path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dict = [PPJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(dict) {
            self.conversation = [Conversation deserialize:dict];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong with this story." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.delegate showStore];

                [ResourceManager findPathForConversationID:DEFAULT_CONVERSATION_ID complete:^(NSString *pathString) {
                    NSData *data = [NSData dataWithContentsOfFile:pathString];
                    NSDictionary *dict = [PPJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    self.conversation = [Conversation deserialize:dict];
                }];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    

    self.headerView.top = 0;
    self.bodyView.top = self.view.height;
}

#pragma mark -
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    Message *messageObject = self.conversation.messages[section];
    
    BOOL sameSenderNext = NO;
    if(self.conversation.messages.count - 1 > section && section < self.conversation.currentReadIndex) {
        Message *nextMessage = self.conversation.messages[section + 1];
        if([nextMessage.characterID isEqualToString:messageObject.characterID]) {
            sameSenderNext = YES;
        }
    }
    
    if(sameSenderNext ||
       messageObject.batteryLow ||
       !messageObject.characterID ||
       !messageObject.text ||
       [self isTypingDelayCell:section]) {
        
        return 0.0f;
    } else {
        return 20.0f;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    Message *messageObject = self.conversation.messages[section];
    if([self tableView:tableView heightForFooterInSection:section] == 0.0f) {
        return nil;
    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 20.0f)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.width - 23.0f, 12.0f)];
    
    nameLabel.font = [UIFont systemFontOfSize:12.0f];
    nameLabel.textColor = [UIColor colorWithWhite:182/255.0f alpha:1.0f];

    Character *sender = self.conversation.characters[messageObject.characterID];
    if(sender.isLocal) {
        nameLabel.textAlignment = NSTextAlignmentRight;
        nameLabel.right = tableView.width - 23.0f;
    } else {
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.left = 23.0f;
    }
    nameLabel.text = sender.name;
    
    [footerView addSubview:nameLabel];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.conversation.currentReadIndex + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat returnedValue = 0.0f;
    
    if([self isTypingDelayCell:indexPath.section]) {
        return 35.0f;
    }

    Message *messageObject = self.conversation.messages[indexPath.section];
    if(messageObject.batteryLow || !messageObject.text) {
        return 0.0f;
    }
    
    returnedValue = [MessageCellTableViewCell heightForText:messageObject.text] + VPADDING;
    
    return returnedValue;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCellTableViewCell *rCell = nil;
    NSString* cellIdentifier = nil;
    Message *messageObject = self.conversation.messages[indexPath.section];
    
    Character *sender;
    if(messageObject.batteryLow) {
        cellIdentifier = kPPMessageThreadCellCenter;
    } else if(messageObject.characterID) {
        sender = self.conversation.characters[messageObject.characterID];
        if (!sender.isLocal) {
            cellIdentifier = kPPMessageThreadCellLeft;
        } else {
            cellIdentifier = kPPMessageThreadCellRight;
        }
    } else {
        cellIdentifier = kPPMessageThreadCellCenter;
    }

    rCell = (MessageCellTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!rCell) {
        rCell = [[MessageCellTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    if([self isTypingDelayCell:indexPath.section]) {
        [rCell configureForTypingDelay];
    } else {
        [rCell configureWithWithMessage:messageObject];
    }


    [rCell setNeedsLayout];
    return rCell;
}

-(BOOL)isTypingDelayCell:(int)section {
    return (typingDelay > 0 && section == self.conversation.currentReadIndex);
}

@end
