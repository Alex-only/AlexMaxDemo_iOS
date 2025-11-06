

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@class ATPlacementModel,ATUnitGroupModel,ATBidInfo;
@interface AlexMaxNativeAdapter : NSObject


+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
