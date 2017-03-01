//
//  EXRCustomTextField+Formatter.m
//  ExchangeRate
//
//  Created by 曹文兵 on 2017/2/26.
//  Copyright © 2017年 bbyz. All rights reserved.
//

#import "EXRCustomTextField+Formatter.h"

static NSString *const addStr =  @"+";
static NSString *const minStr =  @"−";
static NSString *const multiStr =  @"×";
static NSString *const divideStr =  @"÷";
static const NSInteger defaultStrLength = 13;

@implementation EXRCustomTextField (Formatter)

#pragma mark - string formatter

- (BOOL)legalInput:(NSString *)title {
    BOOL stop = NO;
    NSString *str = [self p_removeCommaSepatator:self.text];
    
    //illegal input judge
    if (title == nil) {
        if (str.length == 0) {
            stop = YES;
        }
        
    } else if ([title isEqualToString:@"."]){
        if ([str containsString:@"."]) {
            stop = YES;         //".."
        }
        
    } else {
        if ([str isEqualToString:@"0"] && [title isEqualToString:@"0"]) {
            stop = YES;         //"00"
            
        } else if ([str containsString:@"."]) {
            if (str.length > 3) {
                str = [str substringToIndex:str.length - 4];
                if ([str containsString:@"."]) {
                    stop = YES;        //decimals number illegal
                }
            }
            
        } else if (str.length >= defaultStrLength) {
            stop = YES;                 //str.length illegal
        }
    }
    
    return stop;
}

- (void)textInput:(NSString *)title {
    NSString *str = self.text;
    if (title == nil) {
        if (str.length == 1){
            self.text = nil;
        } else if (str.length > 1) {
            self.text = [str substringToIndex:str.length - 1];
        }
        return;
    }
    
    if (str.length == 0) {
        if ([title isEqualToString:@"."]) {
            self.text = @"0.";
        } else {
            self.text = title;
        }
        
    } else if ([str isEqualToString:@"0"] && ![title isEqualToString:@"."]) {
        self.text = title;
    } else {
        self.text = [str stringByAppendingString:title];
    }
    
    if (self.text.length >= 3) {
        self.text = [self setStringFormat:self.text];
    }
}

- (NSString *)setStringFormat:(NSString *)string {
    NSString *newString = string;
    BOOL negative = NO;
    if ([string containsString:@"-"]) {
        negative = YES;
        newString = [newString substringFromIndex:1];
    }
    
    if ([newString containsString:@"."]) {
        NSRange range = [newString rangeOfString:@"."];
        NSInteger index = range.length + range.location - 1;
        NSString * integerStr = [newString substringToIndex:index];
        NSString * decimalsStr = [newString substringFromIndex:index];
        
        NSString *str = [self p_setStringWithIntegerFormat:integerStr];
        if (negative) {
            str = [@"-" stringByAppendingString:str];
        }
        return [str stringByAppendingString:decimalsStr];
        
    } else {
        NSString *str = [self p_setStringWithIntegerFormat:newString];
        if (negative) {
            str = [@"-" stringByAppendingString:str];
        }
        return str;
    }
}

- (NSString *)p_setStringWithIntegerFormat:(NSString *)string {
    NSMutableString *str = [[self p_removeCommaSepatator:string] mutableCopy];
    
    if (str.length > 3) {
        [str insertString:@"," atIndex:str.length - 3];
    }
    
    if (str.length > 7) {
        [str insertString:@"," atIndex:str.length - 7];
    }
    
    if (str.length > 11) {
        [str insertString:@"," atIndex:str.length - 11];
    }
    
    if (str.length > 15) {
        [str insertString:@"," atIndex:str.length - 15];
    }
    return str;
}

- (NSString *)p_removeCommaSepatator:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@"," withString:@""];
}

- (NSString *)adjustDecimalsWith:(NSString *)string {
    if (![string containsString:@"."]) {
        return string;
    }
    
    NSString *str = string;
    NSRange range = [str rangeOfString:@"."];
    NSInteger index = range.length + range.location;
    BOOL haveChar = NO;
    
    for (NSInteger i = index; i < str.length; i++) {
        unichar cha = [str characterAtIndex:i];
        if (cha > '0') {
            index = i;
            haveChar = YES;
        }
    }
    
    if (!haveChar) {
        index = index - 2;
    }
    return [str substringToIndex:index + 1];
}

#pragma mark - calculate


- (NSInteger)calculateDecimalsNum:(NSString *)string {
    NSInteger num = 0;
    if ([string containsString:@"."]) {
        NSRange range = [string rangeOfString:@"."];
        num = string.length - range.location - 1;
    }
    return num;
}


- (double)calculateTextValueWithInput:(NSString *)title {
    NSArray *array = @[addStr, minStr, multiStr, divideStr];
    NSString *str = self.text;
    NSString *lastCal = nil;
    NSRange range;
    range.length = 1;
    
    for (NSInteger index = str.length - 1; index >= 0; index--) {
        range.location = index;
        lastCal = [str substringWithRange:range];
        
        if ([array containsObject:lastCal]) {
            break;
        }
    }
    
    if (range.location == str.length - 1) {
        str = [str substringToIndex:str.length - 2];
        
    } else {
        NSString *lastStr = [str substringFromIndex:range.location + 1];
        if ([lastStr doubleValue] == 0) {
            str = [str substringToIndex:range.location - 1];
        }
    }
    
    NSArray *addArray = [str componentsSeparatedByString:addStr];
    double resultValue = 0;
    
    for (NSString *str0 in addArray) {
        NSArray *minArray = [str0 componentsSeparatedByString:minStr];
        double value0 = 0;
        
        for (NSInteger index1 = 0; index1 < minArray.count; index1++) {
            NSString *str1 = minArray[index1];
            NSArray *multiArray = [str1 componentsSeparatedByString:multiStr];
            double value1 = 0;
            
            for (NSInteger index2 = 0; index2 < multiArray.count; index2++) {
                NSString *str2 = multiArray[index2];
                NSArray *diviArray = [str2 componentsSeparatedByString:divideStr];
                double value2 = 0;
                
                for (NSInteger index3 = 0; index3 < diviArray.count; index3++) {
                    NSString *str3 = diviArray[index3];
                    
                    if (index3 == 0) {
                        value2 = [str3 doubleValue];
                    } else {
                        if ([str3 doubleValue]) {
                            value2 /= [str3 doubleValue];
                        }
                    }
                }
                
                if (index2 == 0) {
                    value1 = value2;
                } else {
                    value1 *= value2;
                }
            }
            
            if (index1 == 0) {
                value0 = value1;
            } else {
                value0 -= value1;
            }
        }
        resultValue += value0;
    }
    
    if (fabs(resultValue)  < 0.00001) {
        resultValue = 0;
    }
    return resultValue;
}


- (BOOL)setCalculateTextWith:(NSString *)title {
    NSArray *array = @[addStr, minStr, multiStr, divideStr];
    NSString *str = self.text;
    
    if (str.length == 0) {
        self.text = [@"0" stringByAppendingString:[NSString stringWithFormat:@" %@", title]];
        return YES;
    }
    
    NSString *lastCal = nil;
    NSRange range;
    range.length = 1;
    for (NSInteger index = str.length - 1; index >= 0; index--) {
        range.location = index;
        lastCal = [str substringWithRange:range];
        
        if ([array containsObject:lastCal]) {
            break;
        }
    }
    
    if (title == nil) {
        NSString *lastChar = [str substringFromIndex:str.length - 2];
        if ([lastChar containsString:@" "]) {
            self.text = [str substringToIndex:str.length - 2];
        } else {
            self.text = [str substringToIndex:str.length - 1];
        }
        
        BOOL haveOperator = NO;
        for (NSString *str in array) {
            if ([self.text containsString:str]) {
                haveOperator = YES;
                break;
            }
        }
        
        if (!haveOperator) {
            self.text = nil;
        }
        
        return YES;
    }
    
    //don't have operator
    if (range.location == 0) {
        self.text = [str stringByAppendingString:[NSString stringWithFormat:@" %@", title]];
        return YES;
    }
    
    //last char is operator
    if (range.location == str.length - 1) {
        if ([array containsObject:title]) {
            NSString *priorStr = [str substringToIndex:str.length - 1];
            self.text = [priorStr stringByAppendingString:title];
            
        } else if ([title isEqualToString:@"."]) {
            self.text = [str stringByAppendingString:@" 0."];
            
        } else {
            self.text = [str stringByAppendingString:[NSString stringWithFormat:@" %@", title]];
        }
        return YES;
    }
    
    //have operator and isn't the last char
    NSString *lastStr = [str substringFromIndex:range.location + 1];
    
    if ([title isEqualToString:@"."]) {
        if ([lastStr containsString:@"."]) {            //".."
            return NO;
        } else {
            self.text = [str stringByAppendingString:@"."];
            return YES;
        }
    }
    
    if ([title isEqualToString:@"0"] && [lastStr isEqualToString:@"0"]) {           //"00"
        return NO;
    }
    
    if ([array containsObject:title]) {
        if ([lastCal isEqualToString:divideStr] && [lastStr floatValue] == 0) {     //"/0"
            return NO;
        }
        
        NSString *last = [lastStr substringFromIndex:lastStr.length - 1];
        if ([last isEqualToString:@"."]) {
            lastStr = [str substringToIndex:str.length - 1];
            self.text = [lastStr stringByAppendingString:[NSString stringWithFormat:@" %@", title]];
            return YES;
        }
        
        self.text = [str stringByAppendingString:[NSString stringWithFormat:@" %@", title]];
        return YES;
    }
    
    if ([lastStr containsString:@"."]) {            //decimals num illegal
        if (lastStr.length > 3) {
            NSString *last = [lastStr substringToIndex:lastStr.length - 4];
            if ([last containsString:@"."]) {
                return NO;
            }
        }
        
        self.text = [str stringByAppendingString:title];
    }
    
    if (![lastStr containsString:@"."] && lastStr.length > defaultStrLength) {     //lastStr.length illegal
        return NO;
    }
    
    if ([lastStr isEqualToString:@" 0"]) {                  //"01"
        str = [str substringToIndex:str.length - 1];
    }
    
    self.text = [str stringByAppendingString:title];
    
    return YES;
}





@end
