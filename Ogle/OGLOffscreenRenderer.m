//
//  OGLOffscreenRenderer.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLOffscreenRenderer.h"

#warning Descobrir um jeito de tornar esse Protected protegido
#import "OGLOffscreenRenderer+Protected.h"

#import "OGLContext.h"
#import "OGLRedundantRemover.h"
#import "OGLShader.h"

@import OpenGLES.ES2.glext;

@implementation OGLOffscreenRenderer {
    GLint depthTest, stencilTest;
    int bufferCount, arrayCount;
    CGSize size;
    GLuint vao[3], vbo[3], ibo[3], fb[3], fbtex[3];
    GLuint depth[3], stencil[3];
    
    BOOL mipmap;
    
    GLenum filter, format;
}

+ (instancetype)instance {
    static NSMutableDictionary * instances = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instances = [NSMutableDictionary new];
    });
    
    NSString * key = NSStringFromClass([self class]);
    id res = instances[key];
    if (!res) {
        res = [[self allocWithZone:nil] init];
        [instances setObject:res forKey:key];
    }
    
    return res;
}
+ (id)alloc {
    return [self instance];
}

- (instancetype)initWithSize:(CGSize)sz textureFilter:(GLint)flt bufferCount:(int)cnt {
    self = [super init];
    if (self) {
        [self prepareWithSize:sz textureFilter:flt andFormat:GL_UNSIGNED_BYTE bufferCount:cnt];
    }
    return self;
}
- (instancetype)initWithSize:(CGSize)sz textureFilter:(GLint)flt andFormat:(GLint)fmt bufferCount:(int)cnt {
    self = [super init];
    if (self) {
        [self prepareWithSize:sz textureFilter:flt andFormat:fmt bufferCount:cnt];
    }
    return self;
}

- (void)prepareWithSize:(CGSize)sz textureFilter:(GLint)flt andFormat:(GLint)fmt bufferCount:(int)cnt {
    size = sz;
    bufferCount = cnt;
    filter = flt;
    format = fmt;
    
    NSString * name = NSStringFromClass([self class]);
    _shader = [[OGLShader alloc] initWithName:name];
    
    arrayCount = [self arrayBufferCount];
    
    mipmap = (filter != GL_LINEAR) && (filter != GL_NEAREST);
    
    [OGLContext registerListener:self];
}

- (void)oglContextDidChange {
    if (arrayCount > 0) [self generateArrayBuffers];
    
    void * data = calloc(size.width * size.height, format == GL_HALF_FLOAT_OES ? 8 : 4);
    
#warning !!! Obviamente isso não funciona na mudança de contexto !!!
    glGetIntegerv(GL_DEPTH_TEST, &depthTest);
    glGetIntegerv(GL_STENCIL_TEST, &stencilTest);
    
    glGenFramebuffers(bufferCount, fb);
    glGenTextures(bufferCount, fbtex);
    if (depthTest) glGenRenderbuffers(3, depth);
    if (stencilTest) glGenRenderbuffers(3, stencil);
    for (int i = 0; i < bufferCount; i++) {
        glBindFramebuffer(GL_FRAMEBUFFER, fb[i]);
        
        [OGLRedundantRemover bindTexture2D:fbtex[i] at:GL_TEXTURE0];
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, format, data);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
        if (mipmap) {
            BOOL linear = (filter == GL_LINEAR_MIPMAP_LINEAR) || (filter == GL_LINEAR_MIPMAP_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, linear ? GL_LINEAR : GL_NEAREST);
        } else {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
        }
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        if (mipmap) {
            glGenerateMipmap(GL_TEXTURE_2D);
        }
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbtex[i], 0);
        
        if (depthTest == GL_TRUE) {
            glBindRenderbuffer(GL_RENDERBUFFER, depth[i]);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, size.width, size.height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depth[i]);
        }
        if (stencilTest == GL_TRUE) {
#warning Rever stencil apos troca para o iOS 8 (GL_STENCIL_INDEX8_OES sumiu)
            abort();
            //            glBindRenderbuffer(GL_RENDERBUFFER, stencil[i]);
            //            glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8_OES, size.width, size.height);
            //            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, stencil[i]);
        }
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            abort();
        }
        
#ifdef DEBUG
        NSString * name = NSStringFromClass([self class]);
        NSString * lbl = [NSString stringWithFormat:@"%@-%d", name, i];
        glLabelObjectEXT(GL_FRAMEBUFFER, fb[i], 0, [lbl UTF8String]);
        glLabelObjectEXT(GL_TEXTURE, fbtex[i], 0, [lbl UTF8String]);
#endif
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    
    free(data);
    
    publicBuffer = 0;
    inputBuffer = (publicBuffer + 1) % bufferCount;
    outputBuffer = (inputBuffer + 1) % bufferCount;
}

- (void)dealloc {
    [OGLContext unregisterListener:self];
}
- (void)oglContextWillInvalidate {
    glDeleteTextures(bufferCount, fbtex);
    glDeleteFramebuffers(bufferCount, fb);
    if (arrayCount > 0) {
        glDeleteBuffers(arrayCount, ibo);
        glDeleteBuffers(arrayCount, vbo);
        glDeleteVertexArraysOES(arrayCount, vao);
    }
    if (depthTest == GL_TRUE) glDeleteRenderbuffers(3, depth);
    if (stencilTest == GL_TRUE) glDeleteRenderbuffers(3, stencil);
}

- (int)arrayBufferCount {
    return 1;
}
- (BOOL)requiresElementBuffer {
    return NO;
}

- (void)generateArrayBuffers {
    glGenVertexArraysOES(arrayCount, vao);
    glGenBuffers(arrayCount, vbo);
    if ([self requiresElementBuffer]) glGenBuffers(arrayCount, ibo);
    
    for (int i = 0; i < arrayCount; i++) {
        [OGLRedundantRemover bindVertexArray:vao[i]];
#ifdef DEBUG
        NSString * name = [NSString stringWithFormat:@"%@-%d", NSStringFromClass([self class]), i];
        glLabelObjectEXT(GL_VERTEX_ARRAY_OBJECT_EXT, vao[i], 0, [name UTF8String]);
#endif
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo[i]);
        glBindBuffer(GL_ARRAY_BUFFER, vbo[i]);
        
        [self prepareArrayObject];
    }
    
    [OGLRedundantRemover bindVertexArray:0];
}

#pragma mark - Bindings

- (void)bindInputTextureAtSlot:(GLenum)slot {
    [OGLRedundantRemover bindTexture2D:fbtex[inputBuffer] at:slot];
}

- (void)bindPublicTextureAtSlot:(GLenum)slot {
    [OGLRedundantRemover bindTexture2D:fbtex[publicBuffer] at:slot];
}

- (void)bindPublicFramebuffer {
    glBindFramebuffer(GL_FRAMEBUFFER, fb[publicBuffer]);
}

- (void)bindVertexBuffer {
    glBindBuffer(GL_ARRAY_BUFFER, vbo[outputBuffer % arrayCount]);
}

#pragma mark Rendering

- (void)prepareRendering {
    glBindFramebuffer(GL_FRAMEBUFFER, fb[outputBuffer]);
    
#ifdef DEBUG
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        abort();
    }
#endif
    
    glViewport(0, 0, size.width, size.height);
    
    GLbitfield dpt = (depthTest == GL_TRUE) ? GL_DEPTH_BUFFER_BIT : 0;
    GLbitfield stt = (stencilTest == GL_TRUE) ? GL_STENCIL_BUFFER_BIT : 0;
    glClear(GL_COLOR_BUFFER_BIT | dpt | stt);
    
    [_shader use];
    [OGLRedundantRemover bindVertexArray:vao[inputBuffer % arrayCount]];
    
    __block int i = 0;
    [self.inputs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self->_shader setUniform1i:i forKey:key];
        [obj bindInputTextureAtSlot:GL_TEXTURE0 + i];
        i++;
    }];
}

- (void)finishRendering {
    GLenum e[2];
    GLsizei ec = 0;
    if (depthTest) {
        e[ec] = GL_DEPTH_ATTACHMENT;
        ec++;
    }
    if (stencilTest) {
        e[ec] = GL_STENCIL_ATTACHMENT;
        ec++;
    }
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, ec, e);
    //glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    if (mipmap) {
        [OGLRedundantRemover bindTexture2D:fbtex[outputBuffer] at:GL_TEXTURE0];
        glGenerateMipmap(GL_TEXTURE_2D);
    }
}

- (void)flipBuffers {
    inputBuffer  = (inputBuffer  + 1) % bufferCount;
    outputBuffer = (outputBuffer + 1) % bufferCount;
    publicBuffer = (publicBuffer + 1) % bufferCount;
}

- (void)render {
    [self renderUsingBlock:^{
        [self draw];
    }];
}

- (void)renderUsingBlock:(void (^)())block {
#ifdef DEBUG
    NSString * name = NSStringFromClass([self class]);
    glPushGroupMarkerEXT(0, [name UTF8String]);
#endif
    
    [self prepareRendering];
    block();
    [self flipBuffers];
    [self finishRendering];
    
#ifdef DEBUG
    glPopGroupMarkerEXT();
#endif
}

@end
