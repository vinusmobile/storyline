//
//  RowCollectionTableViewCell.m
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "RowCollectionTableViewCell.h"
#import "StoryCollectionViewCell.h"

@interface RowCollectionTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource> {
    
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation RowCollectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setContentArray:(NSArray *)contentArray {
    _contentArray = contentArray;
    [self.collectionView reloadData];
}

#pragma mark -
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contentArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell configureWithMarker:self.contentArray[indexPath.item]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate openStoryWithMarker:self.contentArray[indexPath.item]];
    
//    self.delegate openStoryWithDict:<#(NSDictionary *)#>
}
@end
