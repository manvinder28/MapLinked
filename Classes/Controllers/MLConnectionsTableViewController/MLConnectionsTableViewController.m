//
//  MLConnectionsTableViewController.m
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLConnectionsTableViewController.h"
#import "MLUser.h"
#import "MLConnectionsTableCell.h"
#import "MLConnectionInfoViewController.h"

@interface MLConnectionsTableViewController ()

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *connectionsData;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *loadDataActivityIndicatorView;
@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation MLConnectionsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Connections", @"Connections");
        self.tabBarItem.image = [UIImage imageNamed:@"DockContacts.png"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logoutDidFinish:)
                                                     name:kLogOutNotification
                                                   object:nil];
    }
    return self;
}

- (void)logoutDidFinish:(NSNotification *)notification {
    [self reloadTable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadTable];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable)
                                                 name:kUpdateConnectionsFinalNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kUpdateConnectionsFinalNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reloadTable {
    self.connectionsData = nil;

    NSString *searchText = [[self.searchBar text] uppercaseString];
    if (searchText.length > 0) {
        NSMutableArray *filteringArray = [NSMutableArray array];
        for (MLUser *connection in [[MLDataManager sharedInstance] connections]) {
            NSString *companyNameString = [connection.firstName uppercaseString];
            
            NSRange range = [companyNameString rangeOfString:searchText];
            if (range.location != NSNotFound) {
                [filteringArray addObject:connection];
            }
        }
        self.connectionsData = [NSArray arrayWithArray:filteringArray];
    } else {
        self.connectionsData = [[MLDataManager sharedInstance] connections];
    }

    
    if (![[MLDataManager sharedInstance] connections]) {
        self.tableView.separatorColor = [UIColor clearColor];
        [self.loadDataActivityIndicatorView startAnimating];
        return;
    }
    if (self.connectionsData.count == 0) {
        self.tableView.separatorColor = [UIColor clearColor];
    } else {
        self.tableView.separatorColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    }
    [self.loadDataActivityIndicatorView stopAnimating];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.connectionsData) {
        return 0;
    }
    return [self.connectionsData count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    MLConnectionsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MLConnectionsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    MLUser *user = [self.connectionsData objectAtIndex:indexPath.row];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [user firstName], [user lastName]];
    cell.nameLabel.text = fullName;

    UIImage *defaultImage = [UIImage imageNamed:@"ghost_profile.png"];
    [cell.profileImage setDefaultImage:defaultImage];
    [cell.profileImage loadImageFromURL:user.pictureURL];


    cell.industryLabel.text = [user industry];

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MLUser *user = [self.connectionsData objectAtIndex:indexPath.row];

    MLConnectionInfoViewController *connectionInfoViewController = [[MLConnectionInfoViewController alloc] initWithNibName:@"MLConnectionInfoViewController" bundle:nil userID:user.userUniqId];
    [self.navigationController pushViewController:connectionInfoViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Search bar delegate metods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self reloadTable];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [self reloadTable];
}

@end
