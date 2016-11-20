//
// Created by Mads Lee Jensen on 07/07/16.
// Copyright (c) 2016 Facebook. All rights reserved.
//

#import "RCTImageSequenceView.h"

@implementation RCTImageSequenceView {
    NSUInteger _framesPerSecond;
    NSMutableDictionary *_activeTasks;
    NSMutableDictionary *_imagesLoaded;
    BOOL _start;
}

- (void)setImages:(NSArray *)images {
    __weak RCTImageSequenceView *weakSelf = self;
    
    self.animationImages = nil;
    
    _activeTasks = [NSMutableDictionary new];
    _imagesLoaded = [NSMutableDictionary new];
    
    for (NSUInteger index = 0; index < images.count; index++) {
        NSDictionary *item = images[index];
        #ifdef DEBUG
        NSString *url = item[@"uri"];
        #else
        NSString *url = [NSString stringWithFormat:@"file://%@", item[@"uri"]]; // when not in debug, the paths are "local paths" (because resources are bundled in app)
        #endif
        
        dispatch_async(dispatch_queue_create("dk.mads-lee.ImageSequence.Downloader", NULL), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf onImageLoadTaskAtIndex:index image:image];
            });
        });
        
        _activeTasks[@(index)] = url;
    }
}

- (void)onImageLoadTaskAtIndex:(NSUInteger)index image:(UIImage *)image {
    if (index == 0) {
        self.image = image;
    }
    
    [_activeTasks removeObjectForKey:@(index)];
    
    _imagesLoaded[@(index)] = image;
    
    if (_activeTasks.allValues.count == 0) {
        [self onImagesLoaded];
    }
}

- (void)onImagesLoaded {
    NSMutableArray *images = [NSMutableArray new];
    for (NSUInteger index = 0; index < _imagesLoaded.allValues.count; index++) {
        UIImage *image = _imagesLoaded[@(index)];
        [images addObject:image];
    }
    
    [_imagesLoaded removeAllObjects];
    
    self.image = nil;
    self.animationDuration = images.count * (1.0f / _framesPerSecond);
    self.animationImages = images;
    self.image = self.animationImages[0];
    if (_start){
        self.image = [self.animationImages lastObject];
        [self startAnimating];
    }
}

- (void)setFramesPerSecond:(NSUInteger)framesPerSecond {
    _framesPerSecond = framesPerSecond;
    
    if (self.animationImages.count > 0) {
        self.animationDuration = self.animationImages.count * (1.0f / _framesPerSecond);
    }
}

- (void)setStart:(BOOL)start {
    _start = start;
    
    if (_start && self.animationImages.count > 0){
        self.image = [self.animationImages lastObject];
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)setOneShot:(BOOL)oneShot {
    if (oneShot){
        self.animationRepeatCount = 1;
    } else {
        self.animationRepeatCount = 0;
    }
}

@end
