//
//  UIView+TABLayerout.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2018/9/21.
//  Copyright © 2018年 tigerAndBull. All rights reserved.
//

#import "UIView+TABLayoutSubviews.h"
#import "TABAnimated.h"

#import <objc/runtime.h>

@implementation UIView (TABLayoutSubviews)

+ (void)load {
    
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // Gets the layoutSubviews method to the class,whose type is a pointer to a objc_method structure.
        Method originMethod = class_getInstanceMethod([self class], @selector(layoutSubviews));
        // Get the method you created.
        Method newMethod = class_getInstanceMethod([self class], @selector(tab_layoutSubviews));
        
        method_exchangeImplementations(originMethod, newMethod);
    });
}

#pragma mark - Exchange Method

- (void)tab_layoutSubviews {
    
    [self tab_layoutSubviews];

    if ([self isKindOfClass:[UITableView class]] ||
        [self isKindOfClass:[UICollectionView class]] ||
        [self isKindOfClass:[UICollectionViewCell class]] ||
        [self isKindOfClass:[UITableViewCell class]]) {
        return;
    }
    
    // start animation/end animation
    dispatch_async(dispatch_get_main_queue(), ^{

        if (nil != self.tabAnimated) {
            
            switch (self.tabAnimated.state) {
                    
                case TABViewAnimationStart: {
                    
                    // change status
                    self.tabAnimated.state = TABViewAnimationRunning;
                    
                    if (nil == self.tabLayer) {
                        self.tabLayer = TABLayer.new;
                        self.tabLayer.frame = self.bounds;
                        self.tabLayer.animatedHeight = self.tabAnimated.animatedHeight;
                        self.tabLayer.animatedCornerRadius = self.tabAnimated.animatedCornerRadius;
                        self.tabLayer.cancelGlobalCornerRadius = self.tabAnimated.cancelGlobalCornerRadius;
                        [self.layer addSublayer:self.tabLayer];
                    }
                    
                    NSMutableArray <TABComponentLayer *> *array = @[].mutableCopy;
                    // start animations
                    [TABManagerMethod getNeedAnimationSubViews:self
                                                 withSuperView:self
                                                  withRootView:self
                                             withRootSuperView:self
                                                         array:array];
                    
                    self.tabLayer.componentLayerArray = array;
                    
                    __weak typeof(self) weakSelf = self;
                    if (self.tabAnimated.categoryBlock) {
                        self.tabAnimated.categoryBlock(weakSelf);
                    }
                    
                    self.tabLayer.animatedBackgroundColor = self.tabAnimated.animatedBackgroundColor;
                    self.tabLayer.animatedColor = self.tabAnimated.animatedColor;
                    [self.tabLayer updateSublayers:self.tabLayer.componentLayerArray.mutableCopy];
                    
                    // add shimmer animation
                    if ([TABManagerMethod canAddShimmer:self]) {
                        [TABAnimationMethod addShimmerAnimationToView:self
                                                             duration:[TABAnimated sharedAnimated].animatedDurationShimmer
                                                                  key:kTABShimmerAnimation];
                        break;
                    }
                    
                    // add bin animation
                    if ([TABManagerMethod canAddBinAnimation:self]) {
                        [TABAnimationMethod addAlphaAnimation:self
                                                     duration:[TABAnimated sharedAnimated].animatedDurationBin key:kTABAlphaAnimation];
                    }
                }
                    
                    break;
                    
                case TABViewAnimationEnd: {
                    // end animations
                    [TABManagerMethod endAnimationToSubViews:self];
                    [TABManagerMethod removeMask:self];
                }
                    
                    break;
                    
                default:
                    break;
            }
        }
    });
}

@end
