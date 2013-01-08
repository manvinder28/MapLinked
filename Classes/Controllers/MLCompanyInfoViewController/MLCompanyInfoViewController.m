//
//  MLCompanyInfoViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 1/3/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MLCompanyInfoViewController.h"
#import "AsyncImageView.h"
#import "MLCompany.h"

@interface MLCompanyInfoViewController ()
@property(nonatomic, strong) NSString *companyID;
@property(nonatomic, weak) IBOutlet AsyncImageView *companyLogoImageView;
@property(nonatomic, weak) IBOutlet UILabel *companyNameLabel;
@property(nonatomic, weak) IBOutlet UITextView *aboutTextView;
@end

@implementation MLCompanyInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil companyID:(NSString *)uniqCompanyId {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.companyID = uniqCompanyId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadOutViws];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)reloadOutViws {
    MLCompany *company = [[MLDataManager sharedInstance] companyWithID:self.companyID];
    if (!company) {
        return;
    }
    UIImage *defaultImage = [UIImage imageNamed:@"ghost_company.png"];
    self.companyLogoImageView.defaultImage = defaultImage;
    [self.companyLogoImageView loadImageFromURL:company.logoURL];
    
    self.companyNameLabel.text = company.name;
    
    NSMutableString *aboutString = [NSMutableString string];
    if (company.descriptionString && company.descriptionString.length > 0) {
        [aboutString appendString:company.descriptionString];
        [aboutString appendString:@"\n"];

    }
    if (company.addressesStrings.count > 0) {
        for (NSString *address in company.addressesStrings) {
            if (aboutString.length > 0) {
                [aboutString appendString:@"\n"];
            }
            [aboutString appendString:address];
        }
    }
    self.aboutTextView.text = aboutString;
}
@end
