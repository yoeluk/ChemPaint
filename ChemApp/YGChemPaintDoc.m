//
//  YGChemPaintDoc.m
//  ChemPaint
//
//  Created by Yoel R. GARCIA DIAZ on 08/06/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import "YGChemPaintDoc.h"

//static NSString *FileExtension = @"cpx";

@implementation YGChemPaintDoc

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
	if (!self.cpDocument) {
        self.cpDocument = @"";
    }
    NSData *docData = [self.cpDocument dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    return docData;
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
	
	if ([contents length] > 0) {
        self.cpDocument = [[NSString alloc] initWithData:(NSData *)contents encoding:NSUTF8StringEncoding];
    } else {
        self.cpDocument = @"";
    }
    return YES;
}

@end
