//
//  PZLoadingViewController.m
//  Pocketz
//
//  Created by Jimmy Xu on 5/20/16.
//  Copyright © 2016 Pocketz World. All rights reserved.
//

#import "PZLoadingViewController.h"
#import "PZLoaderView.h"

static PZLoadingViewController *currentVC;

@interface PZLoadingViewController () {
}

@end

@interface PZActivityView : UIView

@property (nonatomic, weak) UIView *boundingBoxView;
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic, weak) PZLoaderView *loaderView;

@end

@implementation PZLoadingViewController

-(id)initWithMessage:(NSString*)message {
    self = [super initWithNibName:nil bundle:nil];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    PZActivityView *view = [[PZActivityView alloc] init];
    view.messageLabel.text = message;
    self.view = view;
    return self;
}

-(void)updateDownloadPercentage:(NSNotification*)notif {
    int percent = [notif.userInfo[@"percentage"] intValue];
    NSString *prefix = notif.userInfo[@"prefix"];
    ((PZActivityView*)self.view).messageLabel.text = [NSString stringWithFormat:@"%@ %d%%", prefix, percent];
    [((PZActivityView*)self.view) setNeedsLayout];
    
    if([notif.userInfo[@"shouldDismiss"] boolValue] && !self.disableAutoDismiss) {
        self.dismissing = YES;
        [self dismissViewControllerAnimated:NO completion:^{
            self.dismissing = NO;
            currentVC = nil;
        }];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    currentVC = self;
    [[((PZActivityView*)self.view) loaderView] animate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    currentVC = nil;
}


+(PZLoadingViewController*)currentVC {
    return currentVC;
}

+(void)show:(NSString*)message presentingController:(UIViewController*)controller animated:(BOOL)animated withCompletion:(void (^ __nullable)(void))completion {
    if(currentVC) {
        if(completion) completion();
        return;
    };
    
    PZLoadingViewController *loadingVC = [[PZLoadingViewController alloc] initWithMessage:message];
    [controller presentViewController:loadingVC animated:animated completion:completion];
}

+(void)dismiss:(BOOL)animated withCompletion:(void (^ __nullable)(void))completion {
    if(!currentVC || currentVC.dismissing) {
        if(completion) completion();
    };
    
    [currentVC dismissViewControllerAnimated:animated completion:^{
        if(completion) completion();
    }];
}

+(void) updateMessage:(NSString*)message {
    if(!currentVC) return;
    
    ((PZActivityView*)currentVC.view).messageLabel.text = message;
    [((PZActivityView*)currentVC.view) setNeedsLayout];
}

@end


@implementation PZActivityView

-(id)init {
    self = [super initWithFrame:CGRectZero];
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    UIView *boundingBoxView = [[UIView alloc] initWithFrame:CGRectZero];
    
    boundingBoxView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    boundingBoxView.layer.cornerRadius = 12.0;
    _boundingBoxView = boundingBoxView;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    messageLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.shadowColor = [UIColor blackColor];
    messageLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    messageLabel.numberOfLines = 0;
    _messageLabel = messageLabel;

    PZLoaderView *loader = [[PZLoaderView alloc] initWithTintColor:[UIColor whiteColor]];
    _loaderView = loader;
    
    [self addSubview:boundingBoxView];
    [self addSubview:loader];
    [self addSubview:messageLabel];

    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    _boundingBoxView.width = 160;
    _boundingBoxView.height = 160;
    _boundingBoxView.left = ceil((self.width / 2.0) - (_boundingBoxView.width / 2.0));
    _boundingBoxView.top = ceil((self.height / 2.0) - (_boundingBoxView.height / 2.0));
    
    _loaderView.left = ceil((self.width / 2.0) - (_loaderView.width / 2.0));
    _loaderView.top = ceil((self.height / 2.0) - (_loaderView.height / 2.0));
    
    CGSize messageLabelSize = [_messageLabel sizeThatFits:CGSizeMake(160-20*2.0, CGFLOAT_MAX)];
    
    _messageLabel.width = messageLabelSize.width;
    _messageLabel.height = messageLabelSize.height;
    _messageLabel.left = ceil((self.width / 2.0) - (_messageLabel.width / 2.0));
    _messageLabel.top = ceil(_loaderView.frame.origin.y + _loaderView.frame.size.height + ((_boundingBoxView.height - _loaderView.height) / 4.0) - (_messageLabel.height / 2.0));
}

@end
