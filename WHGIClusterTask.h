//
//  WHGIClusterTask.h
//  WHGIWitFirePost
//
//  Created by 徐俊峰 on 2019/11/5.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGSGeometry;
@class AGSGraphic;
@class AGSEnvelope;
@class AGSSpatialReference;

//负责数据查询
#define pWHGIClustLayerService [WHGIDataSwitch mapDynamicLayerURLForType:[WHGIDataSwitch currentType]]
#define pWHGIClustLayerIDs @[@"0",@"2",@"3",@"4",@"6",@"7",@"8"]
#define pWHGIClustLayerSymbolImageNames @[@"单位信息",@"社会消防力量",@"消防机构",@"熟悉演练",@"消防栓",@"取水码头",@"天然水源"];

@interface WHGIClusterTask : NSObject


/// 空间查询结果
@property (nonatomic, strong, readonly) NSArray<AGSGraphic *>*allResults;

/// 空间查询的图层id
@property (nonatomic, copy, readonly) NSString *layerID;

/// 是否查询成功
@property (nonatomic, assign, readonly) BOOL clustSuccess;

/// 标记
@property (nonatomic, assign) BOOL marked;

/// 初始化
/// @param layerID 空间查询的图层id
- (instancetype)initWithLayerID:(NSString *)layerID;

/// 方法调用执行空间查询，并回调需要被聚合的查询结果
/// @param env 空间查询范围
/// @param callBack 回调
- (void)clustWithEnvlope:(AGSEnvelope *)env andCall:(void(^)(BOOL success,NSArray<AGSGraphic *> *allResults))callBack;

/// 停止空间查询
- (void)stopTask;

@end
