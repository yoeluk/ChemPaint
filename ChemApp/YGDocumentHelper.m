//
//  YGDocumentHelper.m
//  ChemPaint
//
//  Created by Yoel R. GARCIA DIAZ on 08/06/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import "YGDocumentHelper.h"

@implementation YGDocumentHelper


+(NSURL*)localDocumentsDirectoryURL {
    static NSURL *localDocumentsDirectoryURL = nil;
    if (localDocumentsDirectoryURL == nil) {
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
																				NSUserDomainMask, YES ) objectAtIndex:0];
        localDocumentsDirectoryURL = [NSURL fileURLWithPath:documentsDirectoryPath];
    }
    return localDocumentsDirectoryURL;
}

@end
