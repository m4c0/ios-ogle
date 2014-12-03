//
//  OGLTripleBufferTexture.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface OGLTripleBufferTexture : NSObject
- (instancetype)initWithSize:(CGSize)s;
- (instancetype)initWithSize:(CGSize)s andLabel:(NSString *)label;

- (void)bindLoadedTextureAtSlot:(GLenum)slot;
- (void)bindLoadableTextureAtSlot:(GLenum)slot;
- (void)flipAndBindLoadableTextureAtSlot:(GLenum)slot;

- (void)buildAndFlipAtSlot:(GLenum)slot usingBlock:(void(^)())block;
@end
