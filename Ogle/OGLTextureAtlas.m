//
//  OGLTextureAtlas.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLTextureAtlas.h"

#import "OGLContext.h"
#import "OGLRedundantRemover.h"

@interface OGLTextureAtlas ()<OGLContextListener>
@end

@implementation OGLTextureAtlas {
    NSMutableDictionary * images;
    NSMutableArray * textures;
    NSMutableArray * uiimages;
}


+ (OGLTextureAtlas *)atlasNamed:(NSString *)name {
    static NSMutableDictionary * cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary new];
    });
    if (cache[name]) return cache[name];
    return cache[name] = [[OGLTextureAtlas alloc] initWithName:name];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        [OGLContext registerListener:self];
    }
    return self;
}
- (void)dealloc {
    [OGLContext unregisterListener:self];
}

- (void)oglContextWillInvalidate {
    images = nil;
    textures = nil;
    uiimages = nil;
}

- (void)oglContextDidChange {
    NSString * atlasc = [self.name stringByAppendingPathExtension:@"atlasc"];
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:self.name
                                                           ofType:@"plist"
                                                      inDirectory:atlasc];
    NSDictionary * plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (!plist) abort();
    
    if (![plist[@"format"] isEqualToString:@"APPL"] || ([plist[@"version"] intValue] != 1)) {
        NSLog(@"Invalid atlas version: %@ (%@)", plist[@"format"], plist[@"version"]);
        abort();
    }
    
    images = [NSMutableDictionary new];
    textures = [NSMutableArray new];
    uiimages = [NSMutableArray new];
    
    for (NSDictionary * image in plist[@"images"]) {
        [self loadImageFromDictionary:image withBasePath:atlasc];
    }
    NSAssert([textures count] == 1, @"Numero de texturas no atlas");
}

- (BOOL)loadImageFromDictionary:(NSDictionary *)image withBasePath:(NSString *)basePath {
    NSString * filename = image[@"path"];
    NSString * path = [filename stringByDeletingPathExtension];
    NSString * imagePath = [[NSBundle mainBundle] pathForResource:path ofType:@"png" inDirectory:basePath];
    
    [uiimages addObject:[UIImage imageWithContentsOfFile:imagePath]];
    
    [OGLRedundantRemover setActiveTexture:GL_TEXTURE7];
    
    NSError * err;
    GLKTextureInfo * info = [GLKTextureLoader textureWithContentsOfFile:imagePath options:nil error:&err];
    if (!info || err) {
        NSLog(@"%@", err);
        return NO;
    }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    [textures addObject:info];
    
    for (NSDictionary * subimage in image[@"subimages"]) {
        [self loadSubimageFromDictionary:subimage texture:info];
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}

- (void)loadSubimageFromDictionary:(NSDictionary *)subimage texture:(GLKTextureInfo *)texture {
    NSString * name = subimage[@"name"];
    NSString * name2 = [subimage[@"name"] stringByDeletingPathExtension];
    //    CGSize spriteOffset = CGSizeFromString(subimage[@"spriteOffset"]);
    //    CGSize spriteSourceSize = CGSizeFromString(subimage[@"spriteSourceSize"]);
    
#warning Remover suporte a extensao no nome das imagens
    images[name] = @{@"texture" : texture,
                     @"rect"    : [NSValue valueWithCGRect:CGRectFromString(subimage[@"textureRect"])],
                     @"rotated" : subimage[@"textureRotated"]};
    images[name2] = images[name];
}

- (void)bindFirstTexture:(GLenum)activeTexture {
    GLKTextureInfo * info = [textures firstObject];
    [OGLRedundantRemover bindTexture2D:info.name at:activeTexture];
}
- (CGSize)firstTextureSize {
    GLKTextureInfo * info = [textures firstObject];
    return CGSizeMake(info.width, info.height);
}

- (BOOL)containsTextureNamed:(NSString *)name {
    return images[name] != nil;
}
- (CGRect)rectForTextureNamed:(NSString *)name {
    NSDictionary * img = images[name];
    NSAssert(img, @"Invalid texture");
    NSAssert(img[@"rect"], @"Invalid texture");
    return [img[@"rect"] CGRectValue];
}
- (GLKVector4)pointCoordsForTextureNamed:(NSString *)name {
    CGSize size = self.firstTextureSize;
    CGRect rect = [self rectForTextureNamed:name];
    return GLKVector4Make(rect.origin.x / size.width,
                          rect.origin.y / size.height,
                          rect.size.width / size.width,
                          rect.size.height / size.height);
}

#pragma message("Verificar alinhamento com spriteOffset (truque do alpha 1%)")
- (void)getCoordsInto:(GLfloat *)coords stride:(int)stride forTextureNamed:(NSString *)name {
    NSDictionary * img = images[name];
    
    stride /= sizeof(GLfloat);
    
    CGRect rect = [self rectForTextureNamed:name];
    CGSize size = [self firstTextureSize];
    
    float su = rect.origin.x / size.width;
    float sv = rect.origin.y / size.height;
    float eu = su + rect.size.width / size.width;
    float ev = sv + rect.size.height / size.height;
    if ([img[@"rotated"] boolValue]) {
        coords[0] = eu; coords[1] = sv; coords += stride;
        coords[0] = eu; coords[1] = ev; coords += stride;
        coords[0] = su; coords[1] = ev; coords += stride;
        coords[0] = su; coords[1] = sv; coords += stride;
    } else {
        coords[0] = su; coords[1] = sv; coords += stride;
        coords[0] = eu; coords[1] = sv; coords += stride;
        coords[0] = eu; coords[1] = ev; coords += stride;
        coords[0] = su; coords[1] = ev; coords += stride;
    }
}

- (float)rotationForTextureNamed:(NSString *)name {
    NSDictionary * img = images[name];
    return [img[@"rotated"] boolValue] ? M_PI / 2.0 : 0.0;
}
- (GLKVector4)rotationMatrixForTextureNamed:(NSString *)name {
    float angle = [self rotationForTextureNamed:name];
    return GLKVector4Make(cos(angle), -sin(angle), sin(angle), cos(angle));
}

- (UIImage *)imageForTextureNamed:(NSString *)name {
    CGRect rect = [self rectForTextureNamed:name];
    UIImage * img = [uiimages firstObject];
    CGImageRef cgi = CGImageCreateWithImageInRect(img.CGImage, rect);
    img = [UIImage imageWithCGImage:cgi scale:1 orientation:[images[name][@"rotated"] boolValue] ? UIImageOrientationLeft : UIImageOrientationUp];
    CGImageRelease(cgi);
    return img;
}

@end
