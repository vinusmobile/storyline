//
//  WebImageView.m
//  storyline
//
//  Created by Jimmy Xu on 11/7/16.
//  Copyright © 2016 Storyline. All rights reserved.
//

#import "WebImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WebImageView () {
    
    BOOL isThumbnail;
}

@end

@implementation WebImageView

-(void)loadImageForURL:(NSString*) url {
    if (!url || [url isEqual:[NSNull null]] || ![url hasPrefix:@"http"]) {
        _url = nil;
        return;
    }
    
    NSURL *aUrl = [NSURL URLWithString:url];
    NSString *pathComponent = [aUrl path];
    NSString *extension = [pathComponent pathExtension];
    NSString *thumbnailPath = isThumbnail ? @"_thumbnail":@"";
    
    NSString *modifiedExtension = [NSString stringWithFormat:@"%@.%@", thumbnailPath, extension];
    pathComponent = [pathComponent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", extension] withString:modifiedExtension];
    if(!pathComponent) {
        _url = nil;
        return;
    }
    _url = [[NSURL alloc] initWithScheme:[aUrl scheme] host:[aUrl host] path:pathComponent];
    __weak WebImageView *weakself = self;
    
    [self sd_setImageWithURL:_url placeholderImage:nil options:(SDWebImageHighPriority | SDWebImageAvoidAutoSetImage | SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //        if(!isThumbnail && receivedSize != expectedSize) {
        //            [loaderView setCurrent:receivedSize max:expectedSize];
        //            loaderView.hidden = NO;
        //        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //        loaderView.hidden = YES;
        if(image && [weakself.url isEqual:imageURL]) {
            weakself.image = image;
        }
    }];
    
    [self sd_setImageWithURL:_url];
}

- (void)stopLoadingImage {
    _url = nil;
    //    loaderView.hidden = YES;
}

@end
