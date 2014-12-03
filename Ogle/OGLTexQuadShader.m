//
//  OGLTexQuadShader.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLTexQuadShader.h"

#import "OGLContext.h"
#import "OGLRedundantRemover.h"

@import OpenGLES.ES2.glext;

@implementation OGLTexQuadShader {
    CGRect rect;
    GLuint vao, vbo, ibo;
}

- (instancetype)initWithName:(NSString *)name {
    self = [super initWithName:name];
    if (self) {
        rect = CGRectMake(-1, -1, 2, 2);
    }
    return self;
}
- (instancetype)initWithName:(NSString *)name andRect:(CGRect)r {
    self = [super initWithName:name];
    if (self) {
        rect = r;
    }
    return self;
}

- (void)oglContextDidChange {
    [super oglContextDidChange];
    
    glGenVertexArraysOES(1, &vao);
    [OGLRedundantRemover bindVertexArray:vao];
    
    GLfloat l = rect.origin.x;
    GLfloat b = rect.origin.y;
    GLfloat r = l + rect.size.width;
    GLfloat t = b + rect.size.height;
    
    GLfloat v[] = {
        l, b, 0, 0,
        r, b, 1, 0,
        l, t, 0, 1,
        r, t, 1, 1,
    };
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(v), v, GL_STATIC_DRAW);
    
    GLushort i[] = { 0, 1, 2, 1, 2, 3 };
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(i), i, GL_STATIC_DRAW);
    
    [self enableVertexAttribNamed:@"av2_pos" withSize:2 andType:GL_FLOAT usingStride:16 andOffset:0];
    [self enableVertexAttribNamed:@"av2_tex" withSize:2 andType:GL_FLOAT usingStride:16 andOffset:8];
}

- (void)oglContextWillInvalidate {
    [super oglContextWillInvalidate];
    
    glDeleteBuffers(1, &vbo);
    glDeleteBuffers(1, &ibo);
    glDeleteVertexArraysOES(1, &vao);
}

- (void)render {
    [OGLRedundantRemover bindVertexArray:vao];
    [self use];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
}

@end
