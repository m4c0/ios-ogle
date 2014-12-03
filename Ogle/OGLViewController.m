//
//  OGLViewController.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 03/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLViewController.h"

#import "OGLContext.h"

@implementation OGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    view.context = [OGLContext currentContext];
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
#ifdef DEBUG
    self.preferredFramesPerSecond = 60;
#else
    self.preferredFramesPerSecond = 30;
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GLKView *view = (GLKView *)self.view;
    view.context = [OGLContext currentContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
    }
}

@end
