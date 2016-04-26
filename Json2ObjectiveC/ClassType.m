//
//  ClassType.m
//  Json2ObjectiveC
//
//  Created by Netease on 16/1/5.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "ClassType.h"

@implementation ClassType
-(instancetype)initWithName:(NSString *)name{
    self = [super init];
    if (self != nil) {
        self.name = name;
        self.properties = [[NSMutableArray alloc] init];
        self.propertyDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name value:(NSString *) value {
    self = [super init];
    if (self != nil) {
        self.name = name;
        self.value = value;
        self.properties = [[NSMutableArray alloc] init];
        self.propertyDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addProperty:(Property *)property{
    if (property == nil) {
        return;
    }
    
    [self.properties addObject:property];
    [self.propertyDic setObject:property forKey:property.name];
}

- (NSString *)parseClassInterface{
    NSString *interface = [NSString stringWithFormat:@"\n@protocol %@ @end\n@interface %@ : JSONModel\n", self.name,self.name];
    
    for (Property *property in self.properties) {
        NSString *secondType = @"";
        NSString *propertyType = @"";
        switch (property.pType) {
            case STRING:
                secondType = @"copy";
                propertyType = @"NSString *";
                break;
            case NUMBER:
                secondType = @"assign";
                propertyType = @"NSNumber* ";
                break;
            default:
                secondType = @"strong";
                if (property.classType == nil) {
                    propertyType = @"id ";
                }
                else
                {
                    propertyType = [property.classType stringByAppendingString:@" *"];
                }
                break;
        }
        NSRange range = [propertyType rangeOfString:@"_"];
        if (range.location != NSNotFound) {

            NSString *propertyTypeTmp = [propertyType substringWithRange:NSMakeRange(0, range.location)];
            if ([propertyTypeTmp rangeOfString:@"ListClass"].location != NSNotFound) {
                //发现数组形
                propertyType = [propertyType substringWithRange:NSMakeRange(0, propertyType.length - 2)];
                propertyType = [NSString stringWithFormat:@"NSArray<%@> *", propertyType];
            } else if ([propertyTypeTmp rangeOfString:@"Class"].location != NSNotFound) {

            } else {
                NSString *zsStr = [NSString stringWithFormat:@"/* %@ */ \n", property.value];
                interface = [interface stringByAppendingString:zsStr];
            }

        } else {
            NSString *zsStr = [NSString stringWithFormat:@"/* %@ */ \n", property.value];
            interface = [interface stringByAppendingString:zsStr];
        }
        NSString *pStr = [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;\n", secondType, propertyType, property.name];
        interface = [interface stringByAppendingString:pStr];
    }
    
    interface = [interface stringByAppendingString:@"@end\n"];
    return interface;
}
-(NSString *)parseClassImplementation{
    NSString *implement = [NSString stringWithFormat:@"\n@implementation %@\n+(JSONKeyMapper*)keyMapper{\nreturn\n [[JSONKeyMapper alloc] initWithDictionary:@{\n", self.name];
    
    NSString *transformerFuncs = @"";
    
    NSString *dicStr = @"";
    for (Property *property in self.properties) {
        if (![dicStr isEqualToString:@""]) {
            dicStr = [dicStr stringByAppendingString:@",\n"];
        }
        dicStr = [dicStr stringByAppendingString:[NSString stringWithFormat:@"@\"%@\":@\"%@\"", property.name, property.name]];
        
        if (property.pType == DICTIONARY) {
            NSString *transFunc = [NSString stringWithFormat:@"\n+(NSValueTransformer *)%@JSONTransformer\n{\nreturn [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dict) {\n%@* obj = [MTLJSONAdapter modelOfClass:[%@ class] fromJSONDictionary:dict error:nil];\nreturn obj;\n}];\n}\n", property.name, property.classType, property.classType];
            
//            transformerFuncs = [transformerFuncs stringByAppendingString:transFunc];
        }
        if (property.pType == ARRAY) {
            NSString *transFunc = [NSString stringWithFormat:@"\n+(NSValueTransformer *)%@JSONTransformer\n{\nreturn [MTLValueTransformer transformerWithBlock:^id(NSArray *array) {\nNSMutableArray *temp = [[NSMutableArray alloc] init];\nfor (id obj in array) {\nif ([obj isKindOfClass:[NSDictionary class]]) {\n%@ * c = [MTLJSONAdapter modelOfClass:[%@ class] fromJSONDictionary:obj error:nil];\n[temp addObject:c];\n}else{\n[temp addObject:obj];\n}\n}\nreturn temp;\n}];\n}\n", property.name, property.classType, property.classType];
//            transformerFuncs = [transformerFuncs stringByAppendingString:transFunc];
        }
    }
    implement = [implement stringByAppendingString:dicStr];
    implement = [implement stringByAppendingString:@"\n}];\n}"];
    implement = [implement stringByAppendingString:transformerFuncs];
    implement = [implement stringByAppendingString:@"@end"];
    return implement;
}
@end
