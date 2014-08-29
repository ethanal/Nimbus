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

static NSMutableSet *uploadedFilenames;

@implementation ScreenshotWatcher

- (instancetype)initWithUploadFileCallback:(FileCallbackBlock) callback {
    self = [super init];
    if (self) {
        if (uploadedFilenames == nil) {
            uploadedFilenames = [NSMutableSet new];
        }
        
        self.uploadCallback = callback;
    }
    return self;
}

void describeFSEvent(FSEventStreamEventFlags eventFlags) {
    // if (eventFlags & kFSEventStreamEventFlagNone)               printf("None\t");
    if (eventFlags & kFSEventStreamEventFlagMustScanSubDirs)    printf("MustScanSubDirs\t");
    if (eventFlags & kFSEventStreamEventFlagUserDropped)        printf("UserDropped\t");
    if (eventFlags & kFSEventStreamEventFlagKernelDropped)      printf("KernelDropped\t");
    if (eventFlags & kFSEventStreamEventFlagEventIdsWrapped)    printf("EventIdsWrapped\t");
    if (eventFlags & kFSEventStreamEventFlagHistoryDone)        printf("HistoryDone\t");
    if (eventFlags & kFSEventStreamEventFlagRootChanged)        printf("RootChanged\t");
    if (eventFlags & kFSEventStreamEventFlagMount)              printf("Mount\t");
    if (eventFlags & kFSEventStreamEventFlagUnmount)            printf("Unmount\t");
    if (eventFlags & kFSEventStreamEventFlagItemCreated)        printf("ItemCreated\t");
    if (eventFlags & kFSEventStreamEventFlagItemRemoved)        printf("ItemRemoved\t");
    if (eventFlags & kFSEventStreamEventFlagItemInodeMetaMod)   printf("ItemInodeMetaMod\t");
    if (eventFlags & kFSEventStreamEventFlagItemRenamed)        printf("ItemRenamed\t");
    if (eventFlags & kFSEventStreamEventFlagItemModified)       printf("ItemModified\t");
    if (eventFlags & kFSEventStreamEventFlagItemFinderInfoMod)  printf("ItemFinderInfoMod\t");
    if (eventFlags & kFSEventStreamEventFlagItemChangeOwner)    printf("ItemChangeOwner\t");
    if (eventFlags & kFSEventStreamEventFlagItemXattrMod)       printf("ItemXattrMod\t");
    if (eventFlags & kFSEventStreamEventFlagItemIsFile)         printf("ItemIsFile\t");
    if (eventFlags & kFSEventStreamEventFlagItemIsDir)          printf("ItemIsDir\t");
    if (eventFlags & kFSEventStreamEventFlagItemIsSymlink)      printf("ItemIsSymlink\t");
    printf("\n");
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
        
//        if (![fileURL.lastPathComponent hasPrefix:@"."]) {
//            printf("%s\t", [fileURL.lastPathComponent cStringUsingEncoding:NSUTF8StringEncoding]);
//            describeFSEvent(eventFlags[i]);
//        }
        
        if ((eventFlags[i] & kFSEventStreamEventFlagItemRenamed) &&
            (eventFlags[i] & kFSEventStreamEventFlagItemXattrMod) &&
            !([uploadedFilenames containsObject:path])) {
            
            if (![fileURL.lastPathComponent hasPrefix:@"."]) {
                NSMetadataItem *metadata = [[NSMetadataItem alloc] initWithURL:fileURL];
                if ([fileManager fileExistsAtPath:path]) {
                    BOOL isScreenshot = [[metadata valueForAttribute:@"kMDItemIsScreenCapture"] integerValue] == 1;
                    if (isScreenshot) {
//                        printf("Uploading %s\n", [fileURL.lastPathComponent cStringUsingEncoding:NSUTF8StringEncoding]);
                        NSData *fileData = [fileManager contentsAtPath:path];
                        ScreenshotWatcher *watcher = (__bridge ScreenshotWatcher*)info;
                        watcher.uploadCallback(fileData, path);
                        
                        [uploadedFilenames addObject:path];
                    }
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