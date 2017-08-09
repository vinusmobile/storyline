//
//  ProfileViewController.m
//  storyline
//
//  Created by Jimmy Xu on 11/6/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "ProfileViewController.h"
#import "RowCollectionTableViewCell.h"
#import "ConversationMarker+CoreDataClass.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    __weak RowCollectionTableViewCell *readingListCell;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor str_paleGreyBackgroundColor];
    
    self.tableView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0);
    [self.tableView registerNib:[UINib nibWithNibName:@"RowCollectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"row_collection_cell"];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    _fetchedResultsController = [ConversationMarker MR_fetchAllSortedBy:@"last_opened" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    readingListCell.contentArray = controller.fetchedObjects;
}

#pragma mark -


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 25)];;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, header.width, 25)];
    title.font = [UIFont systemFontOfSize:22.0f weight:UIFontWeightBold];
    title.textColor = [UIColor lightGrayColor];
    title.text = @"Reading List";
    [header addSubview:title];
    return header;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RowCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"row_collection_cell"];
    cell.contentArray = self.fetchedResultsController.fetchedObjects;
    cell.delegate = self.delegate;
    readingListCell = cell;
    return cell;
}

@end
