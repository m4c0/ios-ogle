//
//  OGLBasicQuadRenderer.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 10/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLBasicQuadRenderer.h"

#import "OGLShader.h"
#import "OGLTextureAtlas.h"
#import "OGLTripleBufferQuads.h"

@interface OGLBasicQuadRenderer ()<OGLTripleBufferQuadsDelegate>
@end

@implementation OGLBasicQuadRenderer{
    OGLShader * shader;
    OGLTextureAtlas * atlas;
    OGLTripleBufferQuads * blocks;
    
    OGLBasicQuadRendererBlock buffer[10240];
    int blockCount;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        shader = [OGLShader sharedInstanceNamed:NSStringFromClass([self class])];
        blocks = [[OGLTripleBufferQuads alloc] initWithDelegate:self];
        atlas = [OGLTextureAtlas atlasNamed:@"Default"];
    }
    return self;
}

- (void)prepareBuffer:(int)i {
    struct vtx { GLKVector2 av2_pos; GLKVector2 av2_tex; };
    GLKVector4 v[] = {
        { {-0.5, -0.5, 0, 0} },
        { {+0.5, -0.5, 1, 0} },
        { {-0.5, +0.5, 0, 1} },
        { {+0.5, +0.5, 1, 1} },
    };
    glBufferData(GL_ARRAY_BUFFER, sizeof(v), v, GL_STATIC_DRAW);
    OGLShaderEnableAttrib(shader, struct vtx, av2_pos, 2);
    OGLShaderEnableAttrib(shader, struct vtx, av2_tex, 2);
}

- (void)disposeBuffers {
}

- (void)prepareInstanceBuffer:(int)i {
    glBufferData(GL_ARRAY_BUFFER, sizeof(buffer), buffer, GL_DYNAMIC_DRAW);
    OGLShaderEnableInstancedAttrib(shader, OGLBasicQuadRendererBlock, av4_pos, 4);
    OGLShaderEnableInstancedAttrib(shader, OGLBasicQuadRendererBlock, av4_tex, 4);
    OGLShaderEnableInstancedAttrib(shader, OGLBasicQuadRendererBlock, av4_rot, 4);
    OGLShaderEnableInstancedAttrib(shader, OGLBasicQuadRendererBlock, av2_scale, 2);
    OGLShaderEnableInstancedAttrib(shader, OGLBasicQuadRendererBlock, af_dim, 1);
}

- (void)prepareElementBuffer:(int)i {
    GLushort ix[] = { 0, 1, 2, 1, 2, 3 };
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(ix), ix, GL_STATIC_DRAW);
}

- (GLenum)elementType {
    return GL_UNSIGNED_SHORT;
}

- (int)mainBufferCount {
    return 6;
}

#pragma mark -

- (void)drawBlocks:(OGLBasicQuadRendererBlock *)block count:(int)c {
    NSAssert(blockCount + c < 10240, @"Buffer overflow");
    memcpy(buffer + blockCount, block, c * sizeof(OGLBasicQuadRendererBlock));
    blockCount += c;
}

- (void)finishBlocks {
    if (blockCount == 0) return;
    
    [blocks generateQuadsUsingBlock:^int(void * ptr) {
        memcpy(ptr, self->buffer, sizeof(OGLBasicQuadRendererBlock) * self->blockCount);
        return self->blockCount;
    }];
    
    blockCount = 0;
}
- (void)fixPublicBuffer {
    [blocks flip];
    [blocks flip];
}

- (void)render {
    [atlas bindFirstTexture:GL_TEXTURE0];
    [shader setUniform2f:self.centerViewPosition forKey:@"uv2_position"];
    [shader setUniform4f:self.sceneScale forKey:@"uv4_scale"];
    [shader use];
    [blocks drawArray:GL_TRIANGLES];
}

@end
