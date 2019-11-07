//
//  WHGIClusterTask.m
//  WHGIWitFirePost
//
//  Created by 徐俊峰 on 2019/11/5.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import "WHGIClusterTask.h"
#import <ArcGIS/AGSQueryTask.h>
#import <ArcGIS/AGSQuery.h>
#import <ArcGIS/AGSSpatialReference.h>
#import <ArcGIS/AGSEnumerations.h>
#import <ArcGIS/AGSEnvelope.h>
#import <ArcGIS/AGSFeatureSet.h>

@interface WHGIClusterTask ()<AGSQueryTaskDelegate>

@property (nonatomic, strong) AGSQueryTask *queryTask;
@property (nonatomic, strong) NSOperation *currentOperation;

@property (nonatomic, assign, readwrite) BOOL clustSuccess;

@property (nonatomic, strong, readwrite) NSArray*allResults;
@property (nonatomic, copy, readwrite) NSString *layerID;

@property (nonatomic, copy) void(^resultCall)(BOOL success,NSArray<AGSGraphic *> *allResults);



@end

@implementation WHGIClusterTask
- (instancetype)initWithLayerID:(NSString *)layerID {
    if (self = [super init]) {
        self.layerID = layerID;
    }
    return self;
}
- (void)clustWithEnvlope:(AGSEnvelope *)env andCall:(void(^)(BOOL success,NSArray<AGSGraphic *> *allResults))callBack {
    if (nil == self.currentOperation || self.currentOperation.finished) {
        if (self.clustSuccess == NO) {
            self.resultCall = callBack;
            self.queryTask = [[AGSQueryTask alloc] initWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@/%@",[WHGIDataSwitch mapDynamicLayerURLForType:[WHGIDataSwitch currentType]],self.layerID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            AGSQuery *queryObject = [[AGSQuery alloc] init];
            queryObject.geometry = env;
            queryObject.whereClause = @"1=1";
            queryObject.outFields = @[@"*"];
            queryObject.returnGeometry = YES;
            queryObject.outSpatialReference = env.spatialReference;
            queryObject.spatialRelationship = AGSSpatialRelationshipContains;
            self.queryTask.delegate = self;
            self.currentOperation = [self.queryTask executeWithQuery:queryObject];
        }else{
            if (callBack) {
                callBack(YES,self.allResults);
            }
        }
    }else{
        if (callBack) {
            callBack(NO,nil);
        }
    }
}
- (void)stopTask {
    self.resultCall = nil;
    self.queryTask.delegate = nil;
    if (self.currentOperation.executing) {
        [self.currentOperation cancel];
    }
}
#pragma mark - QueryTask代理
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.clustSuccess = YES;
        self.allResults = [NSArray arrayWithArray:featureSet.features];
        if (self.resultCall) {
            self.resultCall(YES, self.allResults);
        }
    });
}
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didFailWithError:(NSError *)error {
    if (self.resultCall) {
        self.resultCall(NO, nil);
    }
}
- (void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation*)op didExecuteWithRelatedFeatures:(NSDictionary *)relatedFeatures {
    
}
@end
