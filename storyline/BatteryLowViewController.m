//
//  BatteryLowViewController.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "BatteryLowViewController.h"
#import "DataManager.h"
#import "PurchasingViewController.h"
#import "RechargeButton.h"
#import "Amplitude.h"
#import "AppDelegate.h"

@interface BatteryLowViewController () <PurchasingViewControllerProtocol> {
    NSTimer *_timer;
}

- (IBAction)addChargesPressed:(id)sender;
- (IBAction)closePressed:(id)sender;

@property (nonatomic, weak) PurchasingViewController *purchasingVC;
@property (weak, nonatomic) IBOutlet UIView *addBatteryContainerView;

@property (weak, nonatomic) IBOutlet UILabel *batteryChargeAmountLabel;

@property (nonatomic, weak) IBOutlet UIView *bodyView;

@property (weak, nonatomic) IBOutlet RechargeButton *rechargeButton;
@property (nonatomic, weak) IBOutlet UILabel *timeLeftLabel;
@property (weak, nonatomic) IBOutlet UIButton *addCurrencyButton;
@property (weak, nonatomic) IBOutlet UILabel *plusSign;
@end

@implementation BatteryLowViewController


- (void)awakeFromNib {
    [super awakeFromNib];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWallet) name:kNotifyWalletChanged object:nil];
    
    [[Amplitude instance] logEvent:@"Saw Low Battery Screen"];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateWallet {
    self.batteryChargeAmountLabel.text = [GlobalFunctions getIntegerStringDelimitedByCommas:[DataManager batteryChargeAmount]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.rechargeButton.backgroundColor = [UIColor str_purplyColor];
    [self.rechargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    self.addBatteryContainerView.backgroundColor = [UIColor str_purplyColor];
    self.addBatteryContainerView.layer.cornerRadius = self.addBatteryContainerView.height/2;
    self.addBatteryContainerView.clipsToBounds = YES;
        
    self.batteryChargeAmountLabel.text = [GlobalFunctions getIntegerStringDelimitedByCommas:[DataManager batteryChargeAmount]];
    
    if(![DataManager lowBatteryStartDate]) {
        [DataManager setLowBatteryStartDate:[NSDate date]];
    }
    
    
    if([DataManager batteryChargeAmount] > 0) {
        self.addBatteryContainerView.hidden = NO;
        [self.rechargeButton configureWithCost:1];
    } else {
        self.addBatteryContainerView.hidden = YES;
        [self.rechargeButton configureWithCost:0];
    }
    
    [self updateTimeLeft];
    // Do any additional setup after loading the view.
    
    self.bodyView.center = CGPointMake(self.view.width/2, self.view.height/2);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTimer];
}

- (IBAction)rechargeButtonPressed:(id)sender {
    if([DataManager batteryChargeAmount] > 0) {
        [DataManager setBatteryChargeAmount:[DataManager batteryChargeAmount] - 1];
        [DataManager setLowBatteryStartDate:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate batteryRecharged];
        }];
    } else {
        [self showPurchasingVC];
    }
}

-(void)startTimer {
    [self stopTimer];
    _timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)updateTimeLeft {
    NSTimeInterval secondsLeft = [DataManager rechargeTime] + [[DataManager lowBatteryStartDate] timeIntervalSinceNow];
    self.timeLeftLabel.text = [GlobalFunctions timeLeftStringFromSecondsLeft:secondsLeft];
    if(secondsLeft <= 0) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate batteryRecharged];
        }];
    }
}

- (IBAction)addChargesPressed:(UIButton*)sender {
    if(self.purchasingVC) {
        [self showBodyView];
    } else {
        [self showPurchasingVC];
    }
}

- (void)showPurchasingVC {
    self.rechargeButton.hidden = YES;
    self.plusSign.hidden = YES;
    
    if(self.purchasingVC) {
        [self.purchasingVC.view removeFromSuperview];
        [self.purchasingVC removeFromParentViewController];
        self.purchasingVC = nil;
    }
    
    PurchasingViewController *purchasing =
    [[UIStoryboard storyboardWithName:@"Main"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"purchasing"];
    self.purchasingVC = purchasing;
    purchasing.delegate = self;
    [self addChildViewController:purchasing];
    purchasing.view.frame = self.bodyView.frame;
    self.bodyView.hidden = YES;
    [self.view addSubview:purchasing.view];
}

- (void)showBodyView {
    if(self.purchasingVC) {
        [self.purchasingVC.view removeFromSuperview];
        [self.purchasingVC removeFromParentViewController];
        self.purchasingVC = nil;
    }
    self.bodyView.hidden = NO;
    self.rechargeButton.hidden = NO;
    self.plusSign.hidden = NO;
}

- (void)purchaseComplete {
    [DataManager setLowBatteryStartDate:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate batteryRecharged];
    }];
}

- (IBAction)closePressed:(id)sender {
    __weak UIViewController *parentVC = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        if(![GVUserDefaults standardUserDefaults].pushPermissionGranted &&
           (![GVUserDefaults standardUserDefaults].pushPermissionAsked || [GVUserDefaults standardUserDefaults].pushPermissionAsked.timeIntervalSinceNow < -86400*4)) {
            [GVUserDefaults standardUserDefaults].pushPermissionAsked = [NSDate date];
            
            UIAlertController *pushPermission = [UIAlertController alertControllerWithTitle:@"Battery Recharge" message:@"Would you like to be notified when your Storyline battery's been recharged?" preferredStyle:UIAlertControllerStyleAlert];
            [pushPermission addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [pushPermission addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [GVUserDefaults standardUserDefaults].pushPermissionGranted = [NSDate date];
                [appDelegate registerForPushNotifications];
            }]];
            
            [parentVC presentViewController:pushPermission animated:YES completion:nil];
        }
    }];
}

@end
