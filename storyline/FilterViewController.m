//
//  FilterViewController.m
//  storyline
//
//  Created by Jimmy Xu on 12/5/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "FilterViewController.h"
#import "FilterTagCell.h"
#import "StoryCell.h"
#import "DataManager.h"

@interface FilterViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) BOOL searching;

@property (nonatomic, strong) NSArray<NSDictionary*> *allStories;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

-(IBAction)backButtonPressed:(id)sender;

@end

@implementation FilterViewController

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.allStories = [DataManager sharedInstance].directoryStories;
    NSMutableArray *availableTags = [NSMutableArray array];
    
    [availableTags addObject:@"featured"];
    
    for(NSDictionary *dict in self.allStories) {
        NSArray *tags = dict[@"tags"];
        for(NSString *tag in tags) {
            if(![availableTags containsObject:tag]) {
                [availableTags addObject:tag];
            }
        }
    }
    
    self.tags = availableTags;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterTagCell" bundle:nil] forCellReuseIdentifier:@"tag_cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"StoryCell" bundle:nil] forCellReuseIdentifier:@"story_cell"];

    UIImage *closeImage = [[UIImage imageNamed:@"closeWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.backButton setImage:closeImage forState:UIControlStateNormal];

    self.backButton.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setSearching:(BOOL)searching {
    _searching = searching;
    [self.tableView reloadData];
}

#pragma mark -
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.searching = YES;
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    self.searching = NO;
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray<NSDictionary*> *sublist = [NSMutableArray arrayWithCapacity:self.allStories.count];
    
    NSString *lowercaseKeyword = searchBar.text.lowercaseString;
    
    for(NSDictionary *storyDict in self.allStories) {
        NSString *title = [storyDict[@"title"] lowercaseString];
        if([title containsString:lowercaseKeyword]) {
            [sublist addObject:storyDict];
            continue;
        }
        NSDictionary *authorDict = storyDict[@"author"];
        if(authorDict) {
            NSString *authorName = [authorDict[@"name"] lowercaseString];
            if([authorName.lowercaseString containsString:lowercaseKeyword]) {
                [sublist addObject:storyDict];
                continue;
            }
        }
    }
    self.searchResults = sublist;
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark -
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 25.0f)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14.0f, 8.0f, tableView.width-14.0f, 15.0f)];
    label.font = [UIFont systemFontOfSize:12.0f];
    [header addSubview:label];
    
    if(self.searching) {
        label.text = @"Results";
    } else {
        label.text = @"Tags";
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.searching) {
        return 70.0f;
    } else {
        return 44.0f;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searching) {
        return self.searchResults.count;
    } else {
        return self.tags.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.searching) {
        StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"story_cell"];
        [cell configureWithDict:self.searchResults[indexPath.row]];
        return cell;
    } else {
        FilterTagCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag_cell"];
        cell.tagLabel.text = [self.tags[indexPath.row] uppercaseString];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.searching) {
        NSDictionary *storyDict = self.searchResults[indexPath.row];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.directoryVC.delegate openStoryWithDict:storyDict];
        }];
    } else {
        [self filterStoriesOnTag:self.tags[indexPath.row]];
    }
}

#pragma mark -
-(void)filterStoriesOnTag:(NSString*)tag {
    NSArray *fullList = [DataManager sharedInstance].directoryStories;
    NSMutableArray<NSDictionary*> *sublist = [NSMutableArray arrayWithCapacity:fullList.count];

    if([tag isEqualToString:@"featured"]) {
        for(NSDictionary *storyDict in fullList) {
            if([storyDict[@"featured"] boolValue]) {
                [sublist addObject:storyDict];
            }
        }
    } else {
        NSString *lowercaseTag = tag.lowercaseString;
        
        for(NSDictionary *storyDict in fullList) {
            NSArray *tags = storyDict[@"tags"];
            if([tags containsObject:lowercaseTag]) {
                [sublist addObject:storyDict];
            }
        }
    }
    
    [self.directoryVC configureWithTag:tag.uppercaseString withStories:sublist];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
