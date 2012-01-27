//
//  NSStringExt.h
//  TravelApp
//
//  Created by Ben Ford on 6/30/10.
//  Copyright 2010 LagoPixel All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(Ext)
- (NSString *)extFirstWord;
- (NSString *)extStringWithoutWhitespace;
- (BOOL)extContainsString:(NSString *)string;

- (BOOL)extBeginsWithString:(NSString *)beginsWith;
- (NSString *)extStringWithMaxLength:(NSUInteger)maxLength withElipses:(BOOL)withElipses;

- (NSString *)extExtensionWithDot;
- (NSString *)extLastPathComponentWithoutExtension;

/***
 Given target String: 'PictureOfTree.png' textToAppend: '_thumbnail_100'
 Outputs:  'PictureOfTree_thumbnail_100.png'
 */
- (NSString *)extStringByappendingTextBeforeExtension:(NSString *)textToAppend;
@end
