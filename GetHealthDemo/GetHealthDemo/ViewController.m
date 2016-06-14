//
//  ViewController.m
//  GetHealthDemo
//
//  Created by 蒋一博 on 16/6/13.
//  Copyright © 2016年 JiangYibo. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()

/** healthKit属性对象 */
@property (strong ,nonatomic) HKHealthStore *health;




@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeDataSource];
    
    [self initializeInterface];
    
}

- (void)initializeDataSource{
    
    _health = [[HKHealthStore alloc]init];
    
    BOOL available = [HKHealthStore isHealthDataAvailable];
    NSLog(@"available:%d",available);
    
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSet *set = [NSSet setWithObject:type];
    
    [_health requestAuthorizationToShareTypes:nil readTypes:set completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"success");
            [self readStepData];
            //[self readCalorie];
        }else{
            NSLog(@"fail");
        }
    }];
    
}

- (void)initializeInterface{
    
    

    
}

/**
 *   读取步数
 */
- (void)readStepData{
    
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];//获取数据类型：步数
    
    //过滤条件
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    

    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    //开始日期
    NSDate *startDate = [calendar dateFromComponents:components];
    //结束日期
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    
    NSPredicate *predicate = [HKQuery  predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    
    HKObserverQuery *query = [[HKObserverQuery alloc]initWithSampleType:type predicate:nil updateHandler:^(HKObserverQuery * _Nonnull query, HKObserverQueryCompletionHandler  _Nonnull completionHandler, NSError * _Nullable error) {
        
        HKStatisticsQuery *sQuery = [[HKStatisticsQuery alloc]initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
            
            HKQuantity *quantity = result.sumQuantity;
            
            NSInteger stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
            
            
            NSLog(@"stepCount-%ld",stepCount);
            

        }];
        
        [_health executeQuery:sQuery];
        
    }];
    
    [_health executeQuery:query];
    
    
    
}

- (void)readCalorie{

    HKQuantityType *calorieType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];//获取数据类型：能量
    
    //过滤条件
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *component = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now ];
    
    //开始日期
    NSDate *startDate = [calendar dateFromComponents:component];
    //结束日期
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    NSPredicate *predicate = [HKQuery  predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    HKObserverQuery *query = [[HKObserverQuery alloc]initWithSampleType:calorieType predicate:nil updateHandler:^(HKObserverQuery * _Nonnull query, HKObserverQueryCompletionHandler  _Nonnull completionHandler, NSError * _Nullable error) {
        
        HKStatisticsQuery *sQuery = [[HKStatisticsQuery alloc]initWithQuantityType:calorieType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
            
            HKQuantity *quantity = result.sumQuantity;
            
            NSInteger calorieCount = [quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
            
            NSLog(@"calorieCount-%ld",calorieCount);
            
        }];
        
        [_health executeQuery:sQuery];
        
    }];
    
    [_health executeQuery:query];
    
    

}

/*
 HKQuantityTypeIdentifierStepCount －－步数
 HKQuantityTypeIdentifierDistanceWalkingRunning －－步行＋跑步距离
 
 HKQuantityTypeIdentifierHeartRate －－心率
 
 
 */



@end
