//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBanner.h"
#import <objc/runtime.h>

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#endif

#define iPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// DEBUG si trova in Preprocessor Macros

#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

// requested params of AdMob
NSString * const keyAdUnitID = @"adUnitID";
NSString * const keyTestDevices = @"testDevices";

NSString * const BannerProviderStatusDidChnage = @"BannerProviderStatusDidChnage";

NSString * const BannerStatusDidChnage = @"BannerStatusDidChnage";

typedef NS_ENUM(NSInteger, BannerProviderState) {
    BannerProviderStateIdle=1,
    BannerProviderStateReady,
    BannerProviderStateShown
};

@interface Provider : NSObject

@property (nonatomic) id<CommonBannerProvider> bannerProvider;
@property (nonatomic) CommonBannerPriority priority;

@property (nonatomic) BannerProviderState state;

- (id)initWithProvider:(Class)provider priority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams;

@end

@implementation Provider

- (id)initWithProvider:(Class)provider priority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams
{
    self = [super init];
    if (self) {
        // configure banner provider
        self.bannerProvider = [NSClassFromString(NSStringFromClass(provider)) sharedInstance];
        [self.bannerProvider setRequestParams:requestParams];
        
        // add options to provider
        self.priority = priority;
        self.state = BannerProviderStateIdle;
    }
    return self;
}

- (void)setState:(BannerProviderState)state
{
    _state = state;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerProviderStatusDidChnage object:nil];
}

- (BOOL)isEqual:(id)object
{
    return ([self.bannerProvider class] == [((Provider *)object).bannerProvider class]);
}

- (NSString *)providerPriority
{
    switch (self.priority) {
        case CommonBannerPriorityHigh:
            return @"CommonBannerPriorityHigh";
        case CommonBannerPriorityLow:
            return @"CommonBannerPriorityLow";
        default:
            return @"Unknown";
    }
}

- (NSString *)providerState
{
    switch (self.state) {
        case BannerProviderStateIdle:
            return @"BannerProviderStateIdle";
        case BannerProviderStateReady:
            return @"BannerProviderStateReady";
        case BannerProviderStateShown:
            return @"BannerProviderStateShown";
        default:
            return @"Unknown";
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n\"provider\" : {\n\t\"category\" : \"%@\", \n\t\"priority\" : \"%@\", \n\t\"state\" : \"%@\"\n}\n",
            NSStringFromClass([self.bannerProvider class]), [self providerPriority], [self providerState]];
}

@end

typedef void(^Task)(void);

typedef NS_ENUM(NSInteger, LockState) {
    LockStateReleased,
    LockStateAcquired,
    LockStateBusy
};

@interface CommonBanner ()

@property (nonatomic, strong) CommonBannerController *commonBannerController;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic) CommonBannerPosition bannerPosition;
@property (nonatomic) id <CommonBannerAdapter> adapter;
@property (nonatomic, strong) id<CommonBannerProvider> currentBannerProvider;
@property (nonatomic, strong) UIView *bannerContainer;

// ivar "locked" needs to synchronize dispatch_queue
@property (nonatomic, getter=isLocked) BOOL locked;

@property (nonatomic, strong) NSMutableArray *providersQueue;

@property (nonatomic, copy) Task task;

//**********************************************************//
//************************DEBUG MODE************************//
//**********************************************************//
@property (nonatomic, getter=isDebugMode) BOOL debugMode;
@property (nonatomic, strong) NSMutableArray *debugAlertQueue;
//**********************************************************//
//************************DEBUG MODE************************//
//**********************************************************//

//**********************************************************//
//*************************TEST MODE************************//
//**********************************************************//
typedef NS_ENUM(NSInteger, TestCase) {
    TestCaseShowBoth=0,
    TestCaseHideBoth,
    TestCaseShowOnlyOne,
    TestCaseCount
};

@property (nonatomic, strong) NSMutableDictionary *defaultValues;
@property (nonatomic, getter=isTestMode) BOOL testMode;
@property (nonatomic) TestCase testCase;
//**********************************************************//
//*************************TEST MODE************************//
//**********************************************************//

@end

@implementation CommonBanner
@synthesize rootViewController = _rootViewController;

//**********************************************************//
//************************DEBUG MODE************************//
//**********************************************************//
// static method to LOG provider state and selector
static void inline LOG(Provider *provider, SEL selector) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([CommonBanner isDebugMode]) {
                
                NSString *trimedTitle =
                [NSStringFromClass([provider.bannerProvider class]) stringByReplacingOccurrencesOfString:@"CommonBannerProvider"
                                                                                              withString:@""];
                UIAlertView  *alert =
                [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@\n%@", trimedTitle, NSStringFromSelector(selector)]
                                           message:[NSString stringWithFormat:@"%@", [provider providerState]]
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
                [alert show];
                
                [[CommonBanner manager].debugAlertQueue addObject:alert];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    for (UIAlertView *alert in [CommonBanner manager].debugAlertQueue) {
                        [alert dismissWithClickedButtonIndex:0 animated:YES];
                    }
                });
            }
        });
    });
}

- (NSMutableArray *)debugAlertQueue
{
    if (_debugAlertQueue == nil) {
        _debugAlertQueue = [[NSMutableArray alloc] init];
    }
    return _debugAlertQueue;
}

+ (void)setDebugMode:(BOOL)debugMode
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self manager] setDebugMode:debugMode];
    });
}

+ (BOOL)isDebugMode
{
    return [[self manager] isDebugMode];
}
//**********************************************************//
//************************DEBUG MODE************************//
//**********************************************************//

//**********************************************************//
//*************************TEST MODE************************//
//**********************************************************//
NSString * const CommonBannerStatusDidChangeNotification = @"CommonBannerStatusDidChangeNotification";

- (NSMutableDictionary *)defaultValues
{
    if (_defaultValues == nil) {
        _defaultValues = [[NSMutableDictionary alloc] initWithCapacity:[self.providersQueue count]];
    }
    return _defaultValues;
}

+ (void)setTestMode:(BOOL)testMode
{
#ifdef DEBUG
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self manager] setTestMode:testMode];
        if (testMode) {
            [self runTestAfterDelay:10];
        }
    });
#endif
}

+ (BOOL)isTestMode
{
    return [[self manager] isTestMode];
}

+ (CommonBannerPriority)defaultValue:(Provider *)provider
{
    return [[[self manager].defaultValues objectForKey:NSStringFromClass([[provider bannerProvider] class])] integerValue];
}

+ (CommonBannerPriority)testCase:(TestCase)testCase forProvider:(Provider *)provider
{
    NSInteger CommonBannerPriorityHidden = -1;
    switch (testCase) {
        case TestCaseShowBoth:
            return [self defaultValue:provider];
        case TestCaseHideBoth:
            return CommonBannerPriorityHidden;
        case TestCaseShowOnlyOne:
            return [self defaultValue:provider];
        default:
            return CommonBannerPriorityHidden;
    }
}

+ (NSString *)descriptionForTestCase:(TestCase)testCase
{
    switch (testCase) {
        case TestCaseShowBoth:
            return @"show both";
        case TestCaseHideBoth:
            return @"hide both";
        case TestCaseShowOnlyOne:
            return @"show one with highest priority";
        default:
            return nil;
            break;
    }
}

+ (void)runTestAfterDelay:(uint64_t)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[self manager].providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
            
            // save default values
            if ([[self manager].defaultValues objectForKey:NSStringFromClass([[provider bannerProvider] class])] == nil) {
                [[self manager].defaultValues setObject:@(provider.priority) forKey:NSStringFromClass([[provider bannerProvider] class])];
            }
            
            [self updatePriorityIfNeeded:[self testCase:[self manager].testCase forProvider:provider]
                                forClass:[[provider bannerProvider] class]];
        }];
        
        //*************************POST NOTIFICATION************************//
        NSDictionary *userInfo = @{@"status" : [self descriptionForTestCase:[self manager].testCase]};
        NSNotification *notification = [[NSNotification alloc] initWithName:CommonBannerStatusDidChangeNotification
                                                                     object:nil
                                                                   userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        //*************************POST NOTIFICATION************************//
        
        [self manager].testCase++;
        
        if ([self manager].testCase == TestCaseCount) {
            [self manager].testCase = 0;
        }
        
        [self runTestAfterDelay:2];
    });
}
//**********************************************************//
//*************************TEST MODE************************//
//**********************************************************//

- (void)dealloc
{
    [self removeObservers];
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self dispatchProvidersQueue];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:BannerProviderStatusDidChnage
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self dispatchProvidersQueue];
                                                  }];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BannerProviderStatusDidChnage
                                                  object:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        // custom init
    }
    return self;
}

+ (CommonBanner *)manager
{
    static dispatch_once_t pred = 0;
    __strong static CommonBanner *manager = nil;
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (CommonBannerController *)bannerControllerWithRootViewController:(UIViewController *)rootViewController
{
    [self manager].rootViewController = rootViewController;
    
    return [self manager].commonBannerController;
}

+ (void)regitserProvider:(Class)aClass withPriority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams
{
    [[self manager] setProvider:aClass withPriority:priority requestParams:requestParams];
}

+ (void)updatePriorityIfNeeded:(CommonBannerPriority)priority forClass:(Class)aClass
{
    [[self manager] updatePriorityIfNeeded:priority forClass:aClass];
}

+ (CommonBannerPriority)priorityForClass:(Class)aClass
{
    return [[self manager] priorityForClass:aClass];
}

+ (void)startManaging
{
    @synchronized(self) {
        static dispatch_once_t pred = 0;
        dispatch_once(&pred, ^{
            [[self manager] startLoading:YES];
            [[self manager] addObservers];
        });
    }
}

+ (void)stopManaging
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self manager] stopLoading:YES];
        [[self manager] removeObservers];
    });
}

+ (void)setBannerPosition:(CommonBannerPosition)bannerPosition
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [self manager].bannerPosition = bannerPosition;
    });
}

#pragma getter/setter

- (UIViewController *)commonBannerController
{
    if (_commonBannerController == nil) {
        _commonBannerController = [[CommonBannerController alloc] init];
    }
    return _commonBannerController;
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    if (_rootViewController != rootViewController) {
        //[_rootViewController.view removeFromSuperview];
        //[_rootViewController removeFromParentViewController];
        //[_rootViewController dismissViewControllerAnimated:NO completion:nil];
        rootViewController.view.frame = rootViewController.view.frame;
        
        //[self.commonBannerController.view addSubview:rootViewController.view];
        [self.commonBannerController addChildViewController:rootViewController];
        
        _rootViewController = rootViewController;
    }
}

- (UIViewController *)rootViewController
{
    if (_rootViewController == nil) {
        if ([[self.commonBannerController childViewControllers] count] > 0) {
            _rootViewController = [self.commonBannerController childViewControllers][0];
        }
    }
    return _rootViewController;
}

- (UIView *)bannerContainer
{
    if (_bannerContainer == nil) {
        _bannerContainer = [[UIView alloc] init];
        if ([[self.commonBannerController childViewControllers] count] > 0) {
            _rootViewController = [self.commonBannerController childViewControllers][0];
        }
        [_rootViewController.view addSubview:_bannerContainer];
    }
    return _bannerContainer;
}

- (Provider *)provider:(Class)provider
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bannerProvider.class = %@", provider];
    return [[self.providersQueue filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)setProvider:(Class)aClass withPriority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams
{
    Provider *provider = [[Provider alloc] initWithProvider:aClass priority:priority requestParams:requestParams];
    if (self.providersQueue == nil) {
        self.providersQueue = [NSMutableArray array];
    }
    [[self providersQueue] addObject:provider];
}

- (void)updatePriorityIfNeeded:(CommonBannerPriority)priority forClass:(Class)aClass
{
    [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
        if ([provider.bannerProvider isMemberOfClass:aClass]) {
            if (provider.priority != priority) {
                provider.priority = priority;
                
                // try to update immediately
                [self dispatchProvidersQueue];
            }
            *stop = YES;
        }
    }];
}

- (CommonBannerPriority)priorityForClass:(Class)aClass
{
    return [[[self provider:aClass] valueForKey:@"priority"] integerValue];
}

- (Provider *)currentProvider
{
    return [self provider:[self.currentBannerProvider class]];
}

- (void)syncTask:(void(^)(void))task
{
    @synchronized(self) {
        self.locked = YES;
        DebugLog(@"locking...");
        if (task) task();
        DebugLog(@"unlocking...");
        self.locked = NO;
    }
}

- (void)syncTaskWithCallback:(void(^)(void))task withLockStatusChangeBlock:(void(^)(LockState lockState))lockStatus
{
    @synchronized(self) {
        if (self.isLocked) {
            self.task = task;
            DebugLog(@"busy...");
            if (lockStatus) lockStatus(LockStateBusy);
            return;
        }
        self.locked = YES;
        DebugLog(@"locking...");
        if (lockStatus) lockStatus(LockStateAcquired);
        if (task) task();
        DebugLog(@"unlocking...");
        self.locked = NO;
        if (lockStatus) lockStatus(LockStateReleased);
        
        if (self.task) {
            self.task();
            self.task = nil;
        }
    }
}

/*!
 *  @brief  Call this method so stop loading banners
 *
 *  @param forced  stops provider completely by cancalling "delegate", means no any banner notification will posted
 */
- (void)stopLoading:(BOOL)forced
{
    [self syncTaskWithCallback:^{
        [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
            if (forced) {
                [provider.bannerProvider stopLoading];
            }
        }];
    } withLockStatusChangeBlock:^(LockState lockState) {
        if (lockState == LockStateReleased) {
            [self dispatchProvidersQueue];
        }
    }];
}

/*!
 *  @brief  Call this method so start loading banners
 *
 *  @param forced  starts providers by re-setting "delegate" means they will be ready to post notifications
 */
- (void)startLoading:(BOOL)forced
{
    [self syncTaskWithCallback:^{
        [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
            if (forced) {
                [provider.bannerProvider startLoading];
            }
        }];
    } withLockStatusChangeBlock:^(LockState lockState) {
        if (lockState == LockStateReleased) {
            [self dispatchProvidersQueue];
        }
    }];
}

- (void)dispatchProvidersQueue
{
    @synchronized(self) {
        if (self.isLocked) {
            DebugLog(@"waiting for lock...");
            return;
        }
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
        NSArray *providers = [self.providersQueue sortedArrayUsingDescriptors:@[sort]];
        for (int i = 0; i < [providers count]; i++) {
            Provider *provider = [providers objectAtIndex:i];
            //*******************DEBUG*******************//
            DebugLog(@"provider = %@", provider);
            DebugLog(@"currentProvider = %@", [self currentProvider]);
            //*******************DEBUG*******************//
            if (self.adapter != nil) {
                if (![self.adapter canDisplayAds] || provider.priority < 0) {
                    [self syncTask:^{
                        provider.state = BannerProviderStateIdle;
                        [self performLayoutAnimated:NO completion:^(BOOL finished) {
                            self.currentBannerProvider = nil;
    
                        }];
                    }];
                }
                else {
                    // if current banner provider shown with priority=1 then skip
                    if ([self currentProvider].state != BannerProviderStateShown || [self currentProvider].priority != CommonBannerPriorityHigh) {
                        // if current banner provider changes state to idle then hide
                        if (self.currentBannerProvider != nil && [self currentProvider].state == BannerProviderStateIdle) {
                            [self syncTask:^{
                                [self performLayoutAnimated:NO completion:^(BOOL finished) {
                                    self.currentBannerProvider = nil;
        
                                }];
                            }];
                        }
                        else if ([provider.bannerProvider isBannerLoaded] && !([provider isEqual:[self currentProvider]])) {
                            DebugLog(@"preparing to show...%@", [[provider bannerProvider] class]);
                            [self syncTask:^{
                                // hide banner
                                [self performLayoutAnimated:NO completion:^(BOOL finished) {
                                    // remove current banner from bannerContainer
                                    [[self.currentBannerProvider bannerView] removeFromSuperview];
                                    // set old provider to [state=ready]
                                    [self currentProvider].state = BannerProviderStateIdle;
                                    // get new provider
                                    self.currentBannerProvider = [provider bannerProvider];
                                    // set new provider to [state=shown]
                                    [self currentProvider].state = BannerProviderStateShown;
                                    // add current banner to bannerContainer
                                    [self.bannerContainer addSubview:[self.currentBannerProvider bannerView]];
                                    // diplay banner
                                    [self performLayoutAnimated:YES completion:^(BOOL finished) {
                                        LOG([self currentProvider], _cmd);
   
                                    }];
                                }];
                            }];
                            break;
                        }
                    }
                }
            }
        }
    }
}

- (void)performLayoutAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    //****************************DEBUG****************************//
    DebugLog(@"isBannerLoaded=[%@] animated=[%@]",
             [self.currentBannerProvider isBannerLoaded] ? @"Y" : @"N",
             ([self.adapter adsShouldDisplayAnimated] && animated) ? @"Y" : @"N");
    //****************************DEBUG****************************//
    if ([self.adapter adsShouldDisplayAnimated] && animated) {
        [UIView animateWithDuration:0.25 animations:^{
            // viewDidLayoutSubviews will handle positioning the banner view so that it is visible.
            // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
            // as requiring layout...
            [self.commonBannerController.view setNeedsLayout];
            // ... then ask it to lay itself out immediately if it is flagged as requiring layout...
            [self.commonBannerController.view layoutIfNeeded];
            // ... which has the same effect.
        } completion:^(BOOL finished) {
            if (completion) completion(YES);
        }];
    }
    else {
        [self layoutBannerContainer];
        if (completion) completion(YES);
    }
}

- (void)layoutBannerContainer
{
    CGRect contentFrame = self.commonBannerController.view.bounds, bannerFrame = CGRectZero;
    
    // All we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [[self.currentBannerProvider bannerView] sizeThatFits:contentFrame.size];
    
    if ([self.currentBannerProvider isBannerLoaded] && [self.adapter canDisplayAds]) {
        if (self.bannerPosition == CommonBannerPositionBottom) {
            contentFrame.size.height -= bannerFrame.size.height;
            bannerFrame.origin.y = contentFrame.size.height;
        }
        else if (self.bannerPosition == CommonBannerPositionTop) {
            bannerFrame.origin.y = 0;
            contentFrame.origin.y += bannerFrame.size.height;
            contentFrame.size.height -= bannerFrame.size.height;
        }
    }
    else {
        if (self.bannerPosition == CommonBannerPositionBottom) {
            bannerFrame.origin.y = contentFrame.size.height;
        }
        else if (self.bannerPosition == CommonBannerPositionTop) {
            bannerFrame.origin.y -= bannerFrame.size.height;
            contentFrame = self.commonBannerController.view.bounds;
        }
    }
    
    if ([self.adapter adsShouldCoverContent]) {
        contentFrame = self.commonBannerController.view.bounds;
    }
    
    self.rootViewController.view.frame = contentFrame;
    self.bannerContainer.frame = bannerFrame;

}

@end

@interface CommonBannerController ()

@property (nonatomic) CGSize currentSize;

@end

@implementation CommonBannerController

- (id)init
{
    self = [super init];
    if (self) {
        // custom init
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // custom init
    }
    return self;
}

- (void)awakeFromNib
{
    [CommonBanner manager].commonBannerController = self;
}

- (void)loadView
{
    // call in case if initialized from XIB
    [super loadView];
    
    // create view if not initialized from XIB
    if (self.view == nil) {
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.view.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // workaround for iOS 7. For wihtout on iOS 8
    [[[CommonBanner manager] bannerContainer] setNeedsLayout];
    [[[CommonBanner manager] bannerContainer] layoutIfNeeded];
}

- (void)viewDidLayoutSubviews
{
    // adjust banner orientation
    if ([[[CommonBanner manager] currentBannerProvider] respondsToSelector:@selector(viewWillTransitionToSize:)]) {
        [[[CommonBanner manager] currentBannerProvider] viewWillTransitionToSize:self.view.bounds.size];
    }
    
    // layout banner container
    [[CommonBanner manager] layoutBannerContainer];
}

/*!
 * @method Call this method if your target >= 8.0
 *
 * @discussion
 * Reserved for future use.
 */
/*
 #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
 - (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
 {
 [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
 
 if ([[[CommonBanner manager] currentBannerProvider] respondsToSelector:@selector(viewWillTransitionToSize:)]) {
 [[[CommonBanner manager] currentBannerProvider] viewWillTransitionToSize:size];
 }
 }
 #endif
 //*/

@end

@implementation UIViewController (BannerAdapter)
@dynamic canDisplayAds, adsShouldCoverContent, adsShouldDisplayAnimated;

- (BOOL)canDisplayAds
{
    return [objc_getAssociatedObject(self, @selector(canDisplayAds)) boolValue];
}

- (void)setCanDisplayAds:(BOOL)canDisplayAds
{
    objc_setAssociatedObject(self, @selector(canDisplayAds), @(canDisplayAds), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[CommonBanner manager] setAdapter:self];
    
    [[CommonBanner manager] dispatchProvidersQueue];
}

- (BOOL)adsShouldCoverContent
{
    return [objc_getAssociatedObject(self, @selector(adsShouldCoverContent)) boolValue];
}

- (void)setAdsShouldCoverContent:(BOOL)adsShouldCoverContent
{
    objc_setAssociatedObject(self, @selector(adsShouldCoverContent), @(adsShouldCoverContent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)adsShouldDisplayAnimated
{
    return [objc_getAssociatedObject(self, @selector(adsShouldDisplayAnimated)) boolValue];
}

- (void)setAdsShouldDisplayAnimated:(BOOL)adsShouldDisplayAnimated
{
    objc_setAssociatedObject(self, @selector(adsShouldDisplayAnimated), @(adsShouldDisplayAnimated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface CommonBannerProvideriAd () <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;
@property (readwrite, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@end

@implementation CommonBannerProvideriAd
@synthesize requestParams;

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)stopLoading
{
    self.bannerView.delegate = nil;
    
    // set to idle state
    Provider *provider = [[CommonBanner manager] provider:[self class]];
    provider.state = BannerProviderStateIdle;
}

- (void)startLoading
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        // on iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        }
        else {
            self.bannerView = [[ADBannerView alloc] init];
        }
    });
    
    // start receiving callbacks
    self.bannerView.delegate = self;
}

- (void)viewWillTransitionToSize:(CGSize)size
{
    CGRect frame = self.bannerView.frame;
    frame.size = [self.bannerView sizeThatFits:size];
    self.bannerView.frame = frame;
}

#pragma ADBannerViewDelegate protocol

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.bannerLoaded = YES;
    
    Provider *provider = [[CommonBanner manager] provider:[self class]];
    if (provider.state == BannerProviderStateIdle) provider.state = BannerProviderStateReady;
    
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidLoad)]) {
        [adapter bannerViewDidLoad];
    }
    
    LOG(provider, _cmd);
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.bannerLoaded = NO;
    
    Provider *provider = [[CommonBanner manager] provider:[self class]];
    if (provider.state != BannerProviderStateIdle) provider.state = BannerProviderStateIdle;
    
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidFailToReceiveWithError:)]) {
        [adapter bannerViewDidFailToReceiveWithError:error];
    }
    
    LOG(provider, _cmd);
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionShouldBegin)]) {
        [adapter bannerViewActionShouldBegin];
    }
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionDidFinish)]) {
        [adapter bannerViewActionDidFinish];
    }
}

@end

@interface CommonBannerProviderGAd () <GADBannerViewDelegate>

@property (nonatomic, strong) GADRequest *request;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (readwrite, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@end

@implementation CommonBannerProviderGAd
@synthesize requestParams;

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)stopLoading
{
    self.bannerView.delegate = nil;
    
    // set to idle state
    Provider *provider = [[CommonBanner manager] provider:[self class]];
    provider.state = BannerProviderStateIdle;
}

- (void)startLoading
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.bannerView.adUnitID = [self.requestParams objectForKey:keyAdUnitID];
        self.bannerView.rootViewController = [CommonBanner manager].commonBannerController;
        self.bannerView.autoloadEnabled = YES;
        
        self.request = [GADRequest request];
        // Requests test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADBannerView automatically returns test ads when running on a
        // simulator.
        self.request.testDevices = [self.requestParams objectForKey:keyTestDevices];
    });
    
    // start receiving callbacks
    self.bannerView.delegate = self;
}

- (void)viewWillTransitionToSize:(CGSize)size
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        self.bannerView.adSize = kGADAdSizeSmartBannerPortrait;
    }
    else {
        self.bannerView.adSize = kGADAdSizeSmartBannerLandscape;
    }
}

#pragma GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    self.bannerLoaded = YES;
    
    Provider *provider = [[CommonBanner manager] provider:[self class]];
    if (provider.state == BannerProviderStateIdle) provider.state = BannerProviderStateReady;
    
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidLoad)]) {
        [adapter bannerViewDidLoad];
    }
    
    LOG(provider, _cmd);
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    self.bannerLoaded = NO;
    
    Provider *provider = [[CommonBanner manager] provider:[self class]];
    if (provider.state != BannerProviderStateIdle) provider.state = BannerProviderStateIdle;
    
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidFailToReceiveWithError:)]) {
        [adapter bannerViewDidFailToReceiveWithError:error];
    }
    
    LOG(provider, _cmd);
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionShouldBegin)]) {
        [adapter bannerViewActionShouldBegin];
    }
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    id<CommonBannerAdapter> adapter = [CommonBanner manager].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionDidFinish)]) {
        [adapter bannerViewActionDidFinish];
    }
}

@end

@interface CommonBannerProviderCustom () <GADBannerViewDelegate>

@property (nonatomic, strong) UIView *bannerView;
@property (readwrite, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@end

@implementation CommonBannerProviderCustom
@synthesize requestParams;

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)stopLoading
{
    self.bannerLoaded = NO;
    
    // set to idle state
    Provider *provider = [[CommonBanner manager] provider:[self class]];
    provider.state = BannerProviderStateIdle;
}

- (void)startLoading
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        self.bannerView = [[UIView alloc] initWithFrame:(CGRect){0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 50.0f}];
        self.bannerView.backgroundColor = [UIColor greenColor];
    });
    
    // start receiving callbacks
    self.bannerLoaded = YES;
}

- (void)viewWillTransitionToSize:(CGSize)size
{
    CGRect frame = self.bannerView.frame;
    frame.size.width = size.width;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        frame.size.height = 50;
        self.bannerView.backgroundColor = [UIColor greenColor];
    }
    else {
        frame.size.height = 20;
        self.bannerView.backgroundColor = [UIColor orangeColor];
    }
    self.bannerView.frame = frame;
}

@end