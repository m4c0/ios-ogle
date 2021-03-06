//
//  OGLBasicQuadRenderer.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 10/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct OGLBasicQuadRendererBlock {
    GLKVector4 av4_pos;
    GLKVector4 av4_tex;
    GLKVector4 av4_rot;
    GLKVector4 av4_pickerColor;
    GLKVector2 av2_scale;
    GLfloat af_dim;
} OGLBasicQuadRendererBlock;

@interface OGLBasicQuadRenderer : NSObject
@property (nonatomic) GLKVector2 centerViewPosition;
@property (nonatomic) GLKVector4 sceneScale;
- (void)drawBlocks:(OGLBasicQuadRendererBlock *)block count:(int)c;
- (void)finishBlocks;
- (void)fixPublicBuffer;
- (void)render;
- (void)renderForPicking;
@end
