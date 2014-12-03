//
//  OGLOffscreenRenderer.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>

#warning Mover para o shader
#define OGLOffscreenRendererEnableAttrib(x, n, s) [self.shader enableVertexAttribNamed:@#n withSize:s andType:GL_FLOAT usingStride:sizeof(x) andOffset:offsetof(x, n)]

@class OGLShader;

@interface OGLOffscreenRenderer : NSObject {
@protected int outputBuffer, inputBuffer, publicBuffer;
}
@property (nonatomic, readonly) OGLShader * shader;
@property (nonatomic, readonly) NSDictionary * inputs;

+ (instancetype)instance;

- (instancetype)initWithSize:(CGSize)sz textureFilter:(GLint)filter bufferCount:(int)cnt;
- (instancetype)initWithSize:(CGSize)sz textureFilter:(GLint)filter andFormat:(GLint)format bufferCount:(int)cnt;

- (void)bindInputTextureAtSlot:(GLenum)slot;
- (void)bindPublicTextureAtSlot:(GLenum)slot;

- (void)bindPublicFramebuffer;

- (void)bindVertexBuffer;

- (void)render;
- (void)renderUsingBlock:(void(^)())block;

@end
