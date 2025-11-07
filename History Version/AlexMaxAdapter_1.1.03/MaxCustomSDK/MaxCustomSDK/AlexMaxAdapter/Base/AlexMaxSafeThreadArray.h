//
//  AlexMaxSafeThreadArray.h
//  AlexMaxAdapter
//
//  Created by Topon on 2024/3/27.
//  Copyright © 2024 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 A simple implementation of thread safe mutable array.
 
 @discussion Generally, access performance is lower than NSMutableArray,
 but higher than using @synchronized, NSLock, or pthread_mutex_t.

 @warning Fast enumerate(for..in) and enumerator is not thread safe,
 use enumerate using block instead. When enumerate or sort with block/callback,
 do *NOT* send message to the array inside the block/callback.
 */
@interface AlexMaxSafeThreadArray<ObjectType> : NSMutableArray

@end

NS_ASSUME_NONNULL_END
