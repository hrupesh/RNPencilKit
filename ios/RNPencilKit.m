//
//  RNPencilKit.m
//  RNPencilKit
//
//  Created by Rupesh Chaudhari on 12/08/23.
//

#import "RNPencilKit.h"
#import <Foundation/Foundation.h>
#import <PencilKit/PencilKit.h>

NSString *const kDrawingData = @"KDrawingData";

@implementation RNPencilKit

-(id)init {
    self = [super init];
    if (self) {
        _drawingData = nil;
    }
    return self;
}

+ (RNPencilKit *)sharedInstance {
    static RNPencilKit *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    
    dispatch_once(&onceSecurePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void) saveData {
  [[NSUserDefaults standardUserDefaults] setObject:[NSData dataWithData:self.drawingData] forKey:kDrawingData];
  [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void) loadData {
    if([[NSUserDefaults standardUserDefaults] objectForKey:kDrawingData]) {
      self.drawingData = [[NSUserDefaults standardUserDefaults] objectForKey:kDrawingData];
    } else {
        self.drawingData = nil;
    }
}

@end
