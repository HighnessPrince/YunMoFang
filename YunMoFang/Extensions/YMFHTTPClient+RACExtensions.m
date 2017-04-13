//
//  YMFHTTPClient+RACExtensions.m
//  YunMoFang
//
//  Created by Talent Wang on 2017/4/7.
//  Copyright © 2017年 Yunyun Network Technology Co.,Ltd. All rights reserved.
//

#import "YMFHTTPClient+RACExtensions.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation YMFHTTPClient (RACExtensions)

#pragma mark - Post signals
- (RACSignal *)postToPath:(NSString *)path withSpecificParameters:(id)specificParameters{
    return [self postToPath:path withSpecificParameters:specificParameters progress:nil];
}

- (RACSignal *)postToPath:(NSString *)path withSpecificParameters:(id)specificParameters progress:(void (^)(NSProgress *progress))uploadProgress{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self postToPath:path specificParameters:specificParameters progress:uploadProgress completionHandler:^(NSDictionary *responseData, NSError *error) {
            if (!error) {
                [subscriber sendNext:responseData];
                [subscriber sendCompleted];
            }
            else{
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];
}

@end
