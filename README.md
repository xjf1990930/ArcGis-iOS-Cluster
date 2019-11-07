# ArcGis-iOS-Cluster
基于Arcgis for iOS 10.25版本的聚合功能实现

用法：
将所有文件下载拖入自己的工程项目，导入WHGIClusterManager并使用以下两个方法

/// 初始化
/// @param mapView 地图视图
- (instancetype)initWithMapView:(AGSMapView *)mapView;


/// 重新设置需要聚合的图层id，调用这个方法就会重新加载聚合图形
/// @param layerIDs 需要聚合的图层id
- (void)setClustLayerIDs:(NSArray<NSString *> *)layerIDs;


然后要设置好类文件WHGIClusterTask以下几个宏：

//图层服务地址
#define pWHGIClustLayerService @""
//需要被聚合的图层ID
#define pWHGIClustLayerIDs @[@"0",@"2",@"3",@"4",@"6",@"7",@"8"]
//各个聚合的图层ID当无法聚合时使用的符号图片名
#define pWHGIClustLayerSymbolImageNames @[@"image0",@"image2",@"image3",@"image4",@"image6",@"image7",@"image8"];
