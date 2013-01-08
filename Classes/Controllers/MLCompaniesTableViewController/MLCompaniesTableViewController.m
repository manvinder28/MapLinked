//
//  MLCompaniesTableViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 12/24/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLCompaniesTableViewController.h"
#import "MLConnectionsTableCell.h"
#import "MLCompany.h"
#import "MLCompanyInfoViewController.h"

@interface MLCompaniesTableViewController ()

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *companiesData;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *loadDataActivityIndicatorView;
@property(nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation MLCompaniesTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Companies", @"Companies");
        self.tabBarItem.image = [UIImage imageNamed:@"DockFaves.png"];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadTable];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable)
                                                 name:kUpdateCompaniesInfoFinalNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kUpdateCompaniesInfoFinalNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTable {
    self.companiesData = nil;
    
    NSString *searchText = [[self.searchBar text] uppercaseString];
    if (searchText.length > 0) {
        NSMutableArray *filteringArray = [NSMutableArray array];
        for (MLCompany *company in [[MLDataManager sharedInstance] companies]) {
            NSString *companyNameString = [company.name uppercaseString];

            NSRange range = [companyNameString rangeOfString:searchText];
            if (range.location != NSNotFound) {
                [filteringArray addObject:company];
            }
        }
        self.companiesData = [NSArray arrayWithArray:filteringArray];
    } else {
        self.companiesData = [[MLDataManager sharedInstance] companies];
    }
        
    if (![[MLDataManager sharedInstance] companies]) {
        self.tableView.separatorColor = [UIColor clearColor];
        [self.loadDataActivityIndicatorView startAnimating];
        return;
    }
    if (self.companiesData.count == 0) {
        self.tableView.separatorColor = [UIColor clearColor];
    } else {
        self.tableView.separatorColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    }
    [self.loadDataActivityIndicatorView stopAnimating];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (!self.companiesData) {
        return 0;
    }
    return [self.companiesData count];
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
    
    MLCompany *company = [self.companiesData objectAtIndex:indexPath.row];

    cell.nameLabel.text = company.name;
    
    UIImage *defaultImage = [UIImage imageNamed:@"ghost_company.png"];
    cell.profileImage.defaultImage = defaultImage;
    [cell.profileImage loadImageFromURL:company.logoURL];
    cell.industryLabel.text = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    MLCompany *company = [self.companiesData objectAtIndex:indexPath.row];
    
    MLCompanyInfoViewController *companyInfoViewController = [[MLCompanyInfoViewController alloc] initWithNibName:@"MLCompanyInfoViewController" bundle:nil companyID:company.companyUniqId];

    [self.navigationController pushViewController:companyInfoViewController
                                         animated:YES];
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
