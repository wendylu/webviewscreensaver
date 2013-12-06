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

@interface PinSaverView ()
@property (nonatomic, strong, readwrite) WebView *webView;
@property (nonatomic, assign, readwrite) double scrollPosition;
@end

@implementation PinSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        //[self setAnimationTimeInterval:1/30.0];
        
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
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

    [self addSubview:self.webView];
    
    NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
    [[self.webView layer] setBackgroundColor:color.CGColor];
    
    [self.webView setMainFrameURL:@"http://pinterest.com"];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scrollTimerFired) userInfo:nil repeats:YES];
    
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
    NSString *script = @"document.getElementsByClassName('Grid Module')[0].style.background = '#333333'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"document.getElementsByClassName('Module NewPinsIndicator')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    //Remove elements
    script = @"document.getElementsByClassName('Header Module')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"document.getElementsByClassName('HeroHelperBase HeroNelsonMandela Module')[0].style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"document.getElementsByClassName('pinMeta').style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"document.getElementsByClassName('variableHeightLayout padItems GridItems Module centeredWithinWrapper').style.display='none'";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Disable Scroll Bars
    script = @"$('body').css('overflow', 'hidden')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('body').css('overflow', 'auto')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    //Disable Scroll Bars
    [self.webView setHidden:NO];
}

#pragma mark Scrolling

- (void)scrollTimerFired
{
    self.scrollPosition += 100.0;
    
    NSString *script = [NSString stringWithFormat:@"$('html, body').animate({scrollTop:%f}, 1000, 'linear')", self.scrollPosition];
    [self.webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
