//
//  MJCacheManager.h
//  Common
//
//  Created by 黄磊 on 16/4/6.
//  Copyright © 2016年 Musjoy. All rights reserved.
//  缓存管理<MODULE_CACHE_MANAGER>


#import <Foundation/Foundation.h>

/// 本地音频保存目录
#ifndef LOCAL_IMAGE_FOLDER_NAME
#define LOCAL_IMAGE_FOLDER_NAME     @"localImage"
#endif
/// 本地音频保存目录
#ifndef LOCAL_AUDIO_FOLDER_NAME
#define LOCAL_AUDIO_FOLDER_NAME     @"localAudio"
#endif
/// 本地视频保存目录
#ifndef LOCAL_VIDEO_FOLDER_NAME
#define LOCAL_VIDEO_FOLDER_NAME     @"localVideo"
#endif
/// 本地临时保存目录
#ifndef LOCAL_TEMP_FOLDER_NAME
#define LOCAL_TEMP_FOLDER_NAME      @"localTemp"
#endif
/// 本地json路径
#ifndef LOCAL_CONFIG_FOLDER_NAME
#define LOCAL_CONFIG_FOLDER_NAME    @"localConfig"
#endif

typedef void (^MJCacheManagerBlock)(BOOL isSucceed, NSString *message, NSObject *data);

// 缓存文件类型
typedef NS_ENUM(int, CacheFileType) {
    eCacheFileUndefined  = 0,               /**< 未知文件类型，将存放在tmp目录下面 */
    eCacheFileImage,                        /**< 普通图片类型，将存放在images目录下面 */
    eCacheFileAudio,                        /**< 用户头像类型，将存放在Audio目录下面 */
    eCacheFileVideo                         /**< 用户头像类型，将存放在Video目录下面 */
};

// 缓存文件类型
typedef NS_ENUM(int, UseCacheType) {
    eUseCacheOnly       = 0,                /**<  仅使用缓存 */
    eUseCacheFirst,                         /**<  有限使用缓存 */
    eUseCacheNone                           /**<  不是用缓存, 始终从网络加载最新文件 */
};


@interface MJCacheManager : NSObject

/** 仅在wifi下显示图片 */
@property (nonatomic, assign) BOOL fetchImageOnlyOnWifi;

+ (MJCacheManager *)sharedInstance;

+ (BOOL)canFetchImage;

/**
 *	@brief	从本地获取缓存文件，如没有缓存，则从网络获取
 *
 *	@param 	fileUrl         需要获取文件的网络url
 *	@param 	fileType        需要获取的文件类型
 *	@param 	completion      如需要从网络获取，获取完成调用该回调
 *
 *	@return	本地缓存的文件数据
 */
+ (NSObject *)getLocalFileWithUrl:(NSString *)fileUrl
                         fileType:(CacheFileType)fileType
                       completion:(MJCacheManagerBlock)completion;

/**
 *	@brief	从缓存或网络上获取所需要的文件
 *
 *	@param 	fileUrl         需要获取文件的网络url
 *	@param 	fileType        需要获取的文件类型
 *	@param 	useCache        是否使用缓存
 *	@param 	completion      获取完成时的回调
 *
 *	@return	是否已使用缓存数据，YES-是 NO-否
 */
+ (BOOL)getFileWithUrl:(NSString *)fileUrl
              fileType:(CacheFileType)fileType
              useCache:(UseCacheType)useCache
            completion:(MJCacheManagerBlock)completion;

/**
 *	@brief	从缓存或网络上获取所需要的文件，如果是从网络获取，会有获取进度回调
 *
 *	@param 	fileUrl         需要获取文件的网络url
 *	@param 	fileType        需要获取的文件类型
 *	@param 	useCache        使用缓存的形式，请查看 UseCacheType
 *	@param 	completion      从网络获取完成的回调
 *	@param 	progressBlock 	数据获取进度回调
 *
 *	@return	是否已使用缓存数据，YES-是 NO-否
 */
+ (BOOL)getFileWithUrl:(NSString *)fileUrl
              fileType:(CacheFileType)fileType
              useCache:(UseCacheType)useCache
            completion:(MJCacheManagerBlock)completion
         progressBlock:(void (^)(float percent, long long bytesReaded, long long bytesNeedToRead))progressBlock;

#pragma mark - 刷新

/**
 *	@brief	重新从服务器获取该文件, 忽略本地缓存
 *
 *	@param 	fileUrl 	获取图片的网络url
 *	@param 	fileType 	刷新缓存的文件类型
 *	@param 	completion  从网络获取完成的回调
 *
 *	@return	No return
 */
+ (void)reloadFileWith:(NSString *)fileUrl
              fileType:(CacheFileType)fileType
            completion:(MJCacheManagerBlock)completion;

/**
 *	@brief	刷新NSCache的缓存，即重新重本读文件读取缓存
 *
 *	@param 	fileUrl 	刷新缓存的网络url
 *	@param 	fileType 	刷新缓存的文件类型
 *
 *	@return	No return
 */
+ (void)refreshCacheWith:(NSString *)fileUrl
                fileType:(CacheFileType)fileType;


@end
