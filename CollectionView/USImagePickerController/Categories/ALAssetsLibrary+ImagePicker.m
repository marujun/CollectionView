//
//  ALAssetsLibrary+ImagePicker.m
//  CollectionView
//
//  Created by marujun on 16/8/16.
//  Copyright © 2016年 marujun. All rights reserved.
//

#import "ALAssetsLibrary+ImagePicker.h"

@implementation ALAssetsLibrary (ImagePicker)

- (void)writeImage:(UIImage *)image toAlbum:(NSString *)toAlbum completionHandler:(void (^)(ALAsset *asset, NSError *error))completionHandler
{
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL* assetURL, NSError* error) {
        if (error!=nil) {
            if(completionHandler) {
                completionHandler(nil, error);
            }
            
            return;
        }
        
        [self addAssetURL:assetURL toAlbum:toAlbum completionHandler:completionHandler];
    }];
}

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)toAlbum completionHandler:(void (^)(ALAsset *asset, NSError *error))completionHandler
{
    __block BOOL albumWasFound = NO;
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            if ([toAlbum compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                
                                albumWasFound = YES;
                                [self assetForURL:assetURL
                                      resultBlock:^(ALAsset *asset) {
                                          [group addAsset:asset];
                                          
                                          if(completionHandler) completionHandler(asset, nil);
                                          
                                      } failureBlock:^(NSError *error) {
                                          if(completionHandler) completionHandler(nil, error);
                                      }];
                                
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                
                                __weak typeof(self) wself = self;
                                
                                [self addAssetsGroupAlbumWithName:toAlbum
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                          [wself assetForURL: assetURL
                                                                 resultBlock:^(ALAsset *asset) {
                                                                     [group addAsset: asset];
                                                                     
                                                                     if(completionHandler) completionHandler(asset, nil);
                                                                     
                                                                 } failureBlock:^(NSError *error) {
                                                                     if(completionHandler) completionHandler(nil, error);
                                                                 }];
                                                      }
                                                     failureBlock:^(NSError *error) {
                                                         if(completionHandler) completionHandler(nil, error);
                                                     }];
                                return;
                            }
                            
                        } failureBlock:^(NSError *error) {
                            if(completionHandler) completionHandler(nil, error);
                        }];
}

@end