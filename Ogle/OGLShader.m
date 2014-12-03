//
//  OGLShader.m
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import "OGLShader.h"

#import "OGLContext.h"

@import OpenGLES.ES2.glext;

static __weak OGLShader * IGEShaderCache[1024];
static int IGEShaderCacheCount = 0;
static GLint kShaderProgramCurrent = -1;

@implementation OGLShader {
    NSMutableDictionary * attribLocations;
    NSMutableDictionary * uniformLocations;
    NSMutableDictionary * uniformValues;
    
    GLuint progId;
    GLint um4Projection;
}

#pragma mark -
#pragma mark Private Methods

#pragma mark Program Compilation

- (const GLchar *)utf8StringForFile:(NSString *)file type:(GLenum)type {
    NSString * ext = (type == GL_VERTEX_SHADER) ? @"vsh" : @"fsh";
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:file ofType:ext];
    if (!path) {
        NSLog(@"Shader does not exist: %@.%@", file, ext);
        abort();
    }
    return (GLchar *)[[NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding
                                                   error:nil] UTF8String];
}

- (GLuint)compileShaderForSource:(const GLchar *)src type:(GLenum)type {
    GLuint shader = glCreateShader(type);
    if (!shader) {
        abort();
    }
    glShaderSource(shader, 1, &src, NULL);
    glCompileShader(shader);
    return shader;
}

- (GLuint)checkShaderCompilation:(GLuint)shader {
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(shader);
        abort();
    }
    
    return shader;
}

- (GLuint)compileAndCheckShaderForFile:(NSString *)file type:(GLenum)type {
    const GLchar * src = [self utf8StringForFile:file type:type];
    
    GLuint shader = [self compileShaderForSource:src type:type];
#ifdef DEBUG
    GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        NSLog(@"Warning for shader '%@':\n%s", file, log);
        free(log);
    }
#endif
    return [self checkShaderCompilation:shader];
}

#pragma mark Program Linking

- (void)linkProgram {
    glLinkProgram(progId);
    
#ifdef DEBUG
    GLint logLength;
    glGetProgramiv(progId, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(progId, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetProgramiv(progId, GL_LINK_STATUS, &status);
    if (status == 0) {
        if (progId) glDeleteProgram(progId);
        abort();
    }
}

- (void)deleteAndDetachShader:(GLuint)shader {
    if (shader) {
        glDetachShader(progId, shader);
        glDeleteShader(shader);
    }
}

#pragma mark -
#pragma mark Public methods

+ (void)setProjection:(GLfloat *)mat {
    glPushGroupMarkerEXT(0, "Shader: Projection Matrix");
    
    for (int i = 0; i < IGEShaderCacheCount; i++) {
        if (!IGEShaderCache[i]) {
            IGEShaderCacheCount--;
            IGEShaderCache[i] = IGEShaderCache[IGEShaderCacheCount];
            IGEShaderCache[IGEShaderCacheCount] = nil;
            if (IGEShaderCacheCount == 0) break;
        }
        [IGEShaderCache[i] use];
        glUniformMatrix4fv(IGEShaderCache[i]->um4Projection, 1, 0, mat);
    }
    
    glPopGroupMarkerEXT();
}

- (void)buildProgramWithVertex:(GLuint)vertShader
                      fragment:(GLuint)fragShader {
    progId = glCreateProgram();
    glAttachShader(progId, vertShader);
    glAttachShader(progId, fragShader);
    
    [self linkProgram];
    um4Projection = glGetUniformLocation(progId, "um4_projection");
    
    [self deleteAndDetachShader:vertShader];
    [self deleteAndDetachShader:fragShader];
    
    uniformLocations = [NSMutableDictionary new];
    uniformValues = [NSMutableDictionary new];
}

- (id)initWithName:(NSString *)name {
    if ((self = [super init])) {
        _name = name;
        
        if ([self class] == [OGLShader class]) [OGLContext registerListener:self];
    }
    return self;
}

- (void)dealloc {
    [OGLContext unregisterListener:self];
}
- (void)oglContextWillInvalidate {
    if (kShaderProgramCurrent == progId) kShaderProgramCurrent = -1;
    glDeleteProgram(progId);
    attribLocations = nil;
    uniformLocations = nil;
    uniformValues = nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)oglContextDidChange {
    GLuint vertShader = [self compileAndCheckShaderForFile:self.name type:GL_VERTEX_SHADER];
    GLuint fragShader = [self compileAndCheckShaderForFile:self.name type:GL_FRAGMENT_SHADER];
    
    [self buildProgramWithVertex:vertShader fragment:fragShader];
    [self addSelfToCache];
#ifdef DEBUG
    glLabelObjectEXT(GL_PROGRAM_OBJECT_EXT, progId, 0, [self.name UTF8String]);
#endif
}

- (GLint)enableVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type {
    return [self enableVertexAttribNamed:name withSize:size andType:type usingStride:0 andOffset:0];
}

- (GLint)enableVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type usingStride:(GLsizei)stride andOffset:(GLuint)offset {
    GLint loc = [self getAttribLocation:name];
    if (loc == -1) return -1;
    
    glEnableVertexAttribArray(loc);
    glVertexAttribPointer(loc, size, type, GL_FALSE, stride, (void *)(NULL + offset));
    return loc;
}

- (GLint)enableInstancedVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type {
    return [self enableInstancedVertexAttribNamed:name withSize:size andType:type usingStride:0 andOffset:0];
}
- (GLint)enableInstancedVertexAttribNamed:(NSString *)name withSize:(GLint)size andType:(GLint)type usingStride:(GLsizei)stride andOffset:(GLuint)offset {
    GLint loc = [self enableVertexAttribNamed:name withSize:size andType:type usingStride:stride andOffset:offset];
    if (loc == -1) return -1;
    
    glVertexAttribDivisorEXT(loc, 1);
    return loc;
}

- (GLint)getUniformLocation:(NSString *)key {
    [self use];
    
    NSNumber * loc = uniformLocations[key];
    if (!loc) {
        loc = @(glGetUniformLocation(progId, [key UTF8String]));
        uniformLocations[key] = loc;
    }
    return [loc intValue];
}
- (GLint)getAttribLocation:(NSString *)key {
    [self use];
    
    NSNumber * loc = attribLocations[key];
    if (!loc) {
        loc = @(glGetAttribLocation(progId, [key UTF8String]));
        attribLocations[key] = loc;
    }
    return [loc intValue];
}

- (void)setUniform1f:(GLfloat)f forKey:(NSString *)key {
    GLint loc = [self getUniformLocation:key];
    NSNumber * val = uniformValues[key];
    if (!val || [val floatValue] != f) {
        uniformValues[key] = @(f);
        glUniform1f(loc, f);
    }
}
- (void)setUniform1i:(GLint)f forKey:(NSString *)key {
    GLint loc = [self getUniformLocation:key];
    NSNumber * val = uniformValues[key];
    if (!val || [val intValue] != f) {
        uniformValues[key] = @(f);
        glUniform1i(loc, f);
    }
}
- (void)setUniform2f:(GLKVector2)f forKey:(NSString *)key {
    GLint loc = [self getUniformLocation:key];
    NSValue * val = uniformValues[key];
    if (!val || [val CGPointValue].x != f.x || [val CGPointValue].y != f.y) {
        uniformValues[key] = [NSValue valueWithCGPoint:CGPointMake(f.x, f.y)];
        glUniform2f(loc, f.x, f.y);
    }
}

- (void)setUniform3f:(GLKVector3)f forKey:(NSString *)key {
    GLint loc = [self getUniformLocation:key];
    glUniform3fv(loc, 1, f.v);
}
- (void)setUniform4f:(GLKVector4)f forKey:(NSString *)key {
    GLint loc = [self getUniformLocation:key];
    glUniform4fv(loc, 1, f.v);
}
- (void)setUniformMatrix4fv:(GLKMatrix4)f forKey:(NSString *)key {
    GLint loc = [self getUniformLocation:key];
    glUniformMatrix4fv(loc, 1, GL_FALSE, f.m);
}

- (void)use {
    if (kShaderProgramCurrent != progId) {
        glUseProgram(progId);
        kShaderProgramCurrent = progId;
    }
}

- (void)addSelfToCache {
    if (um4Projection > -1) {
        NSAssert(IGEShaderCacheCount < 1024, @"1024 shaders? really?");
        IGEShaderCache[IGEShaderCacheCount++] = self;
    }
}

+ (OGLShader *)sharedInstanceNamed:(NSString *)name {
    static NSMutableDictionary * cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary new];
    });
    
    if (cache[name]) return cache[name];
    return cache[name] = [[OGLShader alloc] initWithName:name];
}

@end
