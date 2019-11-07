//
//  WHGIBlockTask.h
//  WHGIOneMap
//
//  Created by 徐俊峰 on 2019/10/12.
//  Copyright © 2019 WHGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHGIBlockTask : NSObject

/// block队列任务执行（注意，该类实例可以复用，但是前提是要在前一个队列任务结束后）
/// @param objects 需要循环执行block任务的所有对象
/// @param execute 单个对象执行任务
/// @param complete 所有队列任务完成回调
- (void)taskObjects:(NSArray*)objects andTaskExecute:(void(^)(id executeObject,void(^nextCall)(BOOL success,NSArray*recordObjects)))execute complete:(void(^)(BOOL success,NSArray *allRecordObjects,NSError *error))complete;

@end
