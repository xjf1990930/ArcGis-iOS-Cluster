//
//  WHGIClusterModel.h
//  WHGIWitFirePost
//
//  Created by 徐俊峰 on 2019/11/4.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import <Foundation/Foundation.h>
//ArcGis地图
#import <ArcGIS/ArcGIS.h>


//负责数据展示的类
@interface WHGIClusterModel : NSObject


/// 聚合单元的形状
@property (nonatomic, strong, readonly) AGSEnvelope *referEnv;


/// 初始化
/// @param env 聚合单元的形状
/// @param clustLayer 聚合图层
/// @param clustLayerIDs 需要被聚合的图层id
- (instancetype)initWithEnvlope:(AGSEnvelope *)env andClustLayer:(AGSGraphicsLayer *)clustLayer andClustLayerIDs:(NSArray<NSString *> *)clustLayerIDs;

- (void)startClusterTask;//开始聚合
- (void)stopClusterTask;//stop之后该实例就没用了
@end
