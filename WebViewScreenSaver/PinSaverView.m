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

    script = @"document.getElementsByClassName('Module NewPinsIndicator')[0].style.display='none'";
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

    //Change background and text color of pin metadata
    script = @"$('.pinMeta').css({background: '#333333'});";
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
    
    //Change borders
    script = @"$('.richPinMeta').css({'border-bottom': 'solid 1px #333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.pinCredits').css({'border-top': 'solid 1px #333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    script = @"$('.recommendationReason').css({'border-top': 'solid 1px #333333'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];

    //Disable Scroll Bars
    script = @"$('body').css('overflow', 'hidden')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    script = @"$('body').css('overflow', 'auto')";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    //Disable Scroll Bars
    [self.webView setHidden:NO];
    
    script = @"var onTop = 0; window.setInterval(function(){ window.scroll(0, onTop); onTop = 1 + onTop; window.console.log(onTop) }, 100);";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark Scrolling

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
