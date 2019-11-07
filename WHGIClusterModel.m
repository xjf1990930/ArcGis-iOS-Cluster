//
//  WHGIClusterModel.m
//  WHGIWitFirePost
//
//  Created by 徐俊峰 on 2019/11/4.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import "WHGIClusterModel.h"
#import "WHGIClusterTask.h"
#import "WHGIBlockTask.h"

@interface WHGIClusterModel ()

@property (nonatomic, strong, readwrite) AGSEnvelope *referEnv;
@property (nonatomic, strong) NSArray<NSString *> *clustLayerIDs;
@property (nonatomic, strong) AGSGraphicsLayer *clusterLayer;
@property (nonatomic, strong) WHGIBlockTask *taskQueue;
@property (nonatomic, strong) NSArray<WHGIClusterTask *> *tasks;
@property (nonatomic, assign) BOOL taskQueueExcuting;

@end

@implementation WHGIClusterModel

- (instancetype)initWithEnvlope:(AGSEnvelope *)env andClustLayer:(AGSGraphicsLayer *)clustLayer andClustLayerIDs:(NSArray<NSString *> *)clustLayerIDs {
    if (self = [super init]) {
        self.referEnv = env;
        self.clusterLayer = clustLayer;
        self.clustLayerIDs = clustLayerIDs;
    }
    return self;
}

- (void)startClusterTask {
    if (self.taskQueueExcuting) {
        return;
    }
    if (self.clustLayerIDs.count<0) {
        return;
    }
    self.taskQueueExcuting = YES;
    __weak __typeof(self)weakSelf = self;
    [self.taskQueue taskObjects:self.tasks andTaskExecute:^(WHGIClusterTask *executeObject, void (^nextCall)(BOOL success, NSArray *recordObjects)) {
        [executeObject clustWithEnvlope:weakSelf.referEnv andCall:^(BOOL success, NSArray<AGSGraphic *> *allResults) {
            if (allResults) {
                if (nextCall) {
                    nextCall(success,allResults);
                }
            }else{
                if (nextCall) {
                    nextCall(success,@[]);
                }
            }
        }];
    } complete:^(BOOL success, NSArray *allRecordObjects, NSError *error) {
        [weakSelf operateWithCallDatas];
        self.taskQueueExcuting = NO;
    }];
}
- (void)stopClusterTask {
    self.clusterLayer = nil;
    [self.tasks makeObjectsPerformSelector:@selector(stopTask)];
    self.tasks = nil;
}
- (void)operateWithCallDatas {
    if (self.clustLayerIDs.count>0) {
        [self displayClust];
    }
    
}
- (void)displayClust {
    
    if (self.clusterLayer == nil) {
        return;
    }
    
    NSMutableArray *tempGraphics = [NSMutableArray new];
    
    for (WHGIClusterTask *taskModel in self.tasks) {
        if (!taskModel.marked && taskModel.clustSuccess) {//已经在底图上显示过了就不会再处理一次
            [tempGraphics addObjectsFromArray:taskModel.allResults];
            taskModel.marked = YES;
        }
    }
    
    if (tempGraphics.count<=0) {
        return;
    }
    
    NSArray<AGSGraphic *>* graphics = tempGraphics;
    NSMutableArray<AGSGraphic *>* showGraphics = [NSMutableArray new];
    if (graphics.count>0) {
        if (graphics.count>3) {
            [showGraphics addObject:[AGSGraphic graphicWithGeometry:graphics.firstObject.geometry symbol:[self textSymbol:[NSString stringWithFormat:@"%@",@(graphics.count)]] attributes:nil]];
        }else{
            //小于三个，则每个graphic单独显示
            for (AGSGraphic *singleShowGraphic in graphics) {
                
                for (WHGIClusterTask *taskModel in self.tasks) {
                    if ([taskModel.allResults containsObject:singleShowGraphic]) {
                        [showGraphics addObject:[AGSGraphic graphicWithGeometry:singleShowGraphic.geometry symbol:[self pictureSymbolWithLayerID:taskModel.layerID] attributes:nil]];
                        break;
                    }
                }
            }
        }
        [self.clusterLayer addGraphics:showGraphics];
    }
}
#pragma mark - getter
- (AGSSymbol *)textSymbol:(NSString *)number {
    
    AGSCompositeSymbol*composite = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleMarkerSymbol *pointMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    pointMarkerSymbol.color = kMainColor;
    pointMarkerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
    pointMarkerSymbol.size = CGSizeMake(30, 30);
    [composite addSymbol:pointMarkerSymbol];
    
    AGSTextSymbol *textSymbol = [[AGSTextSymbol alloc] initWithText:[NSString stringWithFormat:@"%@",number] color:[UIColor whiteColor]];
    textSymbol.fontSize = 12.0;
    textSymbol.fontFamily = @"Heiti SC";
    textSymbol.bold = NO;
//    textSymbol.borderLineColor = [UIColor blackColor];
//    textSymbol.borderLineWidth = 1.0;
    [composite addSymbol:textSymbol];
    
    return composite;
}
- (AGSPictureMarkerSymbol *)pictureSymbolWithLayerID:(NSString *)layerID {
    AGSPictureMarkerSymbol *result = nil;
    NSArray *layerIDs = pWHGIClustLayerIDs;
    if (![layerIDs containsObject:layerID]) {
        return result;
    }
    NSArray *imageNames = pWHGIClustLayerSymbolImageNames;
    result = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:[imageNames objectAtIndex:[layerIDs indexOfObject:layerID]]]];
    return result;
}
//- (NSArray<WHGIClusterTask *> *)tasks {
//    if (nil == _tasks) {
//        _tasks = @[[[WHGIClusterTask alloc] initWithLayerID:@"0"],
//        [[WHGIClusterTask alloc] initWithLayerID:@"2"],
//        [[WHGIClusterTask alloc] initWithLayerID:@"3"],
//        [[WHGIClusterTask alloc] initWithLayerID:@"4"],
//        [[WHGIClusterTask alloc] initWithLayerID:@"6"],
//        [[WHGIClusterTask alloc] initWithLayerID:@"7"],
//        [[WHGIClusterTask alloc] initWithLayerID:@"8"]];
//    }
//    return _tasks;
//}
- (WHGIBlockTask *)taskQueue {
    if (nil == _taskQueue) {
        _taskQueue = [[WHGIBlockTask alloc] init];
    }
    return _taskQueue;
}
- (NSArray<WHGIClusterTask *> *)tasks {
    if (nil == _tasks) {
        NSMutableArray *clustTasks = [NSMutableArray new];
        for (NSString *clustID in self.clustLayerIDs) {
            [clustTasks addObject:[[WHGIClusterTask alloc] initWithLayerID:clustID]];
        }
        _tasks = [NSArray arrayWithArray:clustTasks];
    }
    return _tasks;
}
@end
