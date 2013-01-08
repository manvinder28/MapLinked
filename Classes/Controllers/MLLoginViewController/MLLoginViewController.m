//
//  MLLoginViewController.m
//  MapLinkedIn
//
//  Created by Alexey Naboychenko on 12/3/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MLLoginViewController.h"
#import "JSONKit.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"
#import "MLUser.h"
#import "MLAppDelegate.h"

//LinkedIn keys
#define kOAuthConsumerKey @"esgtsezw8nwc"
#define kOAuthConsumerSecret @"fICZhjobwQSQVSPa"

@interface MLLoginViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *splashImageView;
@property(nonatomic, weak) IBOutlet UIButton *loginButton;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *loadActivityIndicatorView;
@property(nonatomic, strong) IBOutlet UIView *authorizationView;
@property(nonatomic, weak) IBOutlet UIWebView *authorizationWebView;
@property(nonatomic, weak) IBOutlet UIButton *closeAuthorizationButton;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *requestActivityIndicatorView;

@property(nonatomic, strong) OAToken *requestToken;
@property(nonatomic, strong) OAConsumer *consumer;
@property(nonatomic, strong) NSString *requestTokenURLString;
@property(nonatomic, strong) NSURL *requestTokenURL;
@property(nonatomic, strong) NSString *accessTokenURLString;
@property(nonatomic, strong) NSURL *accessTokenURL;
@property(nonatomic, strong) NSString *userLoginURLString;
@property(nonatomic, strong) NSURL *userLoginURL;
@property(nonatomic, strong) NSString *linkedInCallbackURL;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)closeAuthorizationButtonPressed:(id)sender;

@end

@implementation MLLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initLinkedInApi];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (IS_IPHONE_GTE_568 || IS_IPOD_GTE_568) {
        self.view.frame = CGRectMake(0, 0, 320, 568);
        self.authorizationView.frame = CGRectMake(0, 0, 320, 568);
        self.splashImageView.image = [UIImage imageNamed:@"Default-568h.png"];
        [self.loadActivityIndicatorView stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }
}

- (void)initLinkedInApi {
    self.consumer = [[OAConsumer alloc] initWithKey:kOAuthConsumerKey secret:kOAuthConsumerSecret realm:@"http://api.linkedin.com/"];

    self.requestTokenURLString = @"https://api.linkedin.com/uas/oauth/requestToken";
    self.accessTokenURLString = @"https://api.linkedin.com/uas/oauth/accessToken";
    self.userLoginURLString = @"https://www.linkedin.com/uas/oauth/authorize";
    self.linkedInCallbackURL = @"hdlinked://linkedin/oauth";

    self.requestTokenURL = [NSURL URLWithString:self.requestTokenURLString];
    self.accessTokenURL = [NSURL URLWithString:self.accessTokenURLString];
    self.userLoginURL = [NSURL URLWithString:self.userLoginURLString];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.authorizationWebView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[MLLinkedInManager sharedInstance] networkAvailability]) {
        NSString *allertMessageString = NSLocalizedString(@"You do not appear to be connected to the internet", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:allertMessageString
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([[MLLinkedInManager sharedInstance] loadSavedLIToken]) {

        [self.loadActivityIndicatorView startAnimating];
        [self.loginButton setHidden:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginForQuickBlox)
                                                     name:kUpdateUserInfoFinalNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logoutForLinkedIn)
                                                     name:kUpdateUserInfoFailNotification
                                                   object:nil];
        [[MLLinkedInManager sharedInstance] updateUserInfo];

    } else {
        [self.loginButton setHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.authorizationWebView.delegate = nil;
    [self.authorizationWebView stopLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    if (![[MLLinkedInManager sharedInstance] networkAvailability]) {
        NSString *allertMessageString = NSLocalizedString(@"You do not appear to be connected to the internet", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:allertMessageString
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([[MLLinkedInManager sharedInstance] loadSavedLIToken]) {

        [self.loadActivityIndicatorView startAnimating];
        [self.loginButton setHidden:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginForQuickBlox)
                                                     name:kUpdateUserInfoFinalNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logoutForLinkedIn)
                                                     name:kUpdateUserInfoFailNotification object:nil];
        [[MLLinkedInManager sharedInstance] updateUserInfo];

    } else {
        [self showAuthorizationView];
    }
}

- (IBAction)closeAuthorizationButtonPressed:(id)sender {
    [self hideAuthorizationView];
}

- (void)showAuthorizationView {
    if (![self.authorizationView superview]) {
        [self.view addSubview:self.authorizationView];
        [self.loginButton setHidden:YES];
        [self requestTokenFromProvider];
    }
}

- (void)hideAuthorizationView {
    if ([self.authorizationView superview]) {
        [self.authorizationView removeFromSuperview];
        [self.authorizationWebView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
        if (![[MLLinkedInManager sharedInstance] accessToken] || ![[MLLinkedInManager sharedInstance] consumer]) {
            [self.loginButton setHidden:NO];
            [self.loadActivityIndicatorView stopAnimating];
        } else {
            [self.loadActivityIndicatorView startAnimating];
        }
    }
}

- (void)hideSplash {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.loadActivityIndicatorView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark LinkedIn Authorization metods
//
// OAuth step 1a:
//
// The first step in the the OAuth process to make a request for a "request token".
// Yes it's confusing that the work request is mentioned twice like that, but it is whats happening.
//
- (void)requestTokenFromProvider {
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.requestTokenURL
                                                                   consumer:self.consumer
                                                                      token:nil callback:self.linkedInCallbackURL
                                                          signatureProvider:nil];

    [request setHTTPMethod:@"POST"];

    NSString *permissions = @"r_fullprofile r_contactinfo r_emailaddress r_network w_messages";
    OARequestParameter *scopeParameter = [OARequestParameter requestParameter:@"scope"
                                                                        value:permissions];
    [request setParameters:[NSArray arrayWithObject:scopeParameter]];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenResult:didFinish:)
                  didFailSelector:@selector(requestTokenResult:didFail:)];
}

//
// OAuth step 1b:
//
// When this method is called it means we have successfully received a request token.
// We then show a webView that sends the user to the LinkedIn login page.
// The request token is added as a parameter to the url of the login page.
// LinkedIn reads the token on their end to know which app the user is granting access to.
//
- (void)requestTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    if (ticket.didSucceed == NO)
        return;

    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    self.requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    [self allowUserToLogin];
}

- (void)requestTokenResult:(OAServiceTicket *)ticket didFail:(NSData *)error {
    NSLog(@"%@", [error description]);
}

//
// OAuth step 2:
//
// Show the user a browser displaying the LinkedIn login page.
// They type username/password and this is how they permit us to access their data
// We use a UIWebView for this.
//
// Sending the token information is required, but in this one case OAuth requires us
// to send URL query parameters instead of putting the token in the HTTP Authorization
// header as we do in all other cases.
//
- (void)allowUserToLogin {
    NSString *userLoginURLWithToken = [NSString stringWithFormat:@"%@?oauth_token=%@",
                                                                 self.userLoginURLString, self.requestToken.key];

    self.userLoginURL = [NSURL URLWithString:userLoginURLWithToken];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:self.userLoginURL];
    [self.authorizationWebView loadRequest:request];
}


//
// OAuth step 3:
//
// This method is called when our webView browser loads a URL, this happens 3 times:
//
//      a) Our own [webView loadRequest] message sends the user to the LinkedIn login page.
//
//      b) The user types in their username/password and presses 'OK', this will submit
//         their credentials to LinkedIn
//
//      c) LinkedIn responds to the submit request by redirecting the browser to our callback URL
//         If the user approves they also add two parameters to the callback URL: oauth_token and oauth_verifier.
//         If the user does not allow access the parameter user_refused is returned.
//
//      Example URLs for these three load events:
//          a) https://www.linkedin.com/uas/oauth/authorize?oauth_token=<token value>
//
//          b) https://www.linkedin.com/uas/oauth/authorize/submit   OR
//             https://www.linkedin.com/uas/oauth/authenticate?oauth_token=<token value>&trk=uas-continue
//
//          c) hdlinked://linkedin/oauth?oauth_token=<token value>&oauth_verifier=63600     OR
//             hdlinked://linkedin/oauth?user_refused
//
//
//  We only need to handle case (c) to extract the oauth_verifier value
//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;

    NSString *urlString = url.absoluteString;

    [self.requestActivityIndicatorView startAnimating];

    BOOL requestForCallbackURL = ([urlString rangeOfString:self.linkedInCallbackURL].location != NSNotFound);
    if (requestForCallbackURL) {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"user_refused"].location == NSNotFound);
        if (userAllowedAccess) {
            [self.requestToken setVerifierWithUrl:url];
            [self accessTokenFromProvider];
        }
        else {
            // User refused to allow our app access
            // Notify parent and close this view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginViewDidFinish"
                                                                object:self
                                                              userInfo:nil];

            [self hideAuthorizationView];
        }
    }
    else {
        // Case (a) or (b), so ignore it
        BOOL shouldContinue = ([urlString rangeOfString:@"linkedin"].location != NSNotFound);
        if (!shouldContinue) {
            // User refused to allow our app access
            // Notify parent and close this view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginViewDidFinish"
                                                                object:self
                                                              userInfo:nil];

            [self hideAuthorizationView];
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.requestActivityIndicatorView stopAnimating];
}

//
// OAuth step 4:
//
- (void)accessTokenFromProvider {
    OAMutableURLRequest *request =
            [[OAMutableURLRequest alloc] initWithURL:self.accessTokenURL
                                            consumer:self.consumer
                                               token:self.requestToken
                                            callback:nil signatureProvider:nil];

    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenResult:didFinish:)
                  didFailSelector:@selector(accessTokenResult:didFail:)];
}

- (void)accessTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];

    BOOL problem = ([responseBody rangeOfString:@"oauth_problem"].location != NSNotFound);
    if (problem) {
        NSLog(@"Request access token failed.");
        NSLog(@"%@", responseBody);
    } else {
        OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];

        [[MLLinkedInManager sharedInstance] saveAccessToken:accessToken andConsumer:self.consumer];
    }

    [self hideAuthorizationView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginForQuickBlox) name:kUpdateUserInfoFinalNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutForLinkedIn) name:kUpdateUserInfoFailNotification object:nil];
    [[MLLinkedInManager sharedInstance] updateUserInfo];
}

- (void)logoutForLinkedIn {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MLLinkedInManager sharedInstance] setAccessToken:nil];
    [[MLLinkedInManager sharedInstance] setConsumer:nil];
    [self.loginButton setHidden:NO];
    [self.loadActivityIndicatorView stopAnimating];

    NSString *allertMessageString = NSLocalizedString(@"Error during authorization.\nTry again", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:allertMessageString
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}

#pragma mark - QB Authorization metods
#pragma mark -

- (void)loginForQuickBlox {

    MLUser *currentUser = [[MLDataManager sharedInstance] currentUser];

    QBUUser *userForLogin = [[QBUUser alloc] init];
    [userForLogin setLogin:[NSString stringWithFormat:@"login%@", currentUser.userUniqId]];
    [userForLogin setPassword:[NSString stringWithFormat:@"pass%@", currentUser.userUniqId]];


    void (^__block finalBlockLogin)(Result *) = ^(Result *result) {
        if (result.success) {
            [[MLLinkedInManager sharedInstance] updateUserConnections];
            [self hideSplash];
        }
        else if (result.status == 401) {// user is not exist, we need register new one

            MLUser *currentUser = [[MLDataManager sharedInstance] currentUser];

            QBUUser *userForReg = [[QBUUser alloc] init];
            [userForReg setLogin:[NSString stringWithFormat:@"login%@", currentUser.userUniqId]];
            [userForReg setPassword:[NSString stringWithFormat:@"pass%@", currentUser.userUniqId]];
            [userForReg setEmail:[NSString stringWithFormat:@"%@@qb.com", currentUser.userUniqId]];


            // work with register result
            void (^finalBlockRegister)(Result *) = ^(Result *result) {
                if (result.success) {
                    [QBUsers logInWithUserLogin:userForLogin.login
                                       password:userForLogin.password
                                       delegate:self
                                        context:(__bridge_retained void *) (finalBlockLogin)];
                }
                else {
                    [self logoutForLinkedIn];
                    NSLog(@"Error: %@", result.errors);
                }
            };

            [QBUsers signUp:userForLogin
                   delegate:self
                    context:(__bridge_retained void *) (finalBlockRegister)];
        }
    };

    void (^__block finalBlockCreateSession)(Result *) = ^(Result *result) {
        if (result.success) {
            [QBUsers logInWithUserLogin:userForLogin.login
                               password:userForLogin.password
                               delegate:self
                                context:(__bridge_retained void *) (finalBlockLogin)];
        } else {
            [self logoutForLinkedIn];
            NSLog(@"Error: %@", result.errors);
        }
    };

    [QBAuth createSessionWithDelegate:self
                              context:(__bridge_retained void *) (finalBlockCreateSession)];
}

#pragma mark -
#pragma mark UIAllerView delegate metods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.loadActivityIndicatorView stopAnimating];
    [self.loginButton setHidden:NO];
}

#pragma mark - QB delegate methods
#pragma mark -

- (void)completedWithResult:(Result *)result context:(void *)contextInfo {
    void(^block)(Result *result) = (__bridge void (^)(Result *result)) (contextInfo);
    block(result);
}
@end
