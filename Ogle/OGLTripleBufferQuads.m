//
//  OGLTripleBufferQuads.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLTripleBufferQuads.h"

#import <GLKit/GLKit.h>

#import "OGLContext.h"
#import "OGLRedundantRemover.h"

@import OpenGLES.ES2.glext;

@interface OGLTripleBufferQuads ()<OGLContextListener>
@end

@implementation OGLTripleBufferQuads {
    id<OGLTripleBufferQuadsDelegate> delegate;
    
    GLuint vao[3], vbo[3];
    int quadCount[3];
    
    int publicBuffer;
    int bakingBuffer;
    int writingBuffer;
}

- (instancetype)initWithDelegate:(id<OGLTripleBufferQuadsDelegate>)d {
    self = [super init];
    if (self) {
        delegate = d;
        
        [OGLContext registerListener:self];
    }
    return self;
}
- (void)dealloc {
    [OGLContext unregisterListener:self];
}

- (void)oglContextDidChange {
    glGenVertexArraysOES(3, vao);
    glGenBuffers(3, vbo);
    
    for (int i = 0; i < 3; i++) {
        [OGLRedundantRemover bindVertexArray:vao[i]];
        
        glBindBuffer(GL_ARRAY_BUFFER, vbo[i]);
        [delegate prepareBuffer:i];
    }
}
- (void)oglContextWillInvalidate {
    glDeleteVertexArraysOES(3, vao);
    glDeleteBuffers(3, vbo);
}

- (int)flip {
    publicBuffer = bakingBuffer;
    bakingBuffer = writingBuffer;
    writingBuffer = (writingBuffer + 1) % 3;
    
    return writingBuffer;
}

- (void *)mapBuffer {
    glBindBuffer(GL_ARRAY_BUFFER, vbo[writingBuffer]);
    return glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
}

- (void)unmapBuffer {
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}

- (int)bindPublicBuffer {
    [OGLRedundantRemover bindVertexArray:vao[publicBuffer]];
    return publicBuffer;
}

- (void)generateQuadsUsingBlock:(int(^)(void *))block {
    [self flip];
    
    void * buf = [self mapBuffer];
    quadCount[writingBuffer] = block(buf);
    [self unmapBuffer];
}

- (void)drawArray:(GLenum)mode {
    if (!quadCount[publicBuffer]) return;
    
    [self bindPublicBuffer];
    glDrawArrays(mode, 0, quadCount[publicBuffer]);
}

@end
