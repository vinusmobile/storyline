//
//  MainScrollViewController.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "MainScrollViewController.h"
#import "DirectoryViewController.h"
#import "ChatThreadViewController.h"
#import "ProfileViewController.h"
#import "DataManager.h"
#import "ConversationMarker+CoreDataClass.h"
#import "StoryProtocol.h"
#import "ResourceManager.h"

@interface MainScrollViewController () <UIScrollViewDelegate, StoryProtocol> {
    BOOL layoutFinished;
    int currentPage;
}

@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UIButton *storiesButton;
@property (weak, nonatomic) IBOutlet UIButton *threadButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (nonatomic, weak) DirectoryViewController *directoryVC;
@property (nonatomic, weak) ChatThreadViewController *chatThreadVC;
@property (nonatomic, weak) ProfileViewController *profileVC;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation MainScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *conversationID = DEFAULT_CONVERSATION_ID;

    ConversationMarker *marker = [ConversationMarker MR_findFirstOrderedByAttribute:@"last_opened" ascending:NO];
    
    int currentReadIndex = 0;
    if(marker) {
        conversationID = marker.conversation_id;
        currentReadIndex = marker.index;
    }
    


    
    DirectoryViewController *directory =
    [[UIStoryboard storyboardWithName:@"Main"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"directory"];
    directory.delegate = self;
    
    
    ChatThreadViewController *thread =
    [[UIStoryboard storyboardWithName:@"Main"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"thread"];
    thread.delegate = self;
    
    ProfileViewController *profile =
    [[UIStoryboard storyboardWithName:@"Main"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"profile"];    
    profile.delegate = self;
    
    [self addChildViewController:directory];
    [self addChildViewController:profile];
    [self addChildViewController:thread];
    
    self.directoryVC = directory;
    self.chatThreadVC = thread;
    self.profileVC = profile;
    
    [self.scrollView addSubview:directory.view];
    [self.scrollView addSubview:thread.view];
    [self.scrollView addSubview:profile.view];
    
    [ResourceManager findPathForConversationID:conversationID complete:^(NSString *pathString) {
        NSData *data = [NSData dataWithContentsOfFile:pathString];
        NSDictionary *dict = [PPJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(dict) {
            Conversation *currentConvo = [Conversation deserialize:dict];
            currentConvo.currentReadIndex = currentReadIndex;
        
            thread.conversation = currentConvo;
        } else {
            [ResourceManager findPathForConversationID:DEFAULT_CONVERSATION_ID complete:^(NSString *pathString) {
                NSData *data = [NSData dataWithContentsOfFile:pathString];
                NSDictionary *dict = [PPJSONSerialization JSONObjectWithData:data options:0 error:nil];
                Conversation *currentConvo = [Conversation deserialize:dict];
                currentConvo.currentReadIndex = currentReadIndex;
                
                thread.conversation = currentConvo;
            }];
        }
    }];
    
    layoutFinished = NO;
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.directoryVC.view.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.chatThreadVC.view.frame = CGRectMake(self.directoryVC.view.right, 0, self.view.width, self.view.height);
    self.profileVC.view.frame = CGRectMake(self.chatThreadVC.view.right, 0, self.view.width, self.view.height);
    
    self.scrollView.contentSize = CGSizeMake(self.profileVC.view.frame.origin.x + self.profileVC.view.frame.size.width, 1);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0f alpha:0.6f].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(1.0f, 0.0f);
    gradientLayer.endPoint = CGPointMake(1.0f, 1.0f);
    self.gradientView.layer.mask = gradientLayer;

    if(!layoutFinished) {
        layoutFinished = YES;
        self.scrollView.contentOffset = CGPointMake(self.directoryVC.view.right, 0);
        [self setGradientViewColor:[UIColor colorWithWhite:1.0 alpha:1.0f]];
    }
}

-(void)setGradientViewColor:(UIColor*)color {
    self.gradientView.backgroundColor = color;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)scrollToPage:(int)page {
    [self.scrollView scrollRectToVisible:CGRectMake(page * self.view.width, 0, self.view.width, 1) animated:YES];
}


#pragma mark -
-(void)openStoryWithDict:(NSDictionary *)dict {
    [self.chatThreadVC showStoryWithDict:dict];
    [self scrollToPage:1];
}

-(void)openStoryWithMarker:(ConversationMarker *)marker {
    [self.chatThreadVC showStoryWithMarker:marker];
    [self scrollToPage:1];
}

-(void)showStore {
    [self scrollToPage:0];
}

#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float offsetX = scrollView.contentOffset.x;
    
    if(offsetX == 0) {
        currentPage = 0;
        
        [self.directoryVC directoryDidAppear];
        
        self.storiesButton.selected = YES;
        self.threadButton.selected = NO;
        self.profileButton.selected = NO;
    } else if(offsetX == scrollView.width) {
        currentPage = 1;
        self.storiesButton.selected = NO;
        self.threadButton.selected = YES;
        self.profileButton.selected = NO;
    } else if(offsetX == scrollView.width * 2){
        currentPage = 2;
        self.storiesButton.selected = NO;
        self.threadButton.selected = NO;
        self.profileButton.selected = YES;
    }
    
    
    if([self.chatThreadVC showingCover]) {
        if(offsetX < scrollView.width) {
            float colorScale = (0 + scrollView.width/3) / (scrollView.width);
            [self setGradientViewColor:[UIColor colorWithWhite:colorScale alpha:1.0f]];
        } else if(offsetX < (scrollView.width * 2)) {
            float colorScale = ((offsetX - scrollView.width) + scrollView.width/3) / (scrollView.width);
            [self setGradientViewColor:[UIColor colorWithWhite:colorScale alpha:1.0f]];
        } else {
            [self setGradientViewColor:[UIColor colorWithWhite:1.0 alpha:1.0f]];
        }
    } else {
        if(offsetX < scrollView.width) {
            float colorScale = (offsetX + scrollView.width/3) / (scrollView.width);
            [self setGradientViewColor:[UIColor colorWithWhite:colorScale alpha:1.0f]];
        } else {
            [self setGradientViewColor:[UIColor colorWithWhite:1.0 alpha:1.0f]];
        }
    }
}


#pragma mark -
- (IBAction)storiesButtonPressed:(id)sender {
    [self scrollToPage:0];
}

- (IBAction)threadButtonPressed:(id)sender {
    
    if(currentPage == 1) {
        [self.chatThreadVC showStoryCover];
    } else {
        [self scrollToPage:1];
    }
}

- (IBAction)profileButtonPressed:(id)sender {
    [self scrollToPage:2];
}

@end
