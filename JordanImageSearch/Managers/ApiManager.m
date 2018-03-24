//
//  ApiManager.m
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import "ApiManager.h"
#import "AFNetworking.h"

@implementation ApiManager

static ApiManager *sharedInstance = nil;

const NSString *apiUrl = @"https://pixabay.com/api/?key=5511001-7691b591d9508e60ec89b63c4";
//const NSString *apiKey = @"5511001-7691b591d9508e60ec89b63c4";

+ (ApiManager *) sharedInstance{
    if (sharedInstance == nil) {
        sharedInstance = [[ApiManager alloc] init];
    }
    
    return sharedInstance;
}

#pragma mark - GET
//GET IMAGES
- (void) getImagesWithSearch:(NSString *)searchParam andCompletionBlock:(void(^)(NSError *error, NSDictionary *json))completion{
    
    //Replace empty space with '+'
    searchParam = [searchParam stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *imagesUrl = [NSString stringWithFormat:@"%@&q=%@", apiUrl,searchParam];
    
    [self makeHTTPGetRequestWithUrl:imagesUrl andCompletionBlock:^(NSError *error, id responseObject) {
        if(error) {
            completion(error, nil);
        }
        else{
            completion(nil, responseObject);
        }
    }];
}


#pragma mark - Generic requests
//GET REQUEST
- (void) makeHTTPGetRequestWithUrl:(NSString *)url andCompletionBlock:(void(^)(NSError *error, id responseObject))completion{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    
    //    NSLog(@"GET: %@", url);
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error, nil);
    }];
}

@end
