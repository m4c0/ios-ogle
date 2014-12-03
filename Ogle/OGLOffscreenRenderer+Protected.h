//
//  OGLOffscreenRenderer+Protected.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLContext.h"

@interface OGLOffscreenRenderer (Protected)<OGLContextListener>
- (int)arrayBufferCount;
- (void)prepareArrayObject;
- (BOOL)requiresElementBuffer;
- (void)draw;
@end