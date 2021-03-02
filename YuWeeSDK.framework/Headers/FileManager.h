//
//  FileManager.h
//  YuWeeSDK
//
//  Created by Tanay on 17/12/20.
//  Copyright © 2020 yuwee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN



@interface FileManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

- (void)getAwsCredentialsWithCompletionBlock:(OnGetAwsCredHandler)handler;

- (void)setupAwsCredentialWithAccessKey:(NSString*)accessKeyId
                    withSecretAccessKey:(NSString*)secretAccessKey
                       withSessionToken:(NSString*)sessionToken;

- (void)initFileShareWithRoomId:(NSString*)roomId
            withCompletionBlock:(OnInitFileShareCompletionHandler)completionHandler;

//fun sendFile(roomId: String,
//                 uniqueIdentifier: String,
//                 filePath: String,
//                 fileName: String,
//                 fileExtension: String,
//                 listener: SendFileListener)
//
//    fun getFileUrl(fileId: String, fileKey: String, urlListener: GetFileUrlListener)

- (void)sendFileWithRoomId:(NSString*)roomId
      withUniqueIdentifier:(NSString*)uniqueIdentidier
              withFileData:(NSData*)fileData
              withFileName:(NSString*)fileName
         withFileExtension:(NSString*)fileExtension
              withFileSize:(unsigned long)fileSize
              withDelegate:(nonnull id <YuWeeFileUploadDelegate>)delegate;


- (void)getFileUrlWithFileId:(NSString*)fileId
                 withFileKey:(NSString*)fileKey
         withCompletionBlock:(OnInitFileShareCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
