//
//  OGLTripleBufferTexture.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLTripleBufferTexture.h"

#import "OGLContext.h"
#import "OGLRedundantRemover.h"

@import OpenGLES.ES2.glext;

@interface OGLTripleBufferTexture ()<OGLContextListener>
@end

@implementation OGLTripleBufferTexture {
    GLuint textures[3];
    int loadedTexture;
    int frontTexture;
    
    CGSize size;
    NSString * label;
}

- (instancetype)initWithSize:(CGSize)s {
    self = [super init];
    if (self) {
        size = s;
        label = nil;
        [OGLContext registerListener:self];
    }
    return self;
}
- (instancetype)initWithSize:(CGSize)s andLabel:(NSString *)l {
    self = [super init];
    if (self) {
        size = s;
        label = l;
        [OGLContext registerListener:self];
    }
    return self;
}

- (void)dealloc {
    [OGLContext unregisterListener:self];
}

- (void)oglContextDidChange {
    glGenTextures(3, textures);
    for (int i = 0; i < 3; i++) {
        [OGLRedundantRemover bindTexture2D:textures[i] at:GL_TEXTURE0];
#ifdef DEBUG
        if (label) {
            NSString * lbl = [label stringByAppendingFormat:@"-%d", i];
            glLabelObjectEXT(GL_TEXTURE, textures[i], 0, [lbl UTF8String]);
        }
#endif
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    
    
}

- (void)oglContextWillInvalidate {
    glDeleteTextures(3, textures);
}

- (void)buildAndFlipAtSlot:(GLenum)slot usingBlock:(void (^)())block {
    if (loadedTexture != frontTexture) {
        frontTexture = loadedTexture;
    }
    [self flipAndBindLoadableTextureAtSlot:slot];
    block();
    [OGLRedundantRemover bindTexture2D:textures[frontTexture] at:slot];
}

- (void)bindLoadedTextureAtSlot:(GLenum)slot {
    if (loadedTexture != frontTexture) {
        frontTexture = loadedTexture;
    }
    [OGLRedundantRemover bindTexture2D:textures[frontTexture] at:slot];
}
- (void)flipAndBindLoadableTextureAtSlot:(GLenum)slot {
    loadedTexture = (loadedTexture + 1) % 3;
    [self bindLoadableTextureAtSlot:slot];
}
- (void)bindLoadableTextureAtSlot:(GLenum)slot {
    [OGLRedundantRemover bindTexture2D:textures[loadedTexture] at:slot];
}

@end
