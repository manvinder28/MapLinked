//
//  MLFeedTableViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 1/3/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MLFeedTableViewController.h"
#import "MLNewFeedViewController.h"
#import "MLFeedDetailViewController.h"

@interface MLFeedTableViewController ()

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *feedData;
@end

@implementation MLFeedTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Feed", @"Feed");
        self.tabBarItem.image = [UIImage imageNamed:@"DockMessages.png"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTable)
                                                     name:kUpdateFeedFinalNotification
                                                   object:nil];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *newFeedButton = [[UIBarButtonItem alloc] initWithTitle:@"+"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(newFeed)];
    self.navigationItem.rightBarButtonItem = newFeedButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[MLLinkedInManager sharedInstance] updateFeed];
}

- (void)newFeed {
    MLNewFeedViewController *newFeedViewController = [[MLNewFeedViewController alloc] initWithNibName:@"MLNewFeedViewController" bundle:nil];
    [self.navigationController pushViewController:newFeedViewController
                                         animated:YES];
}

- (void)reloadTable {
    self.feedData = [MLDataManager sharedInstance].feedArray;
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.feedData) {
        return 0;
    }
    return [self.feedData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    QBCOCustomObject *feed = self.feedData[indexPath.row];
    cell.textLabel.text = feed.fields[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QBCOCustomObject *feed = self.feedData[indexPath.row];
    MLFeedDetailViewController *feedDetailViewController = [[MLFeedDetailViewController alloc] initWithFeed:feed];
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

@end
