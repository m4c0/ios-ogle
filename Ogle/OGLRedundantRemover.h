//
//  OGLRedundantRemover.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface OGLRedundantRemover : NSObject

+ (void)bindTexture2D:(GLuint)t at:(GLenum)activeTexture;
+ (void)bindVertexArray:(GLuint)vao;
+ (void)setActiveTexture:(GLenum)activeTexture;

+ (void)reset;

@end
