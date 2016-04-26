//
//  Property.m
//  Json2ObjectiveC
//
//  Created by Netease on 16/1/5.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "Property.h"

@implementation Property
- (instancetype)initWithName:(NSString *)name
                        type:(enum PropertyType)type
                   classType:(NSString *)cType value:(NSString *) cvalue {
    self = [super init];
    if (self != nil) {
        self.name = name;
        self.pType = type;
        self.value = cvalue;
        if (cType != nil) {
            self.classType = cType;
        }
    }
    return self;
}
@end
