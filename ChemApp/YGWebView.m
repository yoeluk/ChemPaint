//
//  YGWebView.m
//  ChemApp
//
//  Created by Yoel R. GARCIA DIAZ on 20/04/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import "YGWebView.h"
#import <ImageIO/ImageIO.h>

@implementation YGWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	
    bool yesCan = NO;
	if (action == @selector(paste:)) {
		//yesCan = [[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:@"com.ChemDoodle.json"]];
	}
    return yesCan;
}

-(void)paste:(id)sender {
	
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	NSArray *pbType = [NSArray arrayWithObject:@"com.ChemDoodle.json"];
	
	if ([gpBoard containsPasteboardTypes:pbType]) {
		
		NSData *jsonFromPasteboard = [gpBoard valueForPasteboardType:@"com.ChemDoodle.json"];
		
		NSMutableDictionary *prettyJSON = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:jsonFromPasteboard options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
		
		if ([prettyJSON objectForKey:@"m"]) {
			for (NSMutableDictionary *atomProps in [prettyJSON objectForKey:@"m"]) {
				for (NSMutableDictionary *atomDict in [atomProps objectForKey:@"a"]) {
					if ([atomDict objectForKey:@"x"]) {
						[atomDict setObject:[NSNumber numberWithFloat: [[atomDict objectForKey:@"x"] floatValue]+50] forKey:@"x"];
						[atomDict setObject:[NSNumber numberWithFloat: [[atomDict objectForKey:@"y"] floatValue]+50] forKey:@"y"];
					}
				}
			}
		}
		if ([prettyJSON objectForKey:@"s"]) {
			for (NSMutableDictionary *shapesProps in [prettyJSON objectForKey:@"s"]) {
				if ([shapesProps objectForKey:@"coordsPush"]) {
					[shapesProps removeObjectForKey:@"coordsPush"];
				}
				for (NSString *key in shapesProps.allKeys) {
					if ([[key substringToIndex:1] isEqualToString:@"x"] || [[key substringToIndex:1] isEqualToString:@"y"]) {
						[shapesProps setObject:[NSNumber numberWithFloat: [[shapesProps objectForKey:key] floatValue]+25] forKey:key];
						[shapesProps setObject:[NSNumber numberWithFloat: [[shapesProps objectForKey:key] floatValue]+25] forKey:key];
					}
				}
			}
		}
		
		NSError *writeError = nil;
		NSData *jsonDataP = [NSJSONSerialization dataWithJSONObject:prettyJSON options:0 error:&writeError];
		NSString *jsonStringP = [[NSString alloc] initWithData:jsonDataP encoding:NSUTF8StringEncoding];
		
		[self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
													  var newJSON = '%@';\
													  var myNewContent = ChemDoodle.readJSON(newJSON);\
													  var newSelAtoms = [];\
													  var newSelShapes = [];\
													  var l = myNewContent.molecules.length;\
													  for (var i = 0; i < l; i++) {\
													  \
														var myNewAddMol = myNewContent.molecules[i];\
														sketcher.molecules.push(myNewAddMol);\
													    newSelAtoms = newSelAtoms.concat(myNewAddMol.atoms);\
													  \
													  }	\
													  for (var i = 0, l = myNewContent.shapes.length; i < l; i++) {\
														sketcher.shapes.push(myNewContent.shapes[i]);\
													    newSelShapes = newSelShapes.concat(myNewAddMol.atoms);\
													  }\
													  sketcher.lasso.empty();\
													  sketcher.lasso.select(newSelAtoms, newselShapes);\
													  sketcher.repaint();\
													  ", jsonStringP]];
	}
}

//- (void)paste:(id)sender {
//	
//	// Get the General pasteboard, the current tile, and create an array
//	// containing the color tile UTI.
//	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
//	//ColorTile *theTile = [self colorTileForOrigin:currentSelection];
//	NSArray *pbType = [NSArray arrayWithObject:@"public.png"];
//	
//	// If there is no tile and the item on the pasteboard is the correct type...
//	if ([gpBoard containsPasteboardTypes:pbType]) {
//		
//		NSLog(@"png found in pasteboard");
//		NSData *pngData = [gpBoard dataForPasteboardType:@"public.png"];
//		
//		CGImageSourceRef pngImageSourceRef = CGImageSourceCreateWithData (
//													  (__bridge CFDataRef)(pngData),
//													  NULL
//													  );
//		
//		CGImageRef pngImageRef = CGImageCreateWithPNGDataProvider (
//													 (__bridge CGDataProviderRef)pngData,//CGDataProviderRef source,
//													 NULL,
//													 NO,
//													 kCGRenderingIntentDefault
//													 );
//		if (pngImageRef != NULL) {
//			NSLog(@"we have a pngImageRef");
//		}
//		NSLog(@"%@", (__bridge NSDictionary *)CGImageSourceCopyProperties(pngImageSourceRef, NULL));
//		
////		// ... read the ColorTile object from the pasteboard.
////		NSData *tileData = [gpBoard dataForPasteboardType:ColorTileUTI];
////		ColorTile *theTile = (ColorTile *)[NSKeyedUnarchiver unarchiveObjectWithData:tileData];
////		
////		// Add the ColorTile object to the data model and update the display.
////		if (theTile) {
////			theTile.tileOrigin = currentSelection;
////			[tiles addObject:theTile];
////			CGRect tileRect = [self rectFromOrigin:currentSelection inset:TILE_INSET];
////			[self setNeedsDisplayInRect:tileRect];
////		}
//	}
//}


@end
