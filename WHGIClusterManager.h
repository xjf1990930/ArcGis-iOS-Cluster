//
//  WHGIClusterManager.h
//  WHGIWitFirePost
//
//  Created by 徐俊峰 on 2019/11/4.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AGSMapView;

@interface WHGIClusterManager : NSObject


/// 需要聚合的图层ID
@property (nonatomic, strong, readonly) NSArray<NSString *> *clustLayerIDs;


/// 初始化
/// @param mapView 地图视图
- (instancetype)initWithMapView:(AGSMapView *)mapView;


/// 重新设置需要聚合的图层id，调用这个方法就会重新加载聚合图形
/// @param layerIDs 需要聚合的图层id
- (void)setClustLayerIDs:(NSArray<NSString *> *)layerIDs;

@end
