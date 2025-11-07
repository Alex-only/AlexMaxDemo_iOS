//
//  AlexMaxNativeLoader.h
//  AnyThinkMaxAdapter
//
//  Created by GUO PENG on 2025/2/19.
//  Copyright © 2025 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlexMaxNativeDelegate.h"
 
NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxNativeLoader : NSObject

- (void)loadNativeWithCustomEven:(AlexMaxNativeDelegate *)nativeDelegate serverInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo;


@end

NS_ASSUME_NONNULL_END
