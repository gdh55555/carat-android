//
//  InstructionViewController.m
//  Carat
//
//  Created by Adam Oliner on 2/9/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "InstructionViewController.h"
#import "Sampler.h"
#import "Utilities.h"

@implementation InstructionViewController

@synthesize actionType = _actionType;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil actionType:(ActionType)action
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        [self setActionType:action];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIWebView

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    // Ignore NSURLErrorDomain error -999.
    if (error.code == NSURLErrorCancelled) return;
    
    // Ignore "Fame Load Interrupted" errors. Seen after app store links.
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
    
    // Normal error handling…
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.title = @"Action Instructions";
    
    // TODO load the appropriate HTML into theHTML based on actionType
    switch (self.actionType) {
        case ActionTypeKillApp:
            DLog(@"Loading Kill App instructions:");
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"killapp.html" relativeToURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]]]];
            break;
            
        case ActionTypeRestartApp:
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"killapp" ofType:@"html"] isDirectory:NO]]];
            break;
            
        case ActionTypeUpgradeOS:
        case ActionTypeDimScreen:
            DLog(@"These instructions not yet implemented.");
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] isDirectory:NO]]];
            break;
        case ActionTypeSpreadTheWord:
            DLog(@"Should not be loading InstructionView when ActionType is SpreadTheWord!");
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] isDirectory:NO]]];
            break;

        default:
            DLog(@"Unrecognized Action Type!");
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] isDirectory:NO]]];
            break;
    }
}

- (void)viewDidUnload
{
    [webView release];
    [self setWebView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[Sampler instance] checkConnectivityAndSendStoredDataToServer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [webView release];
    [super dealloc];
}

@end