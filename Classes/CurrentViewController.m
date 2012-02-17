//
//  CurrentViewController.m
//  Carat
//
//  Created by Adam Oliner on 10/6/11.
//  Copyright 2011 UC Berkeley. All rights reserved.
//

#import "CurrentViewController.h"
#import "SHK.h"
#import "Utilities.h"
#import "DetailViewController.h"
#import "FlurryAnalytics.h"
#import "Sampler.h"
#import "CommunicationManager.h"
#import "UIDeviceHardware.h"
#import "Globals.h"
#import "UIImageDoNotCache.h"
#import "InstructionViewController.h"

@implementation CurrentViewController

@synthesize jscore = _jscore;
@synthesize lastUpdated = _lastUpdated;
@synthesize sinceLastWeekString = _sinceLastWeekString;
@synthesize osVersion = _osVersion;
@synthesize deviceModel = _deviceModel;
@synthesize portraitView, landscapeView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id) initWithNibName: (NSString *) nibNameOrNil 
                bundle: (NSBundle *)nibBundleOrNil 
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        self.title = @"My Device";
        self.tabBarItem.image = [UIImage imageNamed:@"32-iphone"];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - button actions

- (IBAction)getJScoreInfo:(id)sender
{
    InstructionViewController *ivController = [[InstructionViewController alloc] initWithNibName:@"InstructionView" actionType:ActionTypeJScoreInfo];
    [self.navigationController pushViewController:ivController animated:YES];
    [ivController release];
    [FlurryAnalytics logEvent:@"selectedJScoreInfo"];
}

- (DetailViewController *)getDetailView
{
    DetailViewController *detailView = [[[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil] autorelease];
    detailView.navTitle = @"Category Detail";
    return detailView;
}

- (IBAction)getSameOSDetail:(id)sender
{
    DetailScreenReport *dsr = [[Sampler instance] getOSInfo:YES];
    if ([dsr xVals] == nil || [[dsr xVals] count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Report!" 
                                                        message:@"Please check back later; we should have results for your device soon." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        DetailViewController *dvController = [self getDetailView];

        [dvController setXVals:[dsr xVals]];
        [dvController setYVals:[dsr yVals]];
        
        dsr = [[Sampler instance] getOSInfo:NO];
        [dvController setXValsWithout:[dsr xVals]];
        [dvController setYValsWithout:[dsr yVals]];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [[dvController appName] makeObjectsPerformSelector:@selector(setText:) withObject:@"Same Operating System"];
        UIImage *img = [UIImage newImageNotCached:@"icon57.png"];
        [[dvController appIcon] makeObjectsPerformSelector:@selector(setImage:) withObject:img];
        [img release];
        for (UIProgressView *pBar in [dvController appScore]) {
            [pBar setProgress:MIN(MAX([[[Sampler instance] getOSInfo:YES] score],0.0),1.0) animated:NO];
        }
        
        [[dvController thisText] makeObjectsPerformSelector:@selector(setText:) withObject:@"Same OS"];
        [[dvController thatText] makeObjectsPerformSelector:@selector(setText:) withObject:@"Different OS"];
        
        [FlurryAnalytics logEvent:@"selectedSameOS"
                   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[UIDevice currentDevice] systemVersion], @"OS Version", nil]];
    }
}

- (IBAction)getSameModelDetail:(id)sender
{
    DetailScreenReport *dsr = [[Sampler instance] getModelInfo:YES];
    if ([dsr xVals] == nil || [[dsr xVals] count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Report!" 
                                                        message:@"Please check back later; we should have results for your device soon." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        DetailViewController *dvController = [self getDetailView];

        [dvController setXVals:[dsr xVals]];
        [dvController setYVals:[dsr yVals]];
        dsr = [[Sampler instance] getModelInfo:NO];
        [dvController setXValsWithout:[dsr xVals]];
        [dvController setYValsWithout:[dsr yVals]];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [[dvController appName] makeObjectsPerformSelector:@selector(setText:) withObject:@"Same Device Model"];
        UIImage *img = [UIImage newImageNotCached:@"icon57.png"];
        [[dvController appIcon] makeObjectsPerformSelector:@selector(setImage:) withObject:img];
        [img release];
        for (UIProgressView *pBar in [dvController appScore]) {
            [pBar setProgress:MIN(MAX([[[Sampler instance] getModelInfo:YES] score],0.0),1.0) animated:NO];
        }
        
        [[dvController thisText] makeObjectsPerformSelector:@selector(setText:) withObject:@"Same Model"];
        [[dvController thatText] makeObjectsPerformSelector:@selector(setText:) withObject:@"Different Model"];
        
        UIDeviceHardware *h =[[UIDeviceHardware alloc] init];
        [FlurryAnalytics logEvent:@"selectedSameModel"
                   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[h platformString], @"Model", nil]];
        [h release];
    }
}

- (IBAction)getSimilarAppsDetail:(id)sender
{
    DetailScreenReport *dsr = [[Sampler instance] getSimilarAppsInfo:YES];
    if ([dsr xVals] == nil || [[dsr xVals] count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Report!" 
                                                        message:@"Please check back later; we should have results for your device soon." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        DetailViewController *dvController = [self getDetailView];
        
        [dvController setXVals:[dsr xVals]];
        [dvController setYVals:[dsr yVals]];
        dsr = [[Sampler instance] getSimilarAppsInfo:NO];
        [dvController setXValsWithout:[dsr xVals]];
        [dvController setYValsWithout:[dsr yVals]];
        
        [self.navigationController pushViewController:dvController animated:YES];
        
        [[dvController appName] makeObjectsPerformSelector:@selector(setText:) withObject:@"Similar Apps"];
        UIImage *img = [UIImage newImageNotCached:@"icon57.png"];
        [[dvController appIcon] makeObjectsPerformSelector:@selector(setImage:) withObject:img];
        [img release];
        for (UIProgressView *pBar in [dvController appScore]) {
            [pBar setProgress:MIN(MAX([[[Sampler instance] getSimilarAppsInfo:YES] score],0.0),1.0) animated:NO];
        }
        
        [[dvController thisText] makeObjectsPerformSelector:@selector(setText:) withObject:@"Similar Apps"];
        [[dvController thatText] makeObjectsPerformSelector:@selector(setText:) withObject:@"Different Apps"];
        
        [FlurryAnalytics logEvent:@"selectedSimilarApps"];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    DLog(@"My UUID: %@", [[Globals instance] getUUID]);
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidUnload
{
    [jscore release];
    [self setJscore:nil];
    [lastUpdated release];
    [self setLastUpdated:nil];
    [sinceLastWeekString release];
    [self setSinceLastWeekString:nil];
    [portraitView release];
    [self setPortraitView:nil];
    [landscapeView release];
    [self setLandscapeView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateView];
    [self orientationChanged:nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)updateView
{
    // J-Score
    [[self jscore] makeObjectsPerformSelector:@selector(setText:) withObject:[[NSNumber numberWithInt:(int)(MIN( MAX([[Sampler instance] getJScore], -1.0), 1.0)*100)] stringValue]];
    
    // Last Updated
    NSTimeInterval howLong = [[NSDate date] timeIntervalSinceDate:[[Sampler instance] getLastReportUpdateTimestamp]];
    for (UILabel *lastUp in self.lastUpdated) {
        lastUp.text = [Utilities formatNSTimeIntervalAsUpdatedNSString:howLong];
    }
    
    // Change since last week
    [[self sinceLastWeekString] makeObjectsPerformSelector:@selector(setText:) withObject:[[[[Sampler instance] getChangeSinceLastWeek] objectAtIndex:0] stringByAppendingString:[@" (" stringByAppendingString:[[[[Sampler instance] getChangeSinceLastWeek] objectAtIndex:1] stringByAppendingString:@"%)"]]]];
    
    DLog(@"jscore: %f, updated: %f, os: %f, model: %f, apps: %f", (MIN( MAX([[Sampler instance] getJScore], -1.0), 1.0)*100), howLong, MIN(MAX([[[Sampler instance] getOSInfo:YES] score],0.0),1.0), [[[Sampler instance] getModelInfo:YES] score], [[[Sampler instance] getSimilarAppsInfo:YES] score]);
    
    //  Memory info.
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) == KERN_SUCCESS)
    {
        int pagesize = [[UIDevice currentDevice] pageSize];
        int wired = vmstat.wire_count * pagesize;
        int active = vmstat.active_count * pagesize;
        int inactive = vmstat.inactive_count * pagesize;
        int free = vmstat.free_count * pagesize;
        int used = wired+active+inactive;
        float frac_used = (float)(used) / (float)(used+free);
        float frac_active = (float)(active) / (float)(used);
        
        
        
    } // TODO hook to ui

    // Device info
    UIDeviceHardware *h =[[UIDeviceHardware alloc] init];
    for (UILabel *mod in self.deviceModel) {
        mod.text = [h platformString];
    }
    [h release];
    
    for (UILabel *os in self.osVersion) {
        os.text = [UIDevice currentDevice].systemVersion;
    }
    
    [self.view setNeedsDisplay];
}

- (void) orientationChanged:(id)object
{  
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.view = self.portraitView;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
        {
            self.view = self.portraitView;
        } else {
            self.view = self.landscapeView;
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (void)dealloc {
    [jscore release];
    [lastUpdated release];
    [sinceLastWeekString release];
    [portraitView release];
    [landscapeView release];
    [super dealloc];
}

@end
