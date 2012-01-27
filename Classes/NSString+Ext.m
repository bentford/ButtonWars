//
//  NSStringExt.m
//  TravelApp
//
//  Created by Ben Ford on 6/30/10.
//  Copyright 2010 LagoPixel All rights reserved.
//

#import "NSString+Ext.h"


@implementation NSString(Ext)
- (NSString *)extFirstWord {
    NSArray *whitespaceSeperatedWords = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [whitespaceSeperatedWords objectAtIndex:0];
}

- (NSString *)extStringWithoutWhitespace {
    NSArray *whitespaceSeperatedWords = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *result = [NSString string];
    for( NSString *word in whitespaceSeperatedWords )
        result = [result stringByAppendingString:word];
    
    return result;
}

- (BOOL)extContainsString:(NSString *)string {
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)extBeginsWithString:(NSString *)beginsWith {
    return [self rangeOfString:beginsWith].location == 0;
}

- (NSString *)extStringWithMaxLength:(NSUInteger)maxLength withElipses:(BOOL)withElipses {
    if( [self length] <= maxLength )
        return self;
    else if( withElipses == YES )
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:maxLength], @"..."];
    else return [self substringToIndex:maxLength];
}

- (NSString *)extExtensionWithDot {
    return [NSString stringWithFormat:@".%@",[self pathExtension]];    
}

- (NSString *)extLastPathComponentWithoutExtension {

    return [[self lastPathComponent] stringByReplacingOccurrencesOfString:[self extExtensionWithDot] withString:@""];
}

- (NSString *)extStringByappendingTextBeforeExtension:(NSString *)textToAppend {
    // if no extension
    if( [[self pathExtension] length] == 0 ) {
        return [self stringByAppendingFormat:@"%@", textToAppend];
    } else {
        NSString *replaceThis = [NSString stringWithFormat:@".%@",[self pathExtension]];
        return [self stringByReplacingOccurrencesOfString:replaceThis withString:[NSString stringWithFormat:@"%@%@", textToAppend, replaceThis]];
    }
}
@end
