#import "AppDelegate.h"
#import <HealthKit/HealthKit.h>

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Before using the API, we need to check if HealthKit is available in the device, since it is not supported in all ios devices.
    if(NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable])
    {
        //Once we made sure that the device supports HealhtKit we create a HKHealthStore instance
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        
        //We create a set of the types tat we are interested in reading
        NSSet *readObjectTypes  = [NSSet setWithObjects:
                                   [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount], nil];
        
        //Permission request for reading those types of data.
        //Since we are only requesting read permissions we provide nil for ShareTypes.
        [healthStore requestAuthorizationToShareTypes:nil readTypes:readObjectTypes completion:^(BOOL success, NSError * _Nullable error) {
            // we make sure the authentication was succesful
            if(!error) {
                //once the user grants us permission to read steps we create a query object to query for todays steps by creating a predicate that refines the query for today samples
                NSDate *beginningOfToday = [self beginningOfToday];
                NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:beginningOfToday endDate:[NSDate date] options:HKQueryOptionStrictStartDate];
                
                // we create a steps quantity type object and use it to initialize the query
                HKQuantityType *stepsQuantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                
                // we limit the query to return 500 sample object max
                HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:stepsQuantityType predicate:predicate limit:500 sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
                    
                    //we make sure the query executed succesfully
                    if(!error) {
                        // in the results object we obtain all the steps samples saved by any source for steps
                        NSLog(@"Today steps samples: %@", results);
                    }
                }];
                
                // we execute the query with the healthstore object
                [healthStore executeQuery:sampleQuery];
            }
        }];
        
    }
    
    return YES;
}

- (NSDate *)beginningOfToday {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    return [calendar dateFromComponents:components];
}
@end
