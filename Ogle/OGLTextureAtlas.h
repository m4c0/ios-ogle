//
//  OGLTextureAtlas.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>

@interface OGLTextureAtlas : NSObject<NSCopying>
@property (nonatomic, readonly) NSString * name;

+ (OGLTextureAtlas *)atlasNamed:(NSString *)name;

- (void)bindFirstTexture:(GLenum)activeTexture;
- (CGSize)firstTextureSize;

- (BOOL)containsTextureNamed:(NSString *)name;
- (UIImage *)imageForTextureNamed:(NSString *)name;
- (CGRect)rectForTextureNamed:(NSString *)name;
- (GLKVector4)pointCoordsForTextureNamed:(NSString *)name;

- (void)getCoordsInto:(GLfloat *)coords stride:(int)stride forTextureNamed:(NSString *)name;
@end
