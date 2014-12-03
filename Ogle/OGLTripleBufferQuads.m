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
    
    GLuint vao[3], vbo[3], ivbo[3], evbo[3];
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

- (BOOL)elements {
    return [delegate respondsToSelector:@selector(prepareElementBuffer:)];
}
- (BOOL)instanced {
    return [delegate respondsToSelector:@selector(prepareInstanceBuffer:)];
}

- (void)oglContextDidChange {
    glGenVertexArraysOES(3, vao);
    glGenBuffers(3, vbo);
    if ([self instanced]) glGenBuffers(3, ivbo);
    if ([self elements]) glGenBuffers(3, evbo);
    
    for (int i = 0; i < 3; i++) {
        [OGLRedundantRemover bindVertexArray:vao[i]];
        
        glBindBuffer(GL_ARRAY_BUFFER, vbo[i]);
        [delegate prepareBuffer:i];
        
        if ([self instanced]) {
            glBindBuffer(GL_ARRAY_BUFFER, ivbo[i]);
            [delegate prepareInstanceBuffer:ivbo[i]];
        }
        
        if ([self elements]) {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ivbo[i]);
            [delegate prepareElementBuffer:ivbo[i]];
        }
    }
}
- (void)oglContextWillInvalidate {
    glDeleteVertexArraysOES(3, vao);
    glDeleteBuffers(3, vbo);
    if ([self instanced]) glDeleteBuffers(3, ivbo);
    if ([self elements]) glDeleteBuffers(3, evbo);
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

- (void *)mapInstanceBuffer {
    glBindBuffer(GL_ARRAY_BUFFER, ivbo[writingBuffer]);
    return glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
}

- (void)unmapInstanceBuffer {
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}

#warning TODO: renomear para "bindPublicArrayBuffer"
- (int)bindPublicBuffer {
    [OGLRedundantRemover bindVertexArray:vao[publicBuffer]];
    return publicBuffer;
}

- (void)generateQuadsUsingBlock:(int(^)(void *))block {
    [self flip];
    
    void * buf = [self instanced] ? [self mapInstanceBuffer] : [self mapBuffer];
    quadCount[writingBuffer] = block(buf);
    if ([self instanced]) {
        [self unmapInstanceBuffer];
    } else {
        [self unmapBuffer];
    }
}

- (void)drawArray:(GLenum)mode {
    if (!quadCount[publicBuffer]) return;
    
    [self bindPublicBuffer];
    if ([self instanced]) {
        if ([self elements]) {
            glDrawElementsInstancedEXT(mode, [delegate mainBufferCount], [delegate elementType], 0, quadCount[publicBuffer]);
        } else {
            glDrawArraysInstancedEXT(mode, 0, [delegate mainBufferCount], quadCount[publicBuffer]);
        }
    } else {
        if ([self elements]) {
            glDrawElements(mode, quadCount[publicBuffer], [delegate elementType], 0);
        } else {
            glDrawArrays(mode, 0, quadCount[publicBuffer]);
        }
    }
}

@end
