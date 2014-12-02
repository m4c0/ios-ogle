//
//  OGLTexQuadShader.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLShader.h"

@interface OGLTexQuadShader : OGLShader

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name andRect:(CGRect)rect;
- (void)render;

@end
