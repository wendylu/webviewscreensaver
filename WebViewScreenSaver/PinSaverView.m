//
//  PinSaverView.m
//  PinSaver
//
//  Created by Wendy Lu on 12/5/13.
//  Copyright (c) 2013 Pinterest. All rights reserved.
//

#import "PinSaverView.h"

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#define kWebViewContentPadding  50

static NSString * const MyModuleName = @"com.Pinterest.MyScreenSaver";

@interface PinSaverView ()
{
    IBOutlet id configSheet;
}

@property (strong) IBOutlet NSTabView *configTabView;
@property (strong) IBOutlet NSTabViewItem *homeFeedTabViewItem;
@property (strong) IBOutlet NSTabViewItem *boardTabViewItem;

@property (nonatomic, retain) IBOutlet NSTextField *userNameField;
@property (nonatomic, retain) IBOutlet NSTextField *boardNameField;
@property (strong) IBOutlet NSTextField *userNameLabel;
@property (strong) IBOutlet NSTextField *boardTitleLabel;

@property (nonatomic, strong, readwrite) NSImage *logoImage;
@property (nonatomic, assign, readwrite) CGFloat logoAlpha;
@property (nonatomic, assign, readwrite) CGFloat logoScale;

@property (nonatomic, strong, readwrite) WebView *webView;
@property (nonatomic, assign, readwrite) double scrollPosition;
@property (nonatomic, assign, readwrite) BOOL webViewHasScrolled;
@property (nonatomic, assign, readwrite) BOOL webviewLoaded;
@property (nonatomic, assign, readwrite) BOOL displayConfigured;
@end

@implementation PinSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1.0 / 30.0];
        
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
        
        NSBundle *saverBundle = [NSBundle bundleForClass:[self class]];
        _logoImage = [[NSImage alloc] initWithContentsOfFile:[saverBundle pathForResource:@"Logotype" ofType:@"png"]];
        self.logoAlpha = 0.0;
        self.logoScale = 0.5;
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    
    // Create the webview for the screensaver.
    self.webView = [[WebView alloc] initWithFrame:[self bounds]];
    [self.webView setFrameLoadDelegate:self];
    [self.webView setShouldUpdateWhileOffscreen:YES];
    [self.webView setPolicyDelegate:self];
    [self.webView setUIDelegate:self];
    [self.webView setEditingDelegate:self];
    [self.webView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setDrawsBackground:NO];
    [self.webView setHidden:YES];
    
    NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
    [[self.webView layer] setBackgroundColor:color.CGColor];
    
    [self.webView setMainFrameURL:[self webViewURL]];
    
    //Hide scroll bar by making content width a little larger than the width of the screen
    CGRect frame = self.webView.mainFrame.frameView.frame;
    frame.origin.x -= 10;
    frame.size.width += kWebViewContentPadding * 2;
    self.webView.mainFrame.frameView.frame = frame;
    
    
}

- (void)stopAnimation
{
    [super stopAnimation];
    
    [self.webView removeFromSuperview];
    [self.webView close];
    self.webView = nil;
}

#pragma mark Web View

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    self.webviewLoaded = YES;
    if (self.webView.superview && self.displayConfigured == NO) {
        self.displayConfigured = YES;
        [self configureDisplay];
    }
}

- (void)configureDisplay
{
    NSString *script = @"$('body, .Grid').css({background: '#333333'})";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Hide corners
    script = @"$('.pinWrapper').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"document.getElementsByClassName('Module NewPinsIndicator')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"document.getElementsByClassName('Header Module')[0].style.opacity = 0.9";
    [self.webView stringByEvaluatingJavaScriptFromString:script];


    //Remove elements
    script = @"$('.leftHeaderContent, .rightHeaderContent').remove()";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"document.getElementsByClassName('HeroHelperBase HeroNelsonMandela Module')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"document.getElementsByClassName('Nags Module')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];


    script = @"document.getElementsByClassName('variableHeightLayout padItems GridItems Module centeredWithinWrapper').style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"document.getElementsByClassName('scrollToTop rounded Button ScrollToTop Module btn')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Configure invite friends cell
    script = @"document.getElementsByClassName('item')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Grid cell colors
    [self configureGridCellColor];

    //Disable Scroll Bars
    script = @"$('body').css('overflow', 'hidden')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"$('body').css('overflow', 'auto')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Disable Scroll Bars
    [self.webView setHidden:NO];

    script = @"var onTop = 0; window.setInterval(function(){ window.scroll(0, onTop); onTop = 1 + onTop; window.console.log(onTop) }, 50);";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Board View
    script = @"$('.boardName').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.description').css({color: '#C3C3C3'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"$('.BoardInfoBar').remove()";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Since pins are loaded by page, we need to check for and configure the newly loaded cells
    NSTimer *pagingTimer = [NSTimer timerWithTimeInterval:2.0
                                                   target:self
                                                 selector:@selector(pagingTimerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:pagingTimer forMode:NSDefaultRunLoopMode];
}

- (void)configureGridCellColor
{
    //Change background and text color of pin metadata
    NSString *script = @"$('.pinMeta').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.pinDescription').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.pinSocialMeta').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('.richPinMeta').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.richPinGridTitle').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.richPinGridAttributionTitle').css({color: '#C3C3C3'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('.pinCredits').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.creditName').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.creditTitle').css({color: '#C3C3C3'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('.recommendationReasonWrapper').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.recommendationReason').css({color: '#C3C3C3'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('.PinCommentList Module summary').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.commentDescriptionCreator').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.commentDescriptionContent').css({color: '#C3C3C3'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.ui-TextField Module').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.pinDescriptionCommentItem pinUserCommentBox').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.PinCommentList Module summary').css({background: '#333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    
    //Change borders
    script = @"$('.richPinMeta').css({'border-bottom': 'solid 1px #333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('.pinCredits').css({'border-top': 'solid 1px #333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('.recommendationReason').css({'border-top': 'solid 1px #333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)pagingTimerFired:(NSTimer *)timer
{
    //Check for and remove new pins indicator, configure grid cell color
    NSString *script = @"document.getElementsByClassName('Module NewPinsIndicator')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    [self configureGridCellColor];
}

- (NSString *)webViewURL
{
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

    NSString *url = @"http://www.pinterest.com/";
    
    if ([defaults boolForKey:@"BoardView"]) {
        if ([defaults stringForKey:@"UserName"].length > 0 && [defaults stringForKey:@"BoardName"].length > 0) {
            //Append Username
            url = [[url stringByAppendingString:[defaults stringForKey:@"UserName"]] stringByAppendingString:@"/"];
            
            NSString *boardNameForURL = [defaults stringForKey:@"BoardName"];
            
            //Trim whitespace at end
            boardNameForURL = [boardNameForURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            //Remove all non alphanumeric characters except whitespace
            NSMutableCharacterSet *characterSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
            [characterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
            [characterSet addCharactersInString:@" "];
            [characterSet addCharactersInString:@"-"];
            NSCharacterSet *toRemove = [characterSet invertedSet];
            boardNameForURL = [[boardNameForURL componentsSeparatedByCharactersInSet:toRemove] componentsJoinedByString:@""];

            //Replace whitespace with hyphens
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@" +" options:NSRegularExpressionCaseInsensitive error:&error];
            boardNameForURL = [regex stringByReplacingMatchesInString:boardNameForURL options:0 range:NSMakeRange(0, [boardNameForURL length]) withTemplate:@"-"];

            //Append board name
            url = [[url stringByAppendingString:boardNameForURL] stringByAppendingString:@"/"];
        }
    }
    return url;
}

#pragma mark Scrolling

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    CGSize newSize = CGSizeMake(self.logoImage.size.width * self.logoScale, self.logoImage.size.height * self.logoScale);
    
    CGPoint origin = CGPointMake((rect.size.width - newSize.width) / 2, (rect.size.height - newSize.height) / 2);
    CGRect newRect = CGRectMake(origin.x, origin.y, newSize.width, newSize.height);
    [self.logoImage drawInRect:newRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:self.logoAlpha];
    
}

- (void)animateOneFrame
{
    if (self.logoScale < 1.5) {
        self.logoScale += 0.015;
        
        if (self.logoScale < 1) {
            self.logoAlpha += 0.015;
        } else {
            self.logoAlpha -= 0.015;
        }
        
        [self setNeedsDisplay:YES];
    } else {
        if (self.webView.superview == nil) {
            [self addSubview:self.webView];
            if (self.webviewLoaded == YES && self.displayConfigured == NO) {
                self.displayConfigured = YES;
                [self configureDisplay];
            }
        }
    }
}

#pragma mark Configure Sheet

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    ScreenSaverDefaults *defaults;
    
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    
	if (!configSheet)
	{
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self])
		{
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}
	
	if ([defaults boolForKey:@"BoardView"]) {
        [self.configTabView selectTabViewItem:self.boardTabViewItem];

        if ([defaults stringForKey:@"UserName"]) {
            [self.userNameField setStringValue:[defaults stringForKey:@"UserName"]];
        }
        if ([defaults stringForKey:@"BoardName"]) {
            [self.boardNameField setStringValue:[defaults stringForKey:@"BoardName"]];
        }
    } else {
        [self.configTabView selectTabViewItem:self.homeFeedTabViewItem];
    }
    
	return configSheet;
}

- (IBAction)saveClick:(id)sender {
    ScreenSaverDefaults *defaults;
    
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    
	// Update our defaults
	[defaults setBool:self.configTabView.selectedTabViewItem == self.boardTabViewItem forKey:@"BoardView"];
    if (self.configTabView.selectedTabViewItem == self.boardTabViewItem) {
        [defaults setObject:self.boardNameField.stringValue forKey:@"BoardName"];
        [defaults setObject:self.userNameField.stringValue forKey:@"UserName"];
    }
    
	// Save the settings to disk
	[defaults synchronize];
    
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)cancelClick:(id)sender {
    [[NSApplication sharedApplication] endSheet:configSheet];
}

@end
