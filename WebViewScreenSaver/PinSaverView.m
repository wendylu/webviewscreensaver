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
@property (nonatomic, strong, readwrite) NSImage *logoImage;
@property (nonatomic, assign, readwrite) CGFloat logoAlpha;


@property (nonatomic, strong, readwrite) WebView *webView;
@property (nonatomic, assign, readwrite) double scrollPosition;
@property (nonatomic, assign, readwrite) BOOL webViewHasScrolled;
@end

@implementation PinSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1.0 / 15.0];
        
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
        
        NSBundle *saverBundle = [NSBundle bundleForClass:[self class]];
        _logoImage = [[NSImage alloc] initWithContentsOfFile:[saverBundle pathForResource:@"Logotype" ofType:@"png"]];
        self.logoAlpha = 0;
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
    script = @"$('.commenterNameCommentText').css({color: '#FFFFFF'});";
    [self.webView stringByEvaluatingJavaScriptFromString:script];
    script = @"$('.commentDescriptionContent').css({color: '#C3C3C3'});";
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
    
    CGPoint origin = CGPointMake((rect.size.width - self.logoImage.size.width) / 2, (rect.size.height - self.logoImage.size.height) / 2);
    [self.logoImage drawAtPoint:origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:self.logoAlpha];
    
}

- (void)animateOneFrame
{
    if (self.logoAlpha < 1.0) {
        self.logoAlpha += 0.03;
        [self setNeedsDisplay:YES];
    } else {
        if (self.webView.superview == nil) {
            [self addSubview:self.webView];
        } else {
            [self configureGridCellColor];
        }

    }
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
