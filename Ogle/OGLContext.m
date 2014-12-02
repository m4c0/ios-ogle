//
//  OGLContext.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLContext.h"

#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>

static NSString * const OGLContextDidChange = @"OGLContextDidChange";
static NSString * const OGLContextWillInvalidate = @"OGLContextWillInvalidate";

static EAGLContext * OGLCurrentContext = nil;

@implementation OGLContext

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentContext)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearContext)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(releaseContext)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

+ (EAGLContext *)currentContext {
    if (!OGLCurrentContext) {
        OGLCurrentContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!OGLCurrentContext) abort();
    }
    if (OGLCurrentContext != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:OGLCurrentContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:OGLContextDidChange object:nil];
    }
    return OGLCurrentContext;
}
+ (void)clearContext {
    [EAGLContext setCurrentContext:nil];
}
+ (void)releaseContext {
    [[NSNotificationCenter defaultCenter] postNotificationName:OGLContextWillInvalidate object:nil];
    
    [self clearContext];
    
    OGLCurrentContext = nil;
}

+ (void)registerListener:(id<OGLContextListener>)listener {
    [[NSNotificationCenter defaultCenter] addObserver:listener
                                             selector:@selector(oglContextDidChange)
                                                 name:OGLContextDidChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:listener
                                             selector:@selector(oglContextWillInvalidate)
                                                 name:OGLContextWillInvalidate
                                               object:nil];
    if (OGLCurrentContext) [listener oglContextDidChange];
}

+ (void)unregisterListener:(id<OGLContextListener>)listener {
    if (OGLCurrentContext) [listener oglContextWillInvalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:listener
                                                    name:OGLContextDidChange
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:listener
                                                    name:OGLContextWillInvalidate
                                                  object:nil];
}

@end
