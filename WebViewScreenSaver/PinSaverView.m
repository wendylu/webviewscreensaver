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

@property (nonatomic, retain) IBOutlet NSButton *boardViewCheckbox;
@property (nonatomic, retain) IBOutlet NSTextField *boardNameField;

@property (nonatomic, strong, readwrite) NSImage *logoImage;
@property (nonatomic, assign, readwrite) CGFloat logoAlpha;
@property (nonatomic, assign, readwrite) CGFloat logoScale;

@property (nonatomic, strong, readwrite) WebView *webView;
@property (nonatomic, assign, readwrite) double scrollPosition;
@property (nonatomic, assign, readwrite) BOOL webViewHasScrolled;
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
    
    [self.webView setMainFrameURL:@"http://www.pinterest.com/wendylu1/wonderstruck/"];
    
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

    [self configureGridCellColor];
    
    //Disable Scroll Bars
    script = @"$('body').css('overflow', 'hidden')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('body').css('overflow', 'auto')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    //Disable Scroll Bars
    [self.webView setHidden:NO];
    
    script = @"var onTop = 0; window.setInterval(function(){ window.scroll(0, onTop); onTop = 1 + onTop; window.console.log(onTop) }, 100);";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    NSTimer *gridCellTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(configureGridCellColor) userInfo:nil repeats:YES];
    
    //Board View
    script = @"$('.boardName').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.description').css({color: '#C3C3C3'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('.BoardInfoBar').remove()";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
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
	
	[self.boardViewCheckbox setState:[defaults boolForKey:@"BoardView"]];
	[self.boardNameField setStringValue:[defaults stringForKey:@"BoardName"]];
	
	return configSheet;
}

- (IBAction)dismissConfigSheet:(id)sender {
    ScreenSaverDefaults *defaults;
    
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    
	// Update our defaults
	[defaults setBool:[self.boardViewCheckbox state] forKey:@"BoardView"];
	[defaults setObject:self.boardNameField.stringValue forKey:@"BoardName"];
    
	// Save the settings to disk
	[defaults synchronize];
    
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}

@end
