//
//  GAsset.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/8/13.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GAsset.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "GAssetsManager.h"
#import "UIImage+GDoris.h"
static NSString * const kAssetInfoImageData = @"imageData";
static NSString * const kAssetInfoOriginInfo = @"originInfo";
static NSString * const kAssetInfoDataUTI = @"dataUTI";
static NSString * const kAssetInfoOrientation = @"orientation";
static NSString * const kAssetInfoSize = @"size";

#define GAsset_WIDTH [[UIScreen mainScreen] bounds].size.width
#define GAsset_HEIGHT [[UIScreen mainScreen] bounds].size.height
@interface  GAsset ()

@property (nonatomic, copy) NSDictionary *phAssetInfo;
@property (nonatomic, assign) CGSize  imageSize;

@property (nonatomic, copy  ) NSString * privateId;
@end

@implementation  GAsset {
    PHAsset *_phAsset;
    //    float imageSize;
}

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _assetType = GAssetTypeImage;
        self.editerImage = image;
        _assetSubType =  GAssetSubTypeImage;
        _imageSize = image.size;
        int64_t localId = [[NSDate date]  timeIntervalSince1970] * 1000;
        self.privateId = [NSString stringWithFormat:@"local_%lld",localId];
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)phAsset {
    if (self = [super init]) {
        _phAsset = phAsset;
        switch (phAsset.mediaType) {
            case PHAssetMediaTypeImage:
                _assetType =  GAssetTypeImage;
                if ([[phAsset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    _assetSubType =  GAssetSubTypeGIF;
                } else {
                    if (@available(iOS 9.1, *)) {
                        if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                            _assetSubType =  GAssetSubTypeLivePhoto;
                        } else {
                            _assetSubType =  GAssetSubTypeImage;
                        }
                    } else {
                        _assetSubType =  GAssetSubTypeImage;
                    }
                }
                break;
            case PHAssetMediaTypeVideo:
                _assetType =  GAssetTypeVideo;
                break;
            case PHAssetMediaTypeAudio:
                _assetType =  GAssetTypeAudio;
                break;
            default:
                _assetType =  GAssetTypeUnknow;
                break;
        }
        _imageSize =  CGSizeMake(_phAsset.pixelWidth, _phAsset.pixelHeight);
    }
    return self;
}

- (PHAsset *)phAsset {
    return _phAsset;
}

- (UIImage *)originImage {
    __block UIImage *resultImage = nil;

    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    phImageRequestOptions.synchronous = YES;
    phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[[GAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
                                                                        targetSize:CGSizeMake(_phAsset.pixelWidth, _phAsset.pixelHeight)
                                                                       contentMode:PHImageContentModeDefault
                                                                           options:phImageRequestOptions
                                                                     resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                         resultImage = result;
                                                                     }];
    if (!resultImage) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        phImageRequestOptions.networkAccessAllowed = YES;
        phImageRequestOptions.synchronous = YES;
        [[[GAssetsManager sharedInstance] phCachingImageManager] requestImageDataForAsset:_phAsset options:phImageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            resultImage = [UIImage imageWithData:imageData];
        }];
        if (resultImage == nil) {//针对视频取不到原图的情况进行处理
            resultImage = [self previewImage];
        }
    }
    return resultImage;
}

- (UIImage *)thumbnailWithSize:(CGSize)size
{
    CGSize tzsize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (size.width && !isnan(size.width) && size.height && isnan(size.height)) {
        tzsize = size;
    }
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    phImageRequestOptions.networkAccessAllowed = YES;
    phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    __block UIImage * resultImage = nil;
    [[[GAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
                                                                        targetSize:CGSizeMake(tzsize.width * [[UIScreen mainScreen] scale], tzsize.height * [[UIScreen mainScreen] scale])
                                                                       contentMode:PHImageContentModeAspectFill options:phImageRequestOptions
                                                                     resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                         if (result) {
                                                                             resultImage = result;
                                                                         }
                                                                     }];
    return resultImage;
}

- (UIImage *)previewImage {
    __block UIImage *resultImage = nil;
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES;
    imageRequestOptions.synchronous = YES;
    [[[ GAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
                                                                         targetSize:CGSizeMake(GAsset_WIDTH, GAsset_HEIGHT)
                                                                        contentMode:PHImageContentModeAspectFill
                                                                            options:imageRequestOptions
                                                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                          resultImage = result;
                                                                      }];
    if (resultImage == nil) {//针对视频没有预览图的情况进行处理
        CGFloat ScreenScale = [[UIScreen mainScreen] scale];
        resultImage = [self thumbnailWithSize:CGSizeMake(_phAsset.pixelWidth/ScreenScale, _phAsset.pixelHeight/ScreenScale)];
    }
    
    if (resultImage == nil) {//如果视频取大缩略图失败、重新尝试取小缩略图
        resultImage = [self thumbnailWithSize:CGSizeMake(100, 100)];
    }
    return resultImage;
}

- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    imageRequestOptions.progressHandler = phProgressHandler;
    return [[[ GAssetsManager sharedInstance] phCachingImageManager] requestImageDataForAsset:_phAsset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completion) {
            completion([UIImage imageWithData:imageData], info);
        }
    }];
}

- (NSInteger)requestOriginImageDataWithCompletion:(void (^)(NSData *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    imageRequestOptions.progressHandler = phProgressHandler;
    return [[[ GAssetsManager sharedInstance] phCachingImageManager] requestImageDataForAsset:_phAsset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (completion) {
            completion(imageData, info);
        }
    }];
}

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    imageRequestOptions.networkAccessAllowed = YES;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    return [[[ GAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(size.width * [[UIScreen mainScreen] nativeScale], size.height * [[UIScreen mainScreen] nativeScale]) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (completion) {
            completion(result, info);
        }
    }];
}

- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    imageRequestOptions.progressHandler = phProgressHandler;
    return [[[ GAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (completion) {
            completion(result, info);
        }
    }];
}

- (NSInteger)requestLivePhotoWithCompletion:(void (^)(PHLivePhoto *livePhoto, NSDictionary<NSString *, id> *info))completion  withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler NS_AVAILABLE_IOS(9_1) {
    if ([[PHCachingImageManager class] instancesRespondToSelector:@selector(requestLivePhotoForAsset:targetSize:contentMode:options:resultHandler:)]) {
        PHLivePhotoRequestOptions *livePhotoRequestOptions = [[PHLivePhotoRequestOptions alloc] init];
        livePhotoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        livePhotoRequestOptions.progressHandler = phProgressHandler;
        return [[[ GAssetsManager sharedInstance] phCachingImageManager] requestLivePhotoForAsset:_phAsset targetSize:CGSizeMake(GAsset_WIDTH, GAsset_HEIGHT) contentMode:PHImageContentModeDefault options:livePhotoRequestOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            if (completion) {
                completion(livePhoto, info);
            }
        }];
    } else {
        if (completion) {
            completion(nil, nil);
        }
        return 0;
    }
}

- (NSInteger)requestPlayerItemWithCompletion:(void (^)(AVPlayerItem *playerItem, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetVideoProgressHandler)phProgressHandler {
    if ([[PHCachingImageManager class] instancesRespondToSelector:@selector(requestPlayerItemForVideo:options:resultHandler:)]) {
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        videoRequestOptions.progressHandler = phProgressHandler;
        return [[[ GAssetsManager sharedInstance] phCachingImageManager] requestPlayerItemForVideo:_phAsset options:videoRequestOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion) {
                completion(playerItem, info);
            }
        }];
    } else {
        if (completion) {
            completion(nil, nil);
        }
        return 0;
    }
}

- (void)requestImageData:(void (^)(NSData *imageData, NSDictionary<NSString *, id> *info, BOOL isGIF, BOOL isHEIC))completion {
    if (self.assetType !=  GAssetTypeImage) {
        if (completion) {
            completion(nil, nil, NO, NO);
        }
        return;
    }
    __weak __typeof(self)weakSelf = self;
    if (!self.phAssetInfo) {
        // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
        [self requestPhAssetInfo:^(NSDictionary *phAssetInfo) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.phAssetInfo = phAssetInfo;
            if (completion) {
                NSString *dataUTI = phAssetInfo[kAssetInfoDataUTI];
                BOOL isGIF = self.assetSubType ==  GAssetSubTypeGIF;
                BOOL isHEIC = [dataUTI isEqualToString:@"public.heic"];
                NSDictionary<NSString *, id> *originInfo = phAssetInfo[kAssetInfoOriginInfo];
                if (isGIF) {
                    completion(phAssetInfo[kAssetInfoImageData], originInfo, isGIF, isHEIC);
                } else {
                    UIImage *oldImage = [UIImage imageWithData:phAssetInfo[kAssetInfoImageData]];
                    UIImage *newImage = [UIImage imageWithCGImage:oldImage.CGImage
                                                            scale:1
                                                      orientation:(UIImageOrientation)[strongSelf.phAssetInfo[kAssetInfoOrientation] integerValue]];
                    UIImage *newFixImage = [newImage g_fixOrientation];
                    NSData *newImageData = UIImageJPEGRepresentation(newFixImage, 0.75);
                    completion(newImageData, originInfo, isGIF,isHEIC);
                    /* todo by GIKI
                    @autoreleasepool {
                        UIImage *oldImage = [UIImage imageWithData:phAssetInfo[kAssetInfoImageData]];
                        if (!oldImage) oldImage = [strongSelf previewImage];
                        
                        if (!oldImage) {
                            completion(nil, originInfo, isGIF, isHEIC);
                            return;
                        }
                        
                        UIImage *newFixImage = [oldImage fixOrientation];
                        newFixImage = [newFixImage custromCompressImageWithMaxWidth:newFixImage.size.width maxLength:20*1024*1024];
                        NSData *newImageData = [UIImage dataFromImage:newFixImage];
                        completion(newImageData, originInfo, isGif);
                        if (newImageData == nil) {
//                            NSString *log = [NSString stringWithFormat:@"sourcePath is %@,oldImage is %@,newFixImage is %@ ,phAssetInfo is %@",self.sourcePath,oldImage,newFixImage,phAssetInfo];
//                            [[ZYRuntimeLogManager shareRuntimeLogManager] reportRunTimeLog:log customKey:IMAGE_UPLOAD_ERROR_IMAGE_DATA_NIL_REPORT];
                        }
                        if (newImageData && newImageData.length > 20*1024*1024) {
//                            NSString *log = [NSString stringWithFormat:@"new image data length = %lu, original image data length = %lld",newImageData.length,[_phAssetInfo[kAssetInfoSize] longLongValue]];
//                            [[ZYRuntimeLogManager shareRuntimeLogManager] reportRunTimeLog:log customKey:IMAGE_UPLOAD_ERROR_IMAGE_DATA_LENGTH_REPORT];
                        }
                    }
                    */
                }
            }
        }];
    } else {
        if (completion) {
            NSString *dataUTI = self.phAssetInfo[kAssetInfoDataUTI];
            BOOL isGIF = self.assetSubType ==  GAssetSubTypeGIF;
            BOOL isHEIC = [@"public.heic" isEqualToString:dataUTI];
            NSDictionary<NSString *, id> *originInfo = self.phAssetInfo[kAssetInfoOriginInfo];
            if (isGIF) {
                completion(self.phAssetInfo[kAssetInfoImageData], originInfo, isGIF, isHEIC);
            } else {
                UIImage *oldImage = [UIImage imageWithData:self.phAssetInfo[kAssetInfoImageData]];
                UIImage *newImage = [UIImage imageWithCGImage:oldImage.CGImage
                                                        scale:1
                                                  orientation:(UIImageOrientation)[self.phAssetInfo[kAssetInfoOrientation] integerValue]];
                UIImage *newFixImage = [newImage g_fixOrientation];
                NSData *newImageData = UIImageJPEGRepresentation(newFixImage, 0.75);
                completion(newImageData, originInfo, isGIF,isHEIC);
            }
        }
    }
}


- (UIImageOrientation)imageOrientation {
    UIImageOrientation orientation;
    if (self.assetType ==  GAssetTypeImage) {
        if (!self.phAssetInfo) {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            __weak __typeof(self)weakSelf = self;
            [self requestImagePhAssetInfo:^(NSDictionary *phAssetInfo) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.phAssetInfo = phAssetInfo;
            } synchronous:YES];
        }
        // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
        orientation = (UIImageOrientation)[self.phAssetInfo[kAssetInfoOrientation] integerValue];
    } else {
        orientation = UIImageOrientationUp;
    }
    return orientation;
}

- (NSString *)identifier {
    if (_phAsset.localIdentifier) {
        return _phAsset.localIdentifier;
    }
    if (self.privateId.length > 0) {
        return self.privateId;
    }
    return _phAsset.localIdentifier;
}

- (void)requestPhAssetInfo:(void (^)(NSDictionary *))completion {
    if (!_phAsset) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    if (self.assetType ==  GAssetTypeVideo) {
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.networkAccessAllowed = YES;
        [[[ GAssetsManager sharedInstance] phCachingImageManager] requestAVAssetForVideo:_phAsset options:videoRequestOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
                if (info) {
                    [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
                }
                AVURLAsset *urlAsset = (AVURLAsset*)asset;
                NSNumber *size;
                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                [tempInfo setObject:size forKey:kAssetInfoSize];
                if (completion) {
                    completion(tempInfo);
                }
            }
        }];
    } else {
        [self requestImagePhAssetInfo:^(NSDictionary *phAssetInfo) {
            if (completion) {
                completion(phAssetInfo);
            }
        } synchronous:NO];
    }
}

- (void)requestImagePhAssetInfo:(void (^)(NSDictionary *))completion synchronous:(BOOL)synchronous {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = synchronous;
    imageRequestOptions.networkAccessAllowed = YES;
    
    [[[GAssetsManager sharedInstance] phCachingImageManager] requestImageDataForAsset:_phAsset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (info) {
            NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
            if (imageData) {
                [tempInfo setObject:imageData forKey:kAssetInfoImageData];
                [tempInfo setObject:@(imageData.length) forKey:kAssetInfoSize];
            }
            [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
            if (dataUTI) {
                [tempInfo setObject:dataUTI forKey:kAssetInfoDataUTI];
            }
            [tempInfo setObject:@(orientation) forKey:kAssetInfoOrientation];
            if (completion) {
                completion(tempInfo);
            }
        }
    }];
}

- (void)requestVideoURL:(void (^)(NSURL *fileUrl))completion
{
    if (completion == nil) {
        return;
    }
    if (self.assetType != GAssetTypeVideo) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSString *fileName = @"PHAssetVideo.mov";
    
    __weak __typeof(self)weakSelf = self;
    {
        NSArray *assetResources = [PHAssetResource assetResourcesForAsset:_phAsset];
        PHAssetResource *resource;
        
        for (PHAssetResource *assetRes in assetResources) {
            if (assetRes.type == PHAssetResourceTypeVideo ||
                assetRes.type == PHAssetResourceTypePairedVideo) {
                resource = assetRes;
            }
        }
//        NSString *fileName = @"PHAssetVideo.mp4";
        if (resource.originalFilename) {
            fileName = resource.originalFilename;
        }
        if (_phAsset.mediaType == PHAssetMediaTypeVideo || _phAsset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = YES;
            NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
            [[PHImageManager defaultManager] requestExportSessionForVideo:_phAsset options:options exportPreset:AVAssetExportPreset960x540 resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                NSString *savePath = PATH_MOVIE_FILE;
                exportSession.outputURL = [NSURL fileURLWithPath:savePath];
                exportSession.shouldOptimizeForNetworkUse = NO;
                exportSession.outputFileType = AVFileTypeMPEG4;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    switch ([exportSession status]) {
                        case AVAssetExportSessionStatusCompleted:
                        {
                            NSURL * fileurl = [NSURL fileURLWithPath:PATH_MOVIE_FILE];
                            completion(fileurl);
                            break;
                        }
                        case AVAssetExportSessionStatusFailed:
                        case AVAssetExportSessionStatusCancelled:
                        default:
                        {
                            [weakSelf subRequestVideoURL:completion];
                            break;
                        }
                    }
                }];
            }];
        } else {
            completion(nil);
        }
    }
}

- (void)subRequestVideoURL:(void (^)(NSURL *fileUrl))completion
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = true;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:_phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        NSString *filePath = [info valueForKey:@"PHImageFileSandboxExtensionTokenKey"];
        if (filePath && filePath.length > 0) {
            NSArray *lyricArr = [filePath componentsSeparatedByString:@";"];
            NSString *privatePath = [lyricArr lastObject];
            if (privatePath.length > 8) {
                NSString *videoPath = [privatePath substringFromIndex:8];
                NSURL *url = [NSURL fileURLWithPath:videoPath];
                completion(url);
                if (url == nil) {
                    
                }
            }else{
                completion(nil);
            }
        } else if ([asset isKindOfClass:[AVURLAsset class]]){
            NSURL *fileUrl = ((AVURLAsset *)asset).URL;
            completion(fileUrl);
            if (fileUrl == nil) {
                
            }
        } else {
            completion(nil);
        }
    }];
}

- (void)setDownloadProgress:(double)downloadProgress {
    _downloadProgress = downloadProgress;
    _downloadStatus =  GAssetDownloadStatusDownloading;
}

- (void)updateDownloadStatusWithDownloadResult:(BOOL)succeed {
    _downloadStatus = succeed ?  GAssetDownloadStatusSucceed :  GAssetDownloadStatusFailed;
}

- (void)assetSize:(void (^)(long long size))completion {
    if (!self.phAssetInfo) {
        // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
        __weak __typeof(self)weakSelf = self;
        [self requestPhAssetInfo:^(NSDictionary *phAssetInfo) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.phAssetInfo = phAssetInfo;
            if (completion) {
                /**
                 *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                 *  为了避免这种情况，这里该 block 主动放到主线程执行。
                 */
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([phAssetInfo[kAssetInfoSize] longLongValue]);
                });
            }
        }];
    } else {
        if (completion) {
            completion([self.phAssetInfo[kAssetInfoSize] longLongValue]);
        }
    }
}

- (NSTimeInterval)duration {
    if (self.assetType !=  GAssetTypeVideo) {
        return 0;
    }
    return _phAsset.duration;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    return [self.identifier isEqualToString:(( GAsset *)object).identifier];
}

- (BOOL)isLongImage
{
    return (_phAsset.pixelWidth > 0 && _phAsset.pixelHeight / _phAsset.pixelWidth > 2.5f);
}

#pragma mark - Export Video / 导出视频
/// Export Video / 导出视频
- (void)exportVideoOutputPathSuccess:(void (^)(NSURL *fileUrl))success
                             failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    [self getVideoOutputPathWithPresetName:AVAssetExportPresetHighestQuality success:success failure:failure];
}

- (void)getVideoOutputPathWithPresetName:(NSString *)presetName success:(void (^)(NSURL *fileUrl))success failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:_phAsset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        if ([avasset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset *videoAsset = (AVURLAsset*)avasset;
            [self loadVideoDataToLocal:videoAsset.URL success:success failure:failure];
        } else if ([avasset isKindOfClass:[AVComposition class]]){
            //Output URL of the slow motion file.
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = paths.firstObject;
            NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeSlowMoVideo-%d.mov",arc4random() % 1000]];
            NSURL *url = [NSURL fileURLWithPath:myPathDocs];
            
            //Begin slow mo video export
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:avasset presetName:AVAssetExportPresetHighestQuality];
            exporter.outputURL = url;
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (exporter.status == AVAssetExportSessionStatusCompleted) {
                        NSURL *URL = exporter.outputURL;
                        [self loadVideoDataToLocal:URL success:^(NSURL *fileUrl) {
                            if (success) success(fileUrl);
                            if ([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs]) {
                                [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
                            }
                        } failure:^(NSString *errorMessage, NSError *error) {
                            if (failure) failure(errorMessage, error);
                            if ([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs]) {
                                [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
                            }
                        }];
                        
                    }
                });
            }];

        }
      
    }];
}

- (void)loadVideoDataToLocal:(NSURL *)videoUrl success:(void (^)(NSURL *fileUrl))success failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingString:@"output-video.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }
    NSData *data = [NSData dataWithContentsOfURL:videoUrl];
    [data writeToURL:[NSURL fileURLWithPath:outputPath] atomically:YES];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        if (success) {
            success([NSURL fileURLWithPath:outputPath]);
        }
    } else {
        if (failure) {
            failure(@"导出失败，请重新尝试", nil);
        }
    }
}


@end
