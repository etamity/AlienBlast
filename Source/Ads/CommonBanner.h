//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@import GoogleMobileAds;

typedef NS_ENUM(NSInteger, CommonBannerPosition) {
    CommonBannerPositionBottom=0,
    CommonBannerPositionTop
};

@protocol CommonBannerAdapter <NSObject>

@optional
// @important: optional params should be set before calling "canDisplayAds"
@property (readwrite, nonatomic) BOOL adsShouldCoverContent;
@property (readwrite, nonatomic) BOOL adsShouldDisplayAnimated;

@required
@property (readwrite, nonatomic) BOOL canDisplayAds;

@optional
- (void)bannerViewDidLoad;
- (void)bannerViewDidFailToReceiveWithError:(NSError *)error;
- (void)bannerViewActionShouldBegin;
- (void)bannerViewActionDidFinish;

@end

// params needs to build AdMob request
// required - app id
extern NSString * const keyAdUnitID;
// optional - device id array
extern NSString * const keyTestDevices;

@protocol CommonBannerProvider <NSObject>

@required
@property (readonly, nonatomic) UIView *bannerView;
@property (readonly, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@optional
@property (readwrite, nonatomic, strong) NSDictionary *requestParams;

@required
+ (instancetype)sharedInstance;
- (void)startLoading;
- (void)stopLoading;

@optional
- (void)viewWillTransitionToSize:(CGSize)size;

@end

typedef NS_ENUM(NSInteger, CommonBannerPriority) {
    CommonBannerPriorityLow=0,
    CommonBannerPriorityHigh
};

@class CommonBannerController;

@interface CommonBanner : NSObject

/*!
 *  @brief  Call this method to enable debug mode
 *
 *  @param debug set YES to enable
 */
+ (void)setDebugMode:(BOOL)debugMode;

/*!
 *  @brief  Call this method to enable test mode
 *
 *  @param debug set YES to enable
 *  @warning will be disabled in release mode
 */
+ (void)setTestMode:(BOOL)testMode;

/*!
 *  @brief  Call this method to have shared manager of CommonBanner
 *
 *  @return singleton instance of banner manager
 */
+ (CommonBanner *)manager;

/*!
 *  @brief  Call this method to set rootViewController
 *
 *  @param rootViewController first controller of stack
 *
 *  @return singleton instance of banner manager
 *  @discussion This method should be called in application:didFinishLaunchingWithOptions: The returned viewcontroller an instance of type CommonBannerController should be set as a application window.rootViewController. If your app uses storyboard you should ignore this method. In that case create initial view controller with type=CommonBannerController, then create embed transition to your top view controller
 */
+ (CommonBannerController *)bannerControllerWithRootViewController:(UIViewController *)rootViewController;

/*!
 *  @brief  Call this method to initialize provider bannner
 *
 *  @param provider reflection class of type CommonBannerProvideriAd, CommonBannerProviderGAd
 *  @param priority of type CommonBannerPriority
 */
+ (void)regitserProvider:(Class)aClass withPriority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams;

/*!
 *  @brief  Call this method to update priorities if current one is different the one that passing
 *
 *  @param priority of type CommonBannerPriority
 *  @param aClass   reflection class of type CommonBannerProvideriAd, CommonBannerProviderGAd
 */
+ (void)updatePriorityIfNeeded:(CommonBannerPriority)priority forClass:(Class)aClass;

/*!
 *  @brief  Call this method to know the current priority for a given class
 *
 *  @param aClass reflection class of type CommonBannerProvideriAd, CommonBannerProviderGAd
 *
 *  @return currrent priority
 */
+ (CommonBannerPriority)priorityForClass:(Class)aClass;

/*!
 *  @brief  Call this method to start managing banners
 */
+ (void)startManaging;

/*!
 *  @brief  Call this method to stop managing banners. Important: when stopped can not be restarted again, restart the app.
 */
+ (void)stopManaging;

/*!
 *  @brief  Call this method to set banner position
 *
 *  @param bannerPosition Default value is CommonBannerPositionBottom.
 *  @warning Setup once
 *  @warning If window.rootViewController is kind of UINavigationController class then banner position forced to CommonBannerPositionBottom
 *  for usability issues.
 */
+ (void)setBannerPosition:(CommonBannerPosition)bannerPosition;

@end

@interface CommonBannerController : UIViewController

@end

@interface UIViewController (BannerAdapter) <CommonBannerAdapter>

@end


@interface CommonBannerProvideriAd : NSObject <CommonBannerProvider>

@end

@interface CommonBannerProviderGAd : NSObject <CommonBannerProvider>

@end

@interface CommonBannerProviderCustom : NSObject <CommonBannerProvider>

@end