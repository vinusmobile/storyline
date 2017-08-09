//
//  DirectoryViewController.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "DirectoryViewController.h"
#import "StoryCollectionViewCell.h"
#import "MosaicLayout.h"
#import "MosaicLayoutDelegate.h"
#import "ConversationMarker+CoreDataClass.h"
#import "ResourceManager.h"
#import "DataManager.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "FilterViewController.h"

@interface DirectoryViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MosaicLayoutDelegate> {
    BOOL downloading;
}


@property (nonatomic, strong) NSArray<NSDictionary*> *stories;
@property (nonatomic, strong) NSDate *refreshDate;

@property (nonatomic, weak) IBOutlet UIButton *filterButton;
@property (nonatomic, weak) IBOutlet UIView *filterView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

-(IBAction)filterPressed:(id)sender;

@end

@implementation DirectoryViewController


-(void)awakeFromNib {
    [super awakeFromNib];
    [self performSelectorInBackground:@selector(loadStoreData) withObject:nil];
}

-(IBAction)filterPressed:(id)sender {
    if([DataManager sharedInstance].directoryStories) {
        FilterViewController *filter =
        [[UIStoryboard storyboardWithName:@"Main"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"filter"];
        filter.directoryVC = self;
        [self presentViewController:filter animated:YES completion:nil];
    }
}

-(void)loadStoreData {
    downloading = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", S3CDNPath, S3BucketName, @"store_response.json"];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];

    if (data == nil) {
        NSLog(@"Could not load data from url: %@", urlString);
        return;
    } else {
        NSArray *array = [PPJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [DataManager sharedInstance].directoryStories = [array copy];
        NSMutableArray<NSDictionary*> *sublist = [NSMutableArray arrayWithCapacity:array.count];
        for(NSDictionary *storyDict in array) {
            if([storyDict[@"featured"] boolValue]) {
                [sublist addObject:storyDict];
            }
        }
        
        downloading = NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self configureWithTag:@"FEATURED" withStories:sublist];
            self.refreshDate = [NSDate date];
        }];
    }
    
    [self.collectionView.pullToRefreshView stopAnimating];
}

-(void)configureWithTag:(NSString*)tag withStories:(NSArray<NSDictionary*>*)stories {
    self.stories = stories;
    [self.filterButton setTitle:tag forState:UIControlStateNormal];
    
    CGRect bounds = [tag boundingRectWithSize:CGSizeMake(self.view.width - 120, self.filterButton.height)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                                  attributes:@{NSFontAttributeName: self.filterButton.titleLabel.font}
                                                                     context:nil];
    
    self.filterView.backgroundColor = [UIColor str_purplyColor];
    [self.filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.filterButton setFrame:CGRectMake(10, 0, bounds.size.width + 20.0f, self.filterButton.height)];
    self.filterView.width = self.filterButton.width + 13;
}

-(void)setStories:(NSArray<NSDictionary *> *)stories {
    _stories = stories;
    [self.collectionView reloadData];
}

-(void)directoryDidAppear {
    if(downloading) return;
    
    if(!self.stories || self.refreshDate.timeIntervalSinceNow < -600) {
        //refresh stories list if none exist or it's been more than 10 minutes
        
        [self performSelectorInBackground:@selector(loadStoreData) withObject:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filterView.layer.cornerRadius = 10.0f;
    self.filterView.clipsToBounds = YES;
    self.filterView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.filterView.layer.borderWidth = 3.0f;
    
    self.filterView.backgroundColor = [UIColor whiteColor];
    [self.filterButton setTitleColor:[UIColor str_purplyColor] forState:UIControlStateNormal];

    
    self.view.backgroundColor = [UIColor str_black88Color];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    ((MosaicLayout*)(self.collectionView.collectionViewLayout)).delegate = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    [self.collectionView addPullToRefresh:[SVArrowPullToRefreshView class] withActionHandler:^{
        [self loadStoreData];
    }];
}



-(float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath {
    //  Base relative height for simple layout type. This is 1.0 (height equals to width)

    BOOL isDoubleColumn = [self collectionView:collectionView isDoubleColumnAtIndexPath:indexPath];
    if (isDoubleColumn){
        return 0.5;
    }
    
    switch (indexPath.item%10) {
        case 0:
        case 1:
            return 1.5f;
            break;
        case 3:
        case 4:
            return 1.0f;
        case 2:
            return 2.0f;
        case 5:
        case 6:
            return 1.25;
        case 7:
        case 8:
            return 1.0;
        case 9:
            return 2.0f;
        default:
            return 2.0f;
            break;
    }
    
    
    
    
    if(indexPath.item < 2) {
        return 1.5f;
    }
    
    int randomHeight = arc4random() % 4;
    switch (randomHeight) {
        case 0:
            return 2.0f;
            break;
        case 1:
            return 1.0f;
            break;
        case 2:
            return 2.0f;
            break;
        case 3:
            return 1.0f;
            break;
        case 4:
            return 2.0f;
            break;
        default:
            return 1.0f;
            break;
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
//    if(indexPath.item == 4) {
//        return YES;
//    }
//    if(indexPath.item > 5) {
//        return (rand()%10 == 0);
//    } else {
//        return NO;
//    }
    
}

-(NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

#pragma mark -
//
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake((collectionView.width - 1)/2, (collectionView.width - 1)/2 * 1.5);
//}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stories.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dict = self.stories[indexPath.item];
    [cell configureWithDict:dict];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.stories[indexPath.item];
    
    if(dict[@"id"]) {
        ConversationMarker *marker = [ConversationMarker MR_findFirstByAttribute:@"conversation_id" withValue:dict[@"id"]];
        if(marker) {
            [self.delegate openStoryWithMarker:marker];
        } else {
            [self.delegate openStoryWithDict:dict];
        }
    } else {
        //Error: missing ID
    }
}


@end
