//
//  OGLRedundantRemover.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLRedundantRemover.h"

#import "OGLContext.h"

@import OpenGLES.ES2.glext;

static GLuint OGLRedundantVAO = ~0;
static GLuint OGLRedundantTex[8] = { ~0, ~0, ~0, ~0, ~0, ~0, ~0, ~0 };
static GLuint OGLRedundantAT = ~0;

@interface OGLRedundantRemover ()<OGLContextListener>
@end

@implementation OGLRedundantRemover

+ (instancetype)instance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self allocWithZone:nil] init];
    });
    return instance;
}
+ (id)alloc {
    return [self instance];
}

+ (void)load {
    [OGLContext registerListener:[self instance]];
}
+ (void)reset {
    for (int i = 0; i < 8; i++) {
        OGLRedundantTex[i] = ~0;
    }
    OGLRedundantVAO = ~0;
    OGLRedundantAT = ~0;
}

- (void)oglContextDidChange {
    [OGLRedundantRemover reset];
}
- (void)oglContextWillInvalidate {
}

+ (void)bindVertexArray:(GLuint)vao {
    if (OGLRedundantVAO != vao) {
        OGLRedundantVAO = vao;
        glBindVertexArrayOES(vao);
    }
}

+ (void)bindTexture2D:(GLuint)t at:(GLenum)activeTexture {
    [self setActiveTexture:activeTexture];
    
    int at = activeTexture - GL_TEXTURE0;
    if (OGLRedundantTex[at] != t) {
        OGLRedundantTex[at] = t;
        glBindTexture(GL_TEXTURE_2D, t);
    }
}
+ (void)setActiveTexture:(GLenum)activeTexture {
    if (OGLRedundantAT != activeTexture) {
        OGLRedundantAT = activeTexture;
        glActiveTexture(activeTexture);
    }
}

@end
