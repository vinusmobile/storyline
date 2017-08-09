//
//  ResourceManager.m
//  storyline
//
//  Created by Jimmy Xu on 11/10/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "ResourceManager.h"
#import "ASIHTTPRequest.h"
#import <Crashlytics/Crashlytics.h>
#import "ZipArchive.h"
#import "DataManager.h"

#define DOWNLOAD_OVER_LOCAL true

static NSString* folderSuffix;
static NSArray* suffixedFolders;
static NSString* downloadPath;
static NSString *tmpDir = nil;

@interface ResourceManager () {
    NSOperationQueue* downloadQueue;
    NSOperationQueue* unzipQueue;
    NSMutableArray* requests;
}

@end


@implementation ResourceManager

-(id)init {
    self = [super init];
    if(self) {
        downloadQueue = [[NSOperationQueue alloc] init];
        downloadQueue.maxConcurrentOperationCount = 1;
        unzipQueue = [[NSOperationQueue alloc] init];
        //        unzipQueue.maxConcurrentOperationCount = 1;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        requests = [NSMutableArray array];
    }
    return self;
}

+ (ResourceManager*)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}


+(void) findPathForConversationID:(NSString*)conversationID complete:(FilePathCallbackType)completeBlock {
    NSString *partialPath = [NSString stringWithFormat:@"%@.json", conversationID];
    [ResourceManager findPathForResource:partialPath complete:completeBlock];
}

/* Gets the path for a given file name */
+(void) findPathForResource:(NSString*)fileName complete:(FilePathCallbackType)completeBlock {
    //first check download folder
    NSString* path = [self pathInDownloadDirectoryFor:fileName];
    
    //then check main bundle for it
    if(!path) {
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        if(!path) {
            NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", S3CDNPath, S3BucketName, fileName];
            [[ResourceManager sharedInstance] getAssetForURL:urlString fileName:fileName useCache:NO complete:^(BOOL success) {
                if(success) {
                    NSString *newPath = [self pathInDownloadDirectoryFor:fileName];
                    if(completeBlock) completeBlock(newPath);
                } else {
                    if(completeBlock) completeBlock(nil);
                }
            }];
        }
    }
    
    if(path && completeBlock) {
        completeBlock(path);
    }
}

- (BOOL)getAssetForURL:(NSString*)urlPath fileName:(NSString*)fileName useCache:(BOOL) useCache complete:(SuccessCallbackType)completeBlock {
    BOOL success;
    NSLog(@"Downloading %@",urlPath);
    BOOL isZip = [[urlPath pathExtension] isEqualToString:@"zip"];
    NSString* downloadPath;
    downloadPath = [[ResourceManager downloadDirectory] stringByAppendingPathComponent:fileName];
    NSLog(@"download path is %@",downloadPath);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
    __weak ASIHTTPRequest *weakRequest = request;
    __weak ResourceManager* weakSelf = self;
    @synchronized(requests) {
        [requests addObject:request];
    }
    [request setDownloadDestinationPath:downloadPath];
    [request setNumberOfTimesToRetryOnTimeout:5];
    if (useCache) {
        [request setTemporaryFileDownloadPath:[[ResourceManager tempDirectory] stringByAppendingPathComponent:fileName]];
        [request setAllowResumeForFileDownloads:YES];
        [request setDownloadProgressDelegate:self];
        [request setShowAccurateProgress:YES];
        [request setShouldContinueWhenAppEntersBackground:NO];
    }
    
    [request setCompletionBlock:^{
        [weakSelf removeRequest:weakRequest];
        [weakSelf unzipBlock:weakRequest completeBlock:completeBlock path:downloadPath filePath:[ResourceManager downloadDirectory] isZip:isZip];
    }];
    [request setFailedBlock:^{
        CLSLog(@"error downloading due to %@", [weakRequest error]);
        [weakSelf removeRequest:weakRequest];
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
    [request startAsynchronous];
    return YES;
}

-(void) unzipBlock:(ASIHTTPRequest*) request completeBlock:(SuccessCallbackType)completeBlock path:(NSString*)downloadPath filePath:(NSString*)filesystemPath isZip:(BOOL)isZip {
    
    BOOL unzipSuccess = (request.error == nil);
    if (isZip && unzipSuccess) {
        unzipSuccess = [self unzipAsset:downloadPath toPath:filesystemPath];
    }
    if (completeBlock) {
        NSLog(@"complete status %d",unzipSuccess);
        completeBlock(unzipSuccess);
    }
    [self removeRequest:request];
    
}

-(void) removeRequest:(id) request {
    if (request) {
        [requests removeObject:request];
    }
}

- (BOOL)unzipAsset:(NSString*)path toPath:(NSString*)storePath {
    NSLog(@"Unzipping %@ to %@", path, storePath);
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile:path]) {
        BOOL ret = [za UnzipFileTo:storePath overWrite:YES];
        [za UnzipCloseFile];
        if (ret) {
            NSLog(@"finished unzip");
            [self removeAsset:path];
            return YES;
        }
        else {
            NSLog(@"problem unzipping files at path %@",path);
            return NO;
        }
        
    } else {
        NSLog(@"couldn't open zip file at path %@",path);
        return NO;
    }
}

- (void)removeAsset:(NSString*)path {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    return;
}


+ (NSString*)cacheDirectory {
    NSString* myBid = [[NSBundle mainBundle] bundleIdentifier];
    NSString* cacheDir = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/%@", myBid]];
    BOOL isDir = NO;
    NSError *err = nil;
    BOOL createDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir isDirectory:&isDir]) {
        // the path does not exist so create
        createDirectory = YES;
    } else if (!isDir) {
        // the path exists but its not a directory so I'm just going to delete it and then create a directory
        if (![[NSFileManager defaultManager] removeItemAtPath:cacheDir error:&err]) {
            NSLog(@"Error: Could not erase cache file where a directory was supposed to be! %@", err);
            return nil;
        }
        createDirectory = YES;
    }
    
    if (createDirectory) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:&err]) {
            NSLog(@"Error: Could not create cache directory! %@", err);
            return nil;
        }
    }
    return cacheDir;
}

+ (NSString*) tempDirectory {
    if (tmpDir) {
        return tmpDir;
    }
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp%@",[DataManager buildVersion]]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    tmpDir = path;
    return path;
}


+ (NSString*) downloadDirectory {
    if (!downloadPath) {
        downloadPath = [self cacheDirectory];
    }
    return downloadPath;
}

/* Looks for the file in the download directory */
+(NSString*) pathInDownloadDirectoryFor:(NSString*)fileName {
    NSString* path = [[self downloadDirectory] stringByAppendingPathComponent:fileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = nil;
    }
    return path;
}


@end
