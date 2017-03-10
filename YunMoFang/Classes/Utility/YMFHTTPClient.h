//
//  YMFHTTPClient.h
//  YunMoFang
//
//  Created by Talent Wang on 2017/2/7.
//  Copyright © 2017年 Yunyun Network Technology Co.,Ltd. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef enum : NSUInteger {
    YMFHTTPClientExceptionInvalidToken = 10001,
    YMFHTTPClientExceptionUserKickedOff = 10002,
    YMFHTTPClientExceptionExceptionalAccount = 10003
} YMFHTTPClientException;

@protocol IQZHTTPClientDelegate <NSObject>

@optional;
- (void)clientRecievedException:(YMFHTTPClientException)exception description:(NSString *)description;

@end

@class RACSignal;
@interface YMFHTTPClient : AFHTTPSessionManager

@property (nonatomic, weak) id<IQZHTTPClientDelegate> delegate;

+ (instancetype)sharedClient;

@property (nonatomic, strong, readonly) NSMutableDictionary *commonParameters;
- (void)commonParametersSetUserID:(NSNumber *)userID;
- (void)commonParametersSetToken:(NSString *)token;

- (RACSignal *)postToPath:(NSString *)path withSpecificParameters:(id)specificParameters;
- (RACSignal *)postToPath:(NSString *)path withSpecificParameters:(id)specificParameters progress:(void (^)(NSProgress *progress))uploadProgress;

@end
