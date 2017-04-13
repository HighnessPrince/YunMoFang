//
//  YMFHTTPClient.m
//  YunMoFang
//
//  Created by Talent Wang on 2017/2/7.
//  Copyright © 2017年 Yunyun Network Technology Co.,Ltd. All rights reserved.
//

#import "YMFHTTPClient.h"
#import <AFNetworking/AFNetworking.h>

#import "NSString+YMFEncryption.h"
#import "YMFUserDefaultsKeys.h"
#import "YMFParams.h"

#define kCommonParameterPlatformValue (@(1))

static const NSTimeInterval kHTTPRequestTimeoutInterval = 10;
static NSString *const kSpecificParametersKey = @"yy_body";
static NSString *const kCommonParametersKey = @"yy_header";

static NSString *const kResponseCodeKey = @"result_code";
static NSString *const kResponseMessageKey = @"result_msg";

static NSString *const kExceptionalResponseCodeDomain = @"YMFHTTPClientExceptionalResponseCodeDomain";
static NSString *const kExceptionalResponseDataDomain = @"YMFHTTPClientExceptionalResponseDataDomain";

@interface YMFHTTPClient ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *commonParameters;

@end

@implementation YMFHTTPClient

#pragma mark - Singleton
+ (instancetype)sharedClient{
    static YMFHTTPClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:YMFBaseURLString];
        ;
        sharedClient = [[YMFHTTPClient alloc] initWithBaseURL:baseURL];
        sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        sharedClient.requestSerializer.timeoutInterval = kHTTPRequestTimeoutInterval;
        [sharedClient.reachabilityManager startMonitoring];
    });
    return sharedClient;
}

#pragma mark - Assemble parameters
- (NSDictionary *)p_assembledParametersWithSpecificParameters:(NSDictionary *)specificParameters{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (specificParameters) {
        parameters[kSpecificParametersKey] = specificParameters;
    }
    else{
        parameters[kSpecificParametersKey] = @{};
    }
    parameters[kCommonParametersKey] = self.commonParameters;
    return [NSDictionary dictionaryWithDictionary:parameters];
}

#pragma mark - POST
- (NSURLSessionDataTask *)postToPath:(NSString *)path specificParameters:(id)specificParameters completionHandler:(void(^)(NSDictionary *responseData, NSError *error))completionHandler{
    return [self postToPath:path specificParameters:specificParameters progress:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)postToPath:(NSString *)path specificParameters:(id)specificParameters progress:(void (^)(NSProgress *progress))uploadProgress completionHandler:(void(^)(NSDictionary *responseData, NSError *error))completionHandler{
    NSDictionary *assembledParameters = [self p_assembledParametersWithSpecificParameters:specificParameters];
    return [super POST:path parameters:assembledParameters progress:uploadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSError *error = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"%@, response data: %@", path, responseObject);
            NSNumber *responseCode = responseObject[kResponseCodeKey];
            if (![responseCode isEqualToNumber:@0]) {
                NSString *responseMessage = responseObject[kResponseMessageKey];
                error = [NSError errorWithDomain:kExceptionalResponseCodeDomain code:responseCode.integerValue userInfo:@{NSLocalizedDescriptionKey : responseMessage}];
                NSLog(@"HTTP client error:%@, localized description:%@", error, error.localizedDescription);
                completionHandler ? completionHandler(nil, error) : nil;
                if ([_delegate respondsToSelector:@selector(clientRecievedException:description:)]) {
                    YMFHTTPClientException exception = error.code;
                    [_delegate clientRecievedException:exception description:error.localizedDescription];
                }
            }
            else{
                completionHandler ? completionHandler(responseObject, nil) : nil;
            }
        }
        else{
            error = [NSError errorWithDomain:kExceptionalResponseDataDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"response data is not an expected instance of NSDictionary class"}];
            NSLog(@"HTTP client error:%@, localized description:%@", error, error.localizedDescription);
            completionHandler(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if (errorData) {
            NSString *errorInfo = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", errorInfo);
        }
        NSLog(@"HTTP client error:%@, localized description:%@", error, error.localizedDescription);
        completionHandler(nil, error);
    }];
}

#pragma mark - Setter
- (void)commonParametersSetUserID:(NSNumber *)userID{
    self.commonParameters[@"uid"] = userID;
}

- (void)commonParametersSetToken:(NSString *)token{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kTokenUserDefaultsKey];
}

#pragma mark - Getter
- (NSMutableDictionary *)commonParameters{
    if (!_commonParameters) {
        NSNumber *platform = kCommonParameterPlatformValue;
        NSString *deviceModel = [UIDevice currentDevice].model;
        NSString *IMEI = @"";
        NSString *uuidForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *MACAddress = @"";
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [NSString stringWithFormat:@"iOS_%@", infoDictionary[@"CFBundleShortVersionString"]];
        NSString *localLanguage = [NSLocale preferredLanguages][0];
        NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        NSString *iPhoneOSVersion = [UIDevice currentDevice].systemVersion;
        NSNumber *appBuild = @([infoDictionary[@"CFBundleVersion"] integerValue]);
        _commonParameters = [NSMutableDictionary dictionaryWithDictionary:@{@"platform" : platform,
                                                                            @"model" : deviceModel,
                                                                            @"imei" : IMEI,
                                                                            @"device_id" : uuidForVendor,
                                                                            @"app_version" : appVersion,
                                                                            @"app_build" : appBuild,
                                                                            @"mac" : MACAddress,
                                                                            @"language" : localLanguage,
                                                                            @"country" : country,
                                                                            @"version" : iPhoneOSVersion}];
    }
    NSString *timestamp = [NSString stringWithFormat:@"%lld", [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue]];
    NSString *randomNumber = [[NSString alloc] initWithFormat:@"%06d", arc4random_uniform(1000000)];
    _commonParameters[@"random"] = randomNumber;
    _commonParameters[@"timestamp"] = timestamp;
    _commonParameters[@"network"] = @(self.reachabilityManager.networkReachabilityStatus);
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenUserDefaultsKey];
    if (token) {
        _commonParameters[@"signature"] = [[[randomNumber stringByAppendingString:token] stringByAppendingString:timestamp] md5];
    }
    else{
        _commonParameters[@"signature"] = @"foo";
    }
    return _commonParameters;
}

@end
