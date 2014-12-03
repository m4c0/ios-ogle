//
//  OGLTripleBufferQuads.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol OGLTripleBufferQuadsDelegate <NSObject>
- (void)prepareBuffer:(int)i;
- (void)disposeBuffers;
@end

@interface OGLTripleBufferQuads : NSObject
- (instancetype)initWithDelegate:(id<OGLTripleBufferQuadsDelegate>)delegate;

- (int)flip;
- (void *)mapBuffer;
- (void)unmapBuffer;
- (int)bindPublicBuffer;

- (void)generateQuadsUsingBlock:(int(^)(void *))block;
- (void)drawArray:(GLenum)mode;
@end
