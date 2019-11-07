//
//  WHGIClusterManager.m
//  WHGIWitFirePost
//
//  Created by 徐俊峰 on 2019/11/4.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import "WHGIClusterManager.h"
#import "WHGIClusterModel.h"

@interface WHGIClusterManager ()
@property (nonatomic, strong) AGSMapView *mapView;

@property (nonatomic, strong) AGSGraphicsLayer *clusterLayer;
@property (nonatomic, strong) AGSQueryTask *queryTask;
@property (nonatomic, strong) NSMutableArray<WHGIClusterModel *> *clusterModels;
@property (nonatomic, strong) NSArray<NSString *> *clustLayerIDs;

@end

@implementation WHGIClusterManager
- (instancetype)initWithMapView:(AGSMapView *)mapView {
    if (self = [super init]) {
        self.mapView = mapView;
        //添加聚合图层
        self.clusterLayer = [[AGSGraphicsLayer alloc] initWithFullEnvelope:self.mapView.maxEnvelope];
        [self.mapView addMapLayer:self.clusterLayer withName:@"clusterLayer"];
        //聚合时监听地图缩放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewDidEndZoomAction:) name:AGSMapViewDidEndZoomingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewDidEndDragAction:) name:AGSMapViewDidEndPanningNotification object:nil];
    }
    return self;
}
- (void)mapViewDidEndDragAction:(NSNotification *)noti {
    [self continueClust];
}
- (void)mapViewDidEndZoomAction:(NSNotification *)noti {
    [self clusterOverAgain];
}
#pragma mark - 聚合处理
- (void)clusterOverAgain {//当缩放等级变化时重新聚合
    [self.clusterModels makeObjectsPerformSelector:@selector(stopClusterTask)];
    self.clusterModels = [NSMutableArray new];
    [self.clusterLayer removeAllGraphics];
    [self.mapView.superview layoutIfNeeded];
    
    NSArray *needClustEnvs = [self currentScreenClusterEnvlopes];
    
    for (AGSEnvelope *env in needClustEnvs) {
        WHGIClusterModel *clustModel = [[WHGIClusterModel alloc] initWithEnvlope:env andClustLayer:self.clusterLayer andClustLayerIDs:self.clustLayerIDs];
        [self.clusterModels addObject:clustModel];
    }
    [self.clusterModels makeObjectsPerformSelector:@selector(startClusterTask)];
}
- (void)continueClust {
    NSArray *needClustEnvs = [self currentScreenClusterEnvlopes];//已经去重了
    
    for (AGSEnvelope *env in needClustEnvs) {
        WHGIClusterModel *clustModel = [[WHGIClusterModel alloc] initWithEnvlope:env andClustLayer:self.clusterLayer andClustLayerIDs:self.clustLayerIDs];
        [self.clusterModels addObject:clustModel];
    }
    [self.clusterModels makeObjectsPerformSelector:@selector(startClusterTask)];
}
- (NSMutableArray *)currentScreenClusterEnvlopes {
    
    NSUInteger cluster_X = 3;//取当前屏幕三分之一宽为聚合最小单元的宽
    NSUInteger cluster_Y = 4;//取当前屏幕四分之一高为聚合最小单元的高
    
    AGSEnvelope *clipTemp = [self.mapView toMapEnvelope:CGRectMake(0, 0, self.mapView.frame.size.width/cluster_X, self.mapView.frame.size.height/cluster_Y)];
    
    AGSEnvelope *currentScreenEnv = [self.mapView toMapEnvelope:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    AGSPoint *startPoint = [AGSPoint pointWithX:self.mapView.maxEnvelope.xmin y:self.mapView.maxEnvelope.ymin spatialReference:self.mapView.spatialReference];
    //参照当前地图最大范围的最小x个y坐标作为原点，计算出当前屏幕地图范围所有的聚合单元
    NSUInteger env_minX = floor((currentScreenEnv.xmin - startPoint.x)/clipTemp.width);
    NSUInteger env_minY = floor((currentScreenEnv.ymin - startPoint.y)/clipTemp.height);
    
    NSMutableArray *allEnvs = [NSMutableArray new];
    AGSEnvelope *tempEnv = nil;
    for (NSUInteger i = 0; i<=cluster_X; i++) {
        for (NSUInteger j = 0; j<=cluster_Y; j++) {
            tempEnv = [[AGSEnvelope alloc] initWithXmin:startPoint.x+(i+env_minX)*clipTemp.width ymin:startPoint.y+(j+env_minY)*clipTemp.height xmax:startPoint.x+(i+1+env_minX)*clipTemp.width ymax:startPoint.y+(j+1+env_minY)*clipTemp.height spatialReference:self.mapView.spatialReference];
            BOOL contains = NO;
            for (WHGIClusterModel *clustModel in self.clusterModels) {
                if ([clustModel.referEnv isEqualToEnvelope:tempEnv]) {
                    contains = YES;
                    break;
                }
            }
            if (!contains) {
                [allEnvs addObject:tempEnv];
            }
        }
    }
    
    return allEnvs;
}
#pragma mark - setter
- (void)setClustLayerIDs:(NSArray<NSString *> *)layerIDs {
    _clustLayerIDs = layerIDs;
    if (layerIDs.count<=0) {
        [self.clusterLayer removeAllGraphics];
    }else{
        [self clusterOverAgain];
    }
    
}
#pragma mark - 销毁
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
