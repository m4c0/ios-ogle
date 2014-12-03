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

@optional // Instances
- (int)mainBufferCount;
- (void)prepareInstanceBuffer:(int)i;

@optional // Elements
- (GLenum)elementType; // UBYTE, USHORT, etc
- (void)prepareElementBuffer:(int)i;
@end

@interface OGLTripleBufferQuads : NSObject
- (instancetype)initWithDelegate:(id<OGLTripleBufferQuadsDelegate>)delegate;

- (int)flip;

- (void *)mapBuffer;
- (void)unmapBuffer;

- (void *)mapInstanceBuffer;
- (void)unmapInstanceBuffer;

- (int)bindPublicBuffer;

- (void)generateQuadsUsingBlock:(int(^)(void *))block;
- (void)drawArray:(GLenum)mode;
@end
