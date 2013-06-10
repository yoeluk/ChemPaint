//
//  YGViewController.h
//  ChemApp
//
//  Created by Yoel R. GARCIA DIAZ on 28/03/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSZipArchive.h"
#import "YGWebView.h"
#import "YGChemPaintDoc.h"

@interface YGViewController : UIViewController <UIWebViewDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UISplitViewControllerDelegate, NSFileManagerDelegate>  {
	
	@private
	UIDocumentInteractionController *documentController_;
	NSURL *fileURL_;
	NSURL *sendFileURL_;
	bool showCopyMe_;
	UITapGestureRecognizer *dismissMe;
	UILongPressGestureRecognizer *copyMe;
	UIImageView *logo;
	UIAlertView *internetAlert;
	NSFileManager *fileM;
	UIPopoverController *popover;
	UIActivityIndicatorView *spinner;
	bool _createFile;
	NSMetadataQuery *_query;
	
}
@property (weak, nonatomic) IBOutlet YGWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (strong, nonatomic) YGChemPaintDoc *document;


@end
