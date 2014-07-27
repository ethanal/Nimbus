//
//  ScreenshotWatch.h
//  Nimbus
//
//  Created by Ethan Lowman on 7/27/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FileCallbackBlock)(NSData*, NSString*);

@interface ScreenshotWatcher : NSObject

@property (nonatomic, copy) FileCallbackBlock uploadCallback;

- (instancetype)initWithUploadFileCallback:(FileCallbackBlock)callback;
- (void)startWatchingPath:(NSString*) path;

@end
