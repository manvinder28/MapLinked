//
//  MLNewFeedViewController.m
//  MapLinked
//
//  Created by Alexey Naboychenko on 1/3/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MLNewFeedViewController.h"

@interface MLNewFeedViewController ()
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextView *feedTextView;

@end

@implementation MLNewFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *newFeedButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(sendFeed)];
    self.navigationItem.rightBarButtonItem = newFeedButton;
}

- (void)sendFeed {
    NSString *title = self.titleTextField.text;
    NSString *feedText = self.feedTextView.text;

    if (title.length == 0 || feedText.length  == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:NSLocalizedString(@"Field can't be blank", @"Field can't be blank")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [[MLLinkedInManager sharedInstance] sendFeed:feedText
                                           title:title
                                        delegate:self
                               didFinishSelector:@selector(sendingFinish)
                                 didFailSelector:@selector(sendingFail)];
}

- (void)sendingFinish {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sending Finish"
                                                        message:NSLocalizedString(@"Sending Finish", @"Sending Finish")
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

}

- (void)sendingFail {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:NSLocalizedString(@"Sending Fail", @"Sending Fail")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
