//
//  ScreenshotWatch.m
//  Nimbus
//
//  Created by Ethan Lowman on 7/27/14.
//  Copyright (c) 2014 Ethanal. All rights reserved.
//

#import "ScreenshotWatcher.h"


@interface ScreenshotWatcher()

@property (nonatomic, assign) FSEventStreamRef eventStream;

@end

@implementation ScreenshotWatcher

- (instancetype)initWithUploadFileCallback:(FileCallbackBlock) callback {
    self = [super init];
    if (self) {
        self.uploadCallback = callback;
    }
    return self;
}


void fsEventsCallback(ConstFSEventStreamRef streamRef,
                      void *info,
                      size_t numEvents,
                      void *eventPaths,
                      const FSEventStreamEventFlags eventFlags[],
                      const FSEventStreamEventId eventIds[])
{
    char** paths = (char**)eventPaths;
    
    for (int i = 0; i < numEvents; i++) {
        NSString *path = [NSString stringWithUTF8String:paths[i]];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ((eventFlags[i] & kFSEventStreamEventFlagItemRenamed) && !(eventFlags[i] & kFSEventStreamEventFlagItemInodeMetaMod)) {
            if (![fileURL.lastPathComponent hasPrefix:@"."]) {
                NSMetadataItem *metadata = [[NSMetadataItem alloc] initWithURL:fileURL];
                if (metadata != nil && [[metadata attributes] containsObject:@"kMDItemIsScreenCapture"]) {
                    BOOL isScreenshot = [[metadata valueForAttribute:@"kMDItemIsScreenCapture"] integerValue] == 1;
                    if (isScreenshot) {
                        NSData *fileData = [fileManager contentsAtPath:path];
                        ScreenshotWatcher *watcher = (__bridge ScreenshotWatcher*)info;
                        watcher.uploadCallback(fileData, path);
                    }
                } else {
                    NSLog(@"Bad URL: %@", fileURL);
                }
            }

        }
        
    }
}

- (void)startWatchingPath:(NSString*) path {
    FSEventStreamContext context;
    context.info = (__bridge void *)(self);
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    NSArray *pathsToWatch = @[path];
    
    self.eventStream = FSEventStreamCreate(NULL,
                                           &fsEventsCallback,
                                           &context,
                                           (__bridge CFArrayRef)(pathsToWatch),
                                           kFSEventStreamEventIdSinceNow,
                                           0.1,
                                           kFSEventStreamCreateFlagFileEvents
                                           );
    
    FSEventStreamScheduleWithRunLoop(self.eventStream, CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(self.eventStream);
}

@end