//
//  OGLContext.h
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 02/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EAGLContext;

@protocol OGLContextListener <NSObject>
- (void)oglContextDidChange;
- (void)oglContextWillInvalidate;
@end

@interface OGLContext : NSObject

+ (EAGLContext *)currentContext;

+ (void)registerListener:(id<OGLContextListener>)listener;
+ (void)unregisterListener:(id<OGLContextListener>)listener;

@end
