//
//  YMFHTTPClient+RACExtensions.h
//  YunMoFang
//
//  Created by Talent Wang on 2017/4/7.
//  Copyright © 2017年 Yunyun Network Technology Co.,Ltd. All rights reserved.
//

#import "YMFHTTPClient.h"

@interface YMFHTTPClient (RACExtensions)

- (RACSignal *)postToPath:(NSString *)path withSpecificParameters:(id)specificParameters;
- (RACSignal *)postToPath:(NSString *)path withSpecificParameters:(id)specificParameters progress:(void (^)(NSProgress *progress))uploadProgress;

@end
