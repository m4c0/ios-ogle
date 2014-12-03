//
//  OGLShader.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "OGLContext.h"

@interface OGLShader : NSObject<OGLContextListener>
@property (nonatomic, readonly) NSString * name;

+ (OGLShader *)sharedInstanceNamed:(NSString *)name;
+ (void)setProjection:(GLfloat *)mat;

- (id)initWithName:(NSString *)name;

- (GLint)enableVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type;
- (GLint)enableVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type usingStride:(GLsizei)stride andOffset:(GLuint)offset;
- (GLint)enableInstancedVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type;
- (GLint)enableInstancedVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type usingStride:(GLsizei)stride andOffset:(GLuint)offset;

- (GLint)getUniformLocation:(NSString *)name;

- (void)setUniform1f:(GLfloat)f forKey:(NSString *)key;
- (void)setUniform1i:(GLint)f forKey:(NSString *)key;
- (void)setUniform2f:(GLKVector2)f forKey:(NSString *)key;
- (void)setUniform3f:(GLKVector3)f forKey:(NSString *)key;
- (void)setUniform4f:(GLKVector4)f forKey:(NSString *)key;
- (void)setUniformMatrix4fv:(GLKMatrix4)f forKey:(NSString *)key;

- (void)use;

- (GLint)getAttribLocation:(NSString *)name;

@end
