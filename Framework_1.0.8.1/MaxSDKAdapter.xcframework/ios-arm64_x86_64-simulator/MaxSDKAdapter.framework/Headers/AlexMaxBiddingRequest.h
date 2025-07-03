

#import <Foundation/Foundation.h>
#import <AnyThinkSDK/AnyThinkSDK.h>



NS_ASSUME_NONNULL_BEGIN

@interface AlexMaxBiddingRequest : NSObject
@property(nonatomic, copy) NSString *price;
@property(nonatomic, strong) id customObject;
@property(nonatomic, strong) ATUnitGroupModel *unitGroup;
@property(nonatomic, strong) ATAdCustomEvent *customEvent;
@property(nonatomic, copy) NSString *unitID;
@property(nonatomic, copy) NSString *placementID;
@property(nonatomic, copy) NSDictionary *extraInfo;
@property(nonatomic, copy) NSArray *nativeAds;
@property(nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);
@property(nonatomic, assign) ATAdFormat adType;

@end

NS_ASSUME_NONNULL_END
