//
//  MJCacheManager.m
//  Common
//
//  Created by 黄磊 on 16/4/6.
//  Copyright © 2016年 Musjoy. All rights reserved.
//

#import "MJCacheManager.h"
#import "MJWebService.h"
#ifdef MODULE_FILE_SOURCE
#import "FileSource.h"
#else
static NSMutableDictionary *s_localPaths = nil;
#endif
#ifdef MODULE_UTILS
#import "NSString+Utils.h"
#else
#import <CommonCrypto/CommonDigest.h>
#endif

static MJCacheManager *s_cacheManager = nil;



@interface MJCacheManager ()

@property (nonatomic, strong) NSCache *cacheData;

@property (nonatomic, strong) NSMutableDictionary *dicForRequest;

@end


@implementation MJCacheManager

// 获取缓存单例
+ (MJCacheManager *)sharedInstance
{
    if (s_cacheManager == nil)
    {
        s_cacheManager = [[MJCacheManager alloc] init];
    }
    return s_cacheManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dicForRequest = [[NSMutableDictionary alloc] init];
        self.cacheData = [[NSCache alloc] init];
    }
    return self;
}


#pragma mark - Public

+ (BOOL)canFetchImage
{
    AFNetworkReachabilityStatus theReachableState = [MJWebService reachableState];
    if (theReachableState == AFNetworkReachabilityStatusReachableViaWiFi) {
        return YES;
    } else if (theReachableState == AFNetworkReachabilityStatusNotReachable) {
        return NO;
    } else {
        return ![[self sharedInstance] fetchImageOnlyOnWifi];
    }
}

+ (NSObject *)getLocalFileWithUrl:(NSString *)fileUrl fileType:(CacheFileType)fileType completion:(MJCacheManagerBlock)completion
{
    return [[MJCacheManager sharedInstance] getLocalFileWithUrl:fileUrl fileType:fileType completion:completion];
}


+ (BOOL)getFileWithUrl:(NSString *)fileUrl
              fileType:(CacheFileType)fileType
              useCache:(UseCacheType)useCache
            completion:(MJCacheManagerBlock)completion
{
    return [MJCacheManager getFileWithUrl:fileUrl fileType:fileType useCache:useCache completion:completion progressBlock:nil];
}

+ (BOOL)getFileWithUrl:(NSString *)fileUrl
              fileType:(CacheFileType)fileType
              useCache:(UseCacheType)useCache
            completion:(MJCacheManagerBlock)completion
         progressBlock:(void (^)(float, long long, long long))progressBlock
{
    return [[MJCacheManager sharedInstance] getFileWithUrl:fileUrl fileType:fileType useCache:useCache completion:completion progressBlock:progressBlock];
}

+ (void)reloadFileWith:(NSString *)fileUrl fileType:(CacheFileType)fileType completion:(MJCacheManagerBlock)completion
{
    NSString *fileName = [self fileNameWithUrl:fileUrl];
    
    [[MJCacheManager sharedInstance] fetchFileWith:fileUrl locFileName:fileName fileType:fileType completion:completion progressBlock:nil];
}

/**
 *	@brief	刷新对应url的缓存，仅从本地文件读取到NSCache
 *
 *	@param 	fileUrl 	需要刷新缓存的url
 *	@param 	fileType 	需要刷新缓存的文件类型
 *
 *	@return	null
 */
+ (void)refreshCacheWith:(NSString *)fileUrl fileType:(CacheFileType)fileType

{
    NSString *fileName = [self fileNameWithUrl:fileUrl];
    NSString *keyData = [NSString stringWithFormat:@"%@_%d_Data", fileName, fileType];
    MJCacheManager *theCacheManager = [MJCacheManager sharedInstance];
    NSObject *data = nil;
    if (fileType == eCacheFileImage) {
        // 从文件中读取图片或头像缓存
        NSString *localFilePath = [theCacheManager locFilePathWith:fileName andFileType:fileType];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
            data = [UIImage imageWithContentsOfFile:localFilePath];
        }
    }
    // 更新缓存，这里即使本地文件未读取到内容也需要删除缓存
    [theCacheManager.cacheData removeObjectForKey:keyData];
    if (data) {
        [theCacheManager.cacheData setObject:data forKey:keyData];
    }
}


+ (NSString *)fileNameWithUrl:(NSString *)fileUrl
{
    // 使用不加参数的url，以便转化成md5的文件名
    //    NSString *shortUrl = [[fileUrl componentsSeparatedByString:@"?"] objectAtIndex:0];
    NSString *shortUrl = fileUrl;
#ifdef MODULE_UTILS
    return shortUrl.md5;
#else
    return [self md5:shortUrl];
#endif
}

#ifndef MODULE_UTILS
+ (NSString *)md5:(NSString *)theStr
{
    if (self == nil || theStr.length == 0) {
        return @"";
    }
    const char* str = [theStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];   // md5加密字串转大写
    }
    return ret;
}
#endif

#pragma mark - Private

- (NSObject *)getLocalFileWithUrl:(NSString *)fileUrl fileType:(CacheFileType)fileType completion:(MJCacheManagerBlock)completion
{
    // 远程的url为空或空字符串的话，直接返回
    if (fileUrl == nil || [fileUrl isEqualToString:@""]) {
        LogError(@"the fileUrl should not be nil!");
        completion(NO, @"远程文件路径不能为空成功", nil);
        return nil;
    }
    
    // 空值保护
    if (completion == NULL) {
        completion = ^(BOOL isSucceed, NSString *message, NSObject *image) {};
    }
    
    // 本地文件名，取md5
    NSString *fileName = [self.class fileNameWithUrl:fileUrl];;
    
    // 判断NSCache中是否有缓存
    NSObject *dataReturn = [self checkCache:fileName withFileType:fileType];
    
    if (dataReturn) {
        return dataReturn;
    }
    
    
    // 没有找到缓存或不是用缓存的话，从服务器获取文件
    [self fetchFileWith:fileUrl
            locFileName:fileName
               fileType:fileType
             completion:completion
          progressBlock:nil];
    
    return nil;
}


/**
 *	@brief	从缓存或网络上获取所需要的文件，如果是从网络获取，会有获取进度回调
 *
 *	@param 	fileUrl         需要获取文件的网络url
 *	@param 	fileType        需要获取的文件类型
 *	@param 	useCache        使用缓存的形式，请查看 UseCacheType
 *	@param 	completion      从网络获取完成的回调
 *	@param 	progressBlock 	获取进度回调
 *
 *	@return	是否已使用缓存数据，YES-是 NO-否
 */
- (BOOL)getFileWithUrl:(NSString *)fileUrl
              fileType:(CacheFileType)fileType
              useCache:(UseCacheType)useCache
            completion:(MJCacheManagerBlock)completion
         progressBlock:(void (^)(float, long long, long long))progressBlock

{
    // 远程的url为空或空字符串的话，直接返回
    if (fileUrl == nil || [fileUrl isEqualToString:@""]) {
        LogError(@"the fileUrl should not be nil!");
        completion(NO, @"远程文件路径不能为空成功", nil);
        return NO;
    }
    
    // 空值保护
    if (completion == NULL) {
        completion = ^(BOOL isSucceed, NSString *message, NSObject *image) {};
    }
    


    // 本地文件名，取md5
    NSString *fileName = [self.class fileNameWithUrl:fileUrl];;
    
    // 判断NSCache中是否有缓存
    NSObject *dataReturn = [self checkCache:fileName withFileType:fileType];
    
    if (dataReturn) {
        // 本地存在该文件，直接返回
        completion(YES, @"文件读取成功", dataReturn);
        // 如果设置不使用缓存的话，这里不能return
        if (useCache != eUseCacheNone) {
            return YES;
        }
        
    }
    
    // 如果仅使用缓存的话，这里直接返回
    if (useCache == eUseCacheOnly) {
        // 如果仅使用缓存的话，这里没取到也直接返回，返回值未NO
        return NO;
    }
    
//    // 判断文件类型和缓存机制
//    if (useCache != eUseCacheNone || fileType == eCacheFileImage || fileType == eCacheFileAvatar) {
//        // 使用缓存，或者获去图片文件
//        NSObject *dataReturn = [self checkCache:fileName withFileType:fileType];
//        if (dataReturn) {
//            if (fileType == eCacheFileImage || fileType == eCacheFileAvatar) {
//                // 找到缓存图片，先返回图片，这里即使是不使用缓存也要先返回，让界面可以显示
//                completion(YES, @"图片读取成功", dataReturn);
//                if (useCache != eUseCacheNone) {
//                    // 找到缓存，并且要使用缓存的话，直接返回
//                    return YES;
//                }
//            } else {
//                // 找到缓存，直接返回
//                completion(YES, @"文件读取成功", dataReturn);
//                return YES;
//            }
//        }
//    }
//    
//    if (useCache == eUseCacheOnly) {
//        // 如果仅使用缓存的话，这里没取到也直接返回，返回值未NO
//        return NO;
//    }
    
    // 没有找到缓存或不是用缓存的话，从服务器获取文件
    [self fetchFileWith:fileUrl
            locFileName:fileName
               fileType:fileType
             completion:completion
          progressBlock:progressBlock];
    
    return NO;
}


/**
 *	@brief	从网络获取对应文件
 *
 *	@param 	fileUrl         文件的远程url
 *	@param 	fileName        文件的本地名称
 *	@param 	fileType        文件的类型
 *	@param 	completion      完成的回调
 *	@param 	progressBlock 	进度回调
 *
 *	@return	void
 */
- (void)fetchFileWith:(NSString *)fileUrl
          locFileName:(NSString *)fileName
             fileType:(CacheFileType)fileType
           completion:(MJCacheManagerBlock)completion
        progressBlock:(void (^)(float, long long, long long))progressBlock

{
    
    // 空值保护
    if (progressBlock == NULL) {
        progressBlock = ^(float percent, long long bytesReaded, long long bytesNeedToRead) {};
    }
    
    // 将请求缓存在请求队列中
    NSString *key = [NSString stringWithFormat:@"%@_%d", fileName, fileType];
    NSDictionary *dic = @{@"completion": completion,@"progressBlock":progressBlock};
    NSMutableArray *arr = [_dicForRequest objectForKey:key];
    if (arr && arr.count > 0) {
        // 如果队列中有相同请求，加入同一队列后直接返回
        [arr addObject:dic];
        return;
    } else {
        // 如果队列中没有该请求，新建队列，保持该请求
        arr = [[NSMutableArray alloc] initWithObjects:dic, nil];
        [_dicForRequest setObject:arr forKey:key];
    }

    // 开始请求前的路径准备
    NSString *remoteFilePath = fileUrl;
    NSString *localFilePath = [self locFilePathWith:fileName andFileType:fileType];
    
    // 开始请求文件
    [MJWebService startDownload:remoteFilePath
                   withSavePath:localFilePath
                     completion:^(BOOL isSucceed, NSString *message)
     {
         NSObject *fileData = nil;
         if (isSucceed) {
             // 获取成功，准备本地文件
             fileData = [self dataWithLocalFile:localFilePath andFileType:fileType];
             
             if (fileData) {
                 // 如果能读取到文件，就返回该文件的数据，并将该文件缓存到NSCache中，以便下次快速使用
                 NSString *keyData = [NSString stringWithFormat:@"%@_%d_Data", fileName, fileType];
                 [_cacheData setObject:fileData forKey:keyData];
             }
             
         }
         // 开始请求完成回调
         for (NSDictionary *dic in arr) {
             MJCacheManagerBlock cacheBlockTmp = dic[@"completion"];
             if (cacheBlockTmp) {
                 if (isSucceed) {
                     cacheBlockTmp(isSucceed, message, fileData);
                 } else {
                     cacheBlockTmp(isSucceed, message, fileData);
                 }
                 
             }
         }
         // 从队列中清除该请求
         [arr removeAllObjects];
         [_dicForRequest removeObjectForKey:key];
    }
                  progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        // 获取进度回调，这里同一请求队列的都需要回调
        for (NSDictionary *dic in arr) {
            void (^blockTmp)(float, long long, long long) = dic[@"progressBlock"];
            if (blockTmp) {
                blockTmp((float)totalBytesRead / totalBytesExpectedToRead, totalBytesRead, totalBytesExpectedToRead);
            }
        }

    }];
    
}


/**
 *	@brief	检查本地是否存在对应文件
 *
 *	@param 	fileName 	要检查的文件名
 *	@param 	fileType 	要检查的文件类型
 *
 *	@return	检查结果会掉，YES-存在该文件，NO-不存在该文件
 */
- (NSObject *)checkCache:(NSString *)fileName withFileType:(CacheFileType)fileType

{
    // 生成对应key值，通过该key值来保存缓存
    NSObject *returnData = nil;
    NSString *keyData = [NSString stringWithFormat:@"%@_%d_Data", fileName, fileType];
    
    // 首先检查NSCache中是否缓存该文件
    returnData = [_cacheData objectForKey:keyData];
    if (returnData) {
        return returnData;
    }
    
    // NSCache中不存在，则检查本地文件是否存在
    NSString *localFilePath = [self locFilePathWith:fileName andFileType:fileType];
    returnData = [self dataWithLocalFile:localFilePath andFileType:fileType];

    return returnData;
}

/**
 *	@brief	根据文件名和文件类型得到本地文件路径
 *
 *	@param 	fileName 	文件名称
 *	@param 	fileType    文件类型
 *
 *	@return 返回文件路径
 */
- (NSString *)locFilePathWith:(NSString *)fileName andFileType:(CacheFileType)fileType

{
    NSString *folderPath = nil;
    // 根据不同文件类型返回不同路径
    switch (fileType) {
        case eCacheFileUndefined:
            folderPath = [self.class getLocalTempPath];
            break;
        case eCacheFileImage:
            folderPath = [self.class getLocalImagePath];
            break;
        case eCacheFileAudio:
            folderPath = [self.class getLocalAudioPath];
            break;
        case eCacheFileVideo:
            folderPath = [self.class getLocalVideoPath];
            break;
        default:
            folderPath = [self.class getLocalTempPath];
            break;
    }
    // 拼接文件路径并返回
    return [folderPath stringByAppendingPathComponent:fileName];
}

/**
 *	@brief	从本地获取文件
 *
 *	@param 	localFilePath 	本地文件路径
 *	@param 	fileType        本地文件类型
 *
 *	@return	能获取到本地数据则返回数据，不能则返回nil
 */
- (NSObject *)dataWithLocalFile:(NSString *)localFilePath andFileType:(CacheFileType)fileType

{
    NSObject *returnData = nil;
    NSFileManager *fileHandler = [NSFileManager defaultManager];
    if ([fileHandler fileExistsAtPath:localFilePath]) {
        // 文件存在
        if (fileType == eCacheFileImage) {
            // 如果是图片的话，直接读取图片文件
            returnData = [UIImage imageWithContentsOfFile:localFilePath];
        } else {
            // 其他文件类型，无法获取数据，直接放回对应路径
            returnData = [NSDictionary dictionaryWithObject:localFilePath forKey:@"filePath"];
        }
    }
    return returnData;
}


#pragma mark - File Path

#ifdef MODULE_FILE_SOURCE

+ (NSString *)getLocalImagePath
{
    return [FileSource getLocalFilePath:LOCAL_IMAGE_FOLDER_NAME];
}

+ (NSString *)getLocalAudioPath
{
    return [FileSource getLocalFilePath:LOCAL_AUDIO_FOLDER_NAME];
}

+ (NSString *)getLocalVideoPath
{
    return [FileSource getLocalFilePath:LOCAL_VIDEO_FOLDER_NAME];
}


+ (NSString *)getLocalTempPath
{
    return [FileSource getLocalFilePath:LOCAL_TEMP_FOLDER_NAME];
}

#else

+ (NSMutableDictionary *)localPaths
{
    if (s_localPaths == nil) {
        s_localPaths = [[NSMutableDictionary alloc] init];
    }
    return s_localPaths;
}

+ (NSString *)getLocalImagePath
{
    return [self getLocalFilePath:LOCAL_IMAGE_FOLDER_NAME];
}

+ (NSString *)getLocalAudioPath
{
    return [self getLocalFilePath:LOCAL_AUDIO_FOLDER_NAME];
}

+ (NSString *)getLocalVideoPath
{
    return [self getLocalFilePath:LOCAL_VIDEO_FOLDER_NAME];
}

+ (NSString *)getLocalTempPath
{
    return [self getLocalFilePath:LOCAL_TEMP_FOLDER_NAME];
}

+ (NSString *)getLocalFilePath:(NSString *)folderName
{
    NSString *aLocalPaths = [[self localPaths] objectForKey:folderName];
    if (aLocalPaths.length == 0) {
        NSError *error;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if(documentPaths.count > 0) {
            NSString *docpath = [documentPaths objectAtIndex:0];
            if(docpath) {
                docpath = [docpath stringByAppendingPathComponent:folderName];
                if(![[NSFileManager defaultManager] fileExistsAtPath:docpath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:docpath
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:&error];
                    if(error != nil) {
                        return nil; // Cannot create a directory
                    }
                }
                aLocalPaths = docpath;
                [[self localPaths] setObject:aLocalPaths forKey:folderName];
            }
        }
    }
    return aLocalPaths;
}

#endif

@end
