//
//  PurchasingViewController.m
//  storyline
//
//  Created by Jimmy Xu on 11/8/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "PurchasingViewController.h"
#import "DataManager.h"
#import "PurchasingTableViewCell.h"
#import "PZLoadingViewController.h"
#import "RMStore.h"
#import "Amplitude.h"
#import "AMPRevenue.h"
#import "RMAppReceipt.h"

@interface PurchasingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation PurchasingViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"PurchasingCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PurchasingTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 40)];
    footer.backgroundColor = [UIColor clearColor];
    UIButton *restoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    restoreBtn.frame = CGRectMake(0, 0, self.tableView.width, 40.0f);
    restoreBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [footer addSubview:restoreBtn];
    [restoreBtn setTitle:@"I'm already in Storyline Club" forState:UIControlStateNormal];
    [restoreBtn addTarget:self action:@selector(restorePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = footer;
}

-(void)restorePressed:(id)sender {
    [PZLoadingViewController show:@"Restoring Purchases..." presentingController:self animated:YES withCompletion:^{
        [[RMStore defaultStore] refreshReceiptOnSuccess:^{
            [PZLoadingViewController dismiss:YES withCompletion:^{
                if ([DataManager isSubscriptionActive]) {
                    //enable
                    NSLog(@"Purchases Restored");
                    [self.delegate purchaseComplete];
                }else{
                    //no longer active
                    NSLog(@"Not Active");
                    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Not Subscribed" message:@"We couldn't find a current subscription for Storyline." preferredStyle:UIAlertControllerStyleAlert];
                    [errorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:errorAlert animated:YES completion:nil];
                }
            }];
        } failure:^(NSError *error) {
            NSLog(@"Restore Failed: %@", error.localizedDescription);
            [PZLoadingViewController dismiss:YES withCompletion:^{
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [errorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:errorAlert animated:YES completion:nil];
            }];
        }];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PurchasingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *iapDict = [[DataManager getIAPArray] objectAtIndex:indexPath.section];
    cell.iconImageView.image = [UIImage imageNamed:iapDict[@"image"]];

    SKProduct *product = [[RMStore defaultStore] productForIdentifier:iapDict[@"iap_id"]];
    NSString *priceString = nil;
    if(product) {
        priceString = [RMStore localizedPriceOfProduct:product];
    } else {
        priceString = @"Unavailable";
    }
    
    switch (indexPath.section) {
        case 0:
            cell.titleLabel.text = @"Free Trial";
            cell.subtitleLabel.text = [NSString stringWithFormat:@"then %@/month", priceString];
            break;
        case 1:
            cell.titleLabel.text = [NSString stringWithFormat:@"1 week for %@", priceString];
            break;
        case 2:
            cell.titleLabel.text = [NSString stringWithFormat:@"1 year for %@", priceString];
            break;
        default:
            break;
    }
    
    [cell setNeedsLayout];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *iapDict = [[DataManager getIAPArray] objectAtIndex:indexPath.section];
    
    [PZLoadingViewController show:@"Confirming Purchase" presentingController:self animated:YES withCompletion:^{
        NSString *productID = iapDict[@"iap_id"];

        [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
            [[RMStore defaultStore].receiptVerificator verifyTransaction:transaction success:^{
                AMPRevenue *revenue = [[[AMPRevenue revenue] setProductIdentifier:productID] setQuantity:1];
                
                SKProduct *product = [[RMStore defaultStore] productForIdentifier:iapDict[@"iap_id"]];
                if(product) {
                    [revenue setPrice:[NSNumber numberWithDouble:product.price.doubleValue]];
                    
                    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
                    if(receipt) {
                        [revenue setReceipt:receipt];
                        [[Amplitude instance] logRevenueV2:revenue];
                    }
                }
                
                [PZLoadingViewController dismiss:YES withCompletion:^{
                    int newWallet = [DataManager batteryChargeAmount] + [iapDict[@"amount"] intValue];
                    [DataManager setBatteryChargeAmount:newWallet];
                    
                    [self.delegate purchaseComplete];
                }];
            } failure:^(NSError *error) {
                NSLog(@"IAP Failed: %@", error.localizedDescription);
                [PZLoadingViewController dismiss:YES withCompletion:^{
                    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                    [errorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:errorAlert animated:YES completion:nil];
                }];
            }];
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            NSLog(@"IAP Failed: %d, %@", error.code, error.localizedDescription);
            [PZLoadingViewController dismiss:YES withCompletion:^{
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [errorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:errorAlert animated:YES completion:nil];
            }];
        }];
    }];

}

//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake((collectionView.width - 1.0f)/2.0f, 150.0f);
//}
//
//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}
//
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return [DataManager getIAPArray].count;
//}
//
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    PurchasingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    
//    NSDictionary *iapDict = [[DataManager getIAPArray] objectAtIndex:indexPath.row];
//    cell.cellImageView.image = [UIImage imageNamed:iapDict[@"image"]];
//    cell.numChargesLabel.text = [NSString stringWithFormat:@"%@ charges",[GlobalFunctions getIntegerStringDelimitedByCommas:[iapDict[@"amount"] intValue]]];
//    SKProduct *product = [[RMStore defaultStore] productForIdentifier:iapDict[@"iap_id"]];
//    if(product) {
//        cell.priceLabel.text = [RMStore localizedPriceOfProduct:product];
//    } else {
//        cell.priceLabel.text = @"Unavailable";
//    }
//    return cell;
//}
//
//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *iapDict = [[DataManager getIAPArray] objectAtIndex:indexPath.row];
//
//    [PZLoadingViewController show:@"Confirming Purchase" presentingController:self animated:YES withCompletion:^{
//#ifndef DEBUG
//        NSString *productID = iapDict[@"iap_id"];
//
//        [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
//            AMPRevenue *revenue = [[[AMPRevenue revenue] setProductIdentifier:productID] setQuantity:1];
//            
//            SKProduct *product = [[RMStore defaultStore] productForIdentifier:iapDict[@"iap_id"]];
//            if(product) {
//                [revenue setPrice:[NSNumber numberWithDouble:product.price.doubleValue]];
//                
//                NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
//                NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
//                if(receipt) {
//                    [revenue setReceipt:receipt];
//                    [[Amplitude instance] logRevenueV2:revenue];
//                } else {
//                    //no receipt...unverified
//                }
//            }
//#endif
//
//            [PZLoadingViewController dismiss:YES withCompletion:^{
//                int newWallet = [DataManager batteryChargeAmount] + [iapDict[@"amount"] intValue];
//                [DataManager setBatteryChargeAmount:newWallet];
//                
//                [self.delegate purchaseComplete];
//            }];
//#ifndef DEBUG
//        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
//            NSLog(@"IAP Failed: %@", error.localizedDescription);
//            [PZLoadingViewController dismiss:YES withCompletion:^{
//                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
//                [errorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
//                [self presentViewController:errorAlert animated:YES completion:nil];
//            }];
//        }];
//#endif
//    }];
//}

@end
