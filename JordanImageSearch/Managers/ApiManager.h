//
//  ApiManager.h
//  JordanImageSearch
//
//  Created by Jordan Lepretre on 24/03/2018.
//  Copyright © 2018 JDN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiManager : NSObject

+ (ApiManager *) sharedInstance;

//GET
- (void) getImagesWithSearch:(NSString *)searchParam andCompletionBlock:(void(^)(NSError *error, NSArray *json))completion;

//POST

//PUT

//DELETE

@end
