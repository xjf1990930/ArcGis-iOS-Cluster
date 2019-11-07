//
//  WHGIBlockTask.m
//  WHGIOneMap
//
//  Created by 徐俊峰 on 2019/10/12.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import "WHGIBlockTask.h"

@interface WHGIBlockTask ()

@property (nonatomic, strong) NSArray *taskObjects;
@property (nonatomic, copy) void(^nextCall)(BOOL success,NSArray*recordObjects);
@property (nonatomic, copy) void(^completeCall)(BOOL success,NSArray *allRecordObjects,NSError *error);
@property (nonatomic, copy) void(^executeCall)(id executeObject,void(^nextCall)(BOOL success,NSArray*recordObjects));
@property (nonatomic, strong) NSMutableArray *resultObjects;
@property (nonatomic, assign) NSInteger indexCount;
@property (nonatomic, assign) NSInteger taskFaildCount;
@end

@implementation WHGIBlockTask


- (void)taskObjects:(NSArray*)objects andTaskExecute:(void(^)(id executeObject,void(^nextCall)(BOOL success,NSArray*recordObjects)))execute complete:(void(^)(BOOL success,NSArray *allRecordObjects,NSError *error))complete {
    
    self.indexCount = 0;
    self.taskObjects = objects;
    if (self.indexCount>=self.taskObjects.count) {
        //此处说明没有任务对象进来
        if (self.completeCall) {
            self.completeCall(YES, nil, nil);
        }
        return;
    }
    
    self.resultObjects = [NSMutableArray new];
    self.taskFaildCount = 0;
    self.completeCall = complete;
    self.executeCall = execute;
    __weak __typeof(self)weakSelf = self;
    self.nextCall = ^(BOOL success, NSArray *recordObjects) {
        if (success) {
            [weakSelf.resultObjects addObjectsFromArray:recordObjects];
        }else{
            weakSelf.taskFaildCount += 1;
        }
        weakSelf.indexCount += 1;
        if (weakSelf.indexCount>=weakSelf.taskObjects.count) {
            //说明任务结束
            if (0 == weakSelf.taskFaildCount) {
                if (weakSelf.completeCall) {
                    weakSelf.completeCall(YES, (NSArray*)weakSelf.resultObjects, nil);
                }//全部成功
            }else if (weakSelf.taskFaildCount == weakSelf.taskObjects.count) {
                if (weakSelf.completeCall) {
                    weakSelf.completeCall(NO, (NSArray*)weakSelf.resultObjects, [NSError errorWithDomain:@"WHGI" code:-1001 userInfo:@{@"msg":@"任务全部失败"}]);
                }//全部失败
            }else{
                if (weakSelf.completeCall) {
                    weakSelf.completeCall(YES, (NSArray*)weakSelf.resultObjects, [NSError errorWithDomain:@"WHGI" code:-1002 userInfo:@{@"msg":@"任务部分失败"}]);
                }//部分失败
            }
            
        }else{
            //说明还有任务执行，继续
            if (weakSelf.executeCall) {
                weakSelf.executeCall(objects[weakSelf.indexCount], weakSelf.nextCall);
            }
            
        }
    };
    if (self.executeCall) {
        self.executeCall(objects.firstObject,self.nextCall);
    }
    
}

@end
