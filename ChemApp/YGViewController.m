//
//  YGViewController.m
//  ChemApp
//
//  Created by Yoel R. GARCIA DIAZ on 28/03/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import "YGViewController.h"
#import "YGDocumentHelper.h"
#import <ImageIO/ImageIO.h>

@interface YGViewController ()

@end

@implementation YGViewController
@synthesize webView;
@synthesize infoBtn;
@synthesize document;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMolFile:) name:@"openMolFileNotification" object:nil];
	fileURL_ = [NSURL URLWithString:@"empty"];
	showCopyMe_ = NO;
	[self.view.layer setCornerRadius:5.0f];
	[self.view.layer setMasksToBounds:YES];
	[self.view clipsToBounds];
	
	[infoBtn addTarget:self action:@selector(loadInfoPopover:) forControlEvents:UIControlEventTouchUpInside];
	infoBtn.hidden = YES;
	
	webView.delegate = self;
	webView.scrollView.bounces = NO;
	
	copyMe = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copySelection:)];
	copyMe.delegate = self;
	copyMe.allowableMovement = 20;
	[copyMe setCancelsTouchesInView:YES];
	[self.webView addGestureRecognizer:copyMe];
	
	dismissMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissMenu:)];
	dismissMe.numberOfTouchesRequired = 1;
	dismissMe.numberOfTapsRequired = 1;
	dismissMe.delegate = self;
	[self.webView addGestureRecognizer:dismissMe];
	
	logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
	logo.frame = CGRectMake(self.view.frame.size.width-140, 10, 125, 31);
	[self.view addSubview:logo];
	
	int interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		
		logo.frame = CGRectMake(1024-140, 10, 125, 31);
	}
	
	fileM = [[NSFileManager alloc] init];
	NSArray *dirPaths;
	NSString *docsDir;
	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
												   NSUserDomainMask, YES);
	docsDir = [dirPaths objectAtIndex:0];
	NSString *urlString = [docsDir stringByAppendingPathComponent:@"ChemDoodle_WebComponents-master/html/index.html"];
	
	if (![fileM fileExistsAtPath:urlString]) {
		urlString = @"http://www.lewisdots.com/ChemPaint/iPad/html/";
		
		internetAlert = [[UIAlertView alloc] initWithTitle:@"Accessing Online Components" message:@"ChemPaint is attempting to access required components online. Please ensure that an Internet connection is available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		internetAlert.tag = 201;
		[internetAlert show];
		
	}
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
	
	
	
//	if (self.documentsInCloud) {
//        _query = [[NSMetadataQuery alloc] init];
//        [_query setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
//        [_query setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*.cpx'", NSMetadataItemFSNameKey]];
//        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
//        [notificationCenter addObserver:self selector:@selector(fileListReceived)
//								   name:NSMetadataQueryDidFinishGatheringNotification object:nil];
//        [notificationCenter addObserver:self selector:@selector(fileListReceived)
//								   name:NSMetadataQueryDidUpdateNotification object:nil];
//        [_query startQuery];
//    } else {
//        NSArray* localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:
//								   [self.documentsDir path] error:nil];
//        for (NSString* document in localDocuments) {
//            [_fileList addObject:[[[FileRepresentation alloc] initWithFileName:[document lastPathComponent]
//																		   url:[NSURL fileURLWithPath:[[self.documentsDir path]
//																									   stringByAppendingPathComponent:document]]] autorelease]];
//        }
//    }
	
	
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	
	
	//[self openDocumentIn];
	
//	NSString *stringURL = @"http://www.lipidmaps.org/data/LMSDRecord.php?Mode=File&LMID=LMSP07000001";
//	NSURL  *url = [NSURL URLWithString:stringURL];
//	NSData *urlData = [NSData dataWithContentsOfURL:url];
//	NSString  *filePath;
//	NSArray *paths;
//	NSString *documentsDirectory;
//	
//	if ( urlData )
//	{
//		paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//		documentsDirectory = [paths objectAtIndex:0];
//		
//		filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"LMSP07000001.mol"];
//		[urlData writeToFile:filePath atomically:YES];
//		fileURL_ = [NSURL URLWithString:filePath];
//	}
	
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.tag = 99;
	spinner.color = [UIColor grayColor];
	spinner.center = self.view.center;
	[spinner startAnimating];
	[self.webView addSubview:spinner];
	self.webView.userInteractionEnabled = NO;
}

-(void)openDocument {
	
	if (_createFile) {
        [self.document saveToURL:self.document.fileURL
				forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
					if (success) {
						NSLog(@"file created");
						NSError *error;
						NSURL *ubURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:@"JN4BWPC6UG.com.lewisdots.ChemPaint"];
						[[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:self.document.fileURL destinationURL:ubURL error:&error];
					}
				}];
        _createFile = NO;
    }
}

-(void)fileListReceived {
	
//	NSString* selectedFileName=nil;
//    NSInteger newSelectionRow = [self.tableView indexPathForSelectedRow].row;
//    if (newSelectionRow != NSNotFound) {
//        selectedFileName = [[_fileList objectAtIndex:newSelectionRow] fileName];
//    }
//    [_fileList removeAllObjects];
//    NSArray* queryResults = [_query results];
//    for (NSMetadataItem* result in queryResults) {
//        NSString* fileName = [result valueForAttribute:NSMetadataItemFSNameKey];
//        if (selectedFileName && [selectedFileName isEqualToString:fileName]) {
//            newSelectionRow = [_fileList count];
//        }
//        [_fileList addObject:[[[FileRepresentation alloc] initWithFileName:fileName
//																	   url:[result valueForAttribute:NSMetadataItemURLKey]] autorelease]];
//    }
//    [self.tableView reloadData];
//    if (newSelectionRow != NSNotFound) {
//        NSIndexPath* selectionPath = [NSIndexPath indexPathForRow:newSelectionRow inSection:0];
//        [self.tableView selectRowAtIndexPath:selectionPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//    }
}

-(void)loadInfoPopover:(id)sender {
	
	popover = [[UIPopoverController alloc] initWithContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"infoNavController"]];
	[popover presentPopoverFromRect:infoBtn.frame inView:self.webView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem*)barButtonItem {
	
	//[self.navigationItem setLeftBarButtonItem:nil];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
	
	if (barButtonItem) {
		//myLeftBarBtn_ = barButtonItem;
		//[myLeftBarBtn_ setTitle:@"Lists"];
		//[self.navigationItem setLeftBarButtonItem:myLeftBarBtn_];
	}
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
	
//	if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ) {
//		return YES;
//	} else /* if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
//		return YES;
//	} */
	return YES;
}

-(void)alertSaveLocally:(id)sender {
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save locally?" message:@"ChemPaint requests permission to save ChemDoodle Web Components library locally for increased functionality. If you cancell this request ChemPaint will continue accessing these resources remotelly providing that an Internet connection is available when they are needed." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	alertView.tag = 101;
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	if (alertView.tag == 101 && buttonIndex == 1) {
		
		NSString *aFileURL = @"http://github.com/yoeluk/ChemDoodle_WebComponents/archive/master.zip";
		NSFileManager *filemgr;
		NSArray *dirPaths;
		NSString *docsDir;
		NSString *newDir;
		
		filemgr =[NSFileManager defaultManager];
		
		dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
													   NSUserDomainMask, YES);
		
		docsDir = [dirPaths objectAtIndex:0];
		newDir = [docsDir stringByAppendingPathComponent:@"master.zip"];
		
		dispatch_queue_t downloadQueue = dispatch_queue_create("get the html_files", NULL);
		dispatch_async(downloadQueue, ^{
			
			NSData *asyncData = [NSData dataWithContentsOfURL:[NSURL URLWithString:aFileURL]];
			
			if (asyncData) {
				
				[asyncData writeToFile:newDir atomically:YES];
			}
			
			[SSZipArchive unzipFileAtPath:newDir toDestination:docsDir];
			
			NSString *reloadHTML = [docsDir stringByAppendingPathComponent:@"ChemDoodle_WebComponents-master/html/index.html"];
			
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:reloadHTML]]];
			
		});
		
		[((UIActivityIndicatorView *)[self.webView viewWithTag:99]) startAnimating];
		self.webView.userInteractionEnabled = NO;
		infoBtn.hidden = YES;
		
	}
	
}

-(void)dissmissMenu:(id)sender {
	if (![[self.webView stringByEvaluatingJavaScriptFromString: @"sketcher.lasso.isActive();"] boolValue]) {
		[[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
	}
}

-(void)copySelection:(id)sender {
	
	UIMenuController *menuCtr = [UIMenuController sharedMenuController];
	
	if ([copyMe state] == 1) {
		
		bool selection = [[self.webView stringByEvaluatingJavaScriptFromString: @"sketcher.lasso.isActive();"] boolValue];
		
		if ( selection ) {
			
			CGPoint aPoint = [copyMe locationInView:self.webView];
			menuCtr.arrowDirection = UIMenuControllerArrowDefault;
			[menuCtr setTargetRect:CGRectMake(aPoint.x, aPoint.y, 20, 20) inView:self.webView];
			NSMutableArray *itemsArr = [[NSMutableArray alloc] initWithCapacity:5];
			UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(loadPNG:)];
			UIMenuItem *dupItem = [[UIMenuItem alloc] initWithTitle:@"Duplicate" action:@selector(duplicateSelection:)];
			[itemsArr addObject:copyItem];
			[itemsArr addObject:dupItem];
			menuCtr.menuItems = itemsArr;
			[menuCtr setMenuVisible:YES animated:YES];
		}
		
	} else if ([copyMe state] == 2) {
		[menuCtr setMenuVisible:NO animated:YES];
	}
}

-(void)duplicateSelection:(id)sender {
	
	NSString *myContent = [self.webView stringByEvaluatingJavaScriptFromString:@"\
						   \
						   var lassoedMols = [];\
						   var lassoedShapes = [];\
						   var molsAlreadyProcessed = [];\
						   \
						   \
						   var containsMol = function(mol, mols) {\
							   for (var i = 0; i < mols.length; i++) {\
								   if (mols[i] === mol) {\
									   return true;\
								   }\
							   }\
							   return false;\
						   };\
						   \
						   \
						   var bondIsLassoed = function(mol, bond) {\
							   if ( bond.a1.isLassoed && bond.a2.isLassoed ) {\
								   return true;\
							   }\
							   return false;\
						   };\
						   for (var i = 0, l = sketcher.lasso.atoms.length; i < l; i++) {\
							   var mol = sketcher.getMoleculeByAtom(sketcher.lasso.atoms[i]);\
							   \
							   \
							   if (containsMol(mol, molsAlreadyProcessed) === false) {\
								   molsAlreadyProcessed.push(mol);\
								   var newLassoedMol = new ChemDoodle.structures.Molecule;\
								   \
								   \
								   for (var ii = 0, la = mol.atoms.length; ii < la; ii++) {\
									   if (mol.atoms[ii].isLassoed) {\
										   newLassoedMol.atoms.push(mol.atoms[ii]);\
									   }\
								   }\
								   for (var ii = 0, lb = mol.bonds.length; ii < lb; ii++) {\
									   var bond = mol.bonds[ii];\
									   \
									   if (bondIsLassoed(mol, bond) === true) {\
										   \
										   newLassoedMol.bonds.push(bond);\
									   }\
								   }\
								   lassoedMols.push(newLassoedMol);\
							   }\
						   }\
						   \
						   \
						   lassoedShapes = sketcher.lasso.shapes;\
						   ChemDoodle.writeJSON(lassoedMols, lassoedShapes);\
						   "];
	
	NSDictionary *pasteMyContent = [NSDictionary dictionaryWithObjectsAndKeys:(id)myContent, @"com.ChemDoodle.json", nil];
	NSArray *arr = [[NSArray alloc] initWithObjects:pasteMyContent, nil];
	[UIPasteboard generalPasteboard].items = arr;
	
	NSMutableDictionary *prettyJSON = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:[[UIPasteboard generalPasteboard] valueForPasteboardType:@"com.ChemDoodle.json"] options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
	
	if ([prettyJSON objectForKey:@"m"]) {
		for (NSMutableDictionary *atomProps in [prettyJSON objectForKey:@"m"]) {
			for (NSMutableDictionary *atomDict in [atomProps objectForKey:@"a"]) {
				if ([atomDict objectForKey:@"x"]) {
					[atomDict setObject:[NSNumber numberWithFloat: [[atomDict objectForKey:@"x"] floatValue]+100] forKey:@"x"];
					[atomDict setObject:[NSNumber numberWithFloat: [[atomDict objectForKey:@"y"] floatValue]+100] forKey:@"y"];
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
					[shapesProps setObject:[NSNumber numberWithFloat: [[shapesProps objectForKey:key] floatValue]+50] forKey:key];
					[shapesProps setObject:[NSNumber numberWithFloat: [[shapesProps objectForKey:key] floatValue]+50] forKey:key];
				}
			}
		}
	}
	
	NSError *writeError = nil;
	NSData *jsonDataP = [NSJSONSerialization dataWithJSONObject:prettyJSON options:0 error:&writeError];
	NSString *jsonStringP = [[NSString alloc] initWithData:jsonDataP encoding:NSUTF8StringEncoding];
	
	[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
														  \
														  var newJSON = '%@';\
														  var myNewContent = ChemDoodle.readJSON(newJSON);\
														  var moleculesArray = []; moleculesArray = myNewContent.molecules;\
														  var shapesArray = []; shapesArray = myNewContent.shapes;\
														  var newSelAtoms = [];\
														  var newSelShapes = [];\
														  var l = myNewContent.molecules.length;\
														  \
														  for (var i = 0; i < l; i++) {\
														  \
															var myNewAddMol = myNewContent.molecules[i];\
															newSelAtoms = newSelAtoms.concat(myNewAddMol.atoms);\
														  \
														  }	\
														  for (var i = 0, l = myNewContent.shapes.length; i < l; i++) {\
															newSelShapes = newSelShapes.concat(myNewContent.shapes[i]);\
														  }\
														  \
														  sketcher.historyManager.pushUndo(new ChemDoodle.sketcher.actions.AddMoleculesAndShapesAction(sketcher, moleculesArray, shapesArray));\
														  sketcher.lasso.empty();\
														  sketcher.lasso.select(newSelAtoms, newSelShapes);\
														  sketcher.repaint();\
														  \
														  ", jsonStringP]];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	
    return YES;
}

-(void) openMolFile:(NSNotification *)aNotification {
	
	fileURL_ = [[aNotification userInfo] objectForKey:@"urlToOpen"];
	
	if ([[[fileURL_ path] substringToIndex:8] isEqualToString:@"/private"]) {
		fileURL_ = [NSURL URLWithString:[[fileURL_ path] substringFromIndex:8]];
	}
	
	if ( [self.webView request] && ![self.webView isLoading]) {
		
		[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
															  ChemDoodle.io.file.content('%@', function(fileContent){\
															  var newMol2Load = ChemDoodle.readMOL(fileContent);\
															  \
															  sketcher.addMolecule(newMol2Load);\
															  sketcher.center();\
															  \
															  //sketcher.toolbarManager.buttonLasso.getElement().click();\
															  //var newSelMol = sketcher.molecules[sketcher.molecules.length-1];\
															  //sketcher.tools.lasso.select(newSelMol.atoms, []);\
															  });", [fileURL_ path]]];
		NSLog(@"path %@", [fileURL_ path]);
		
		NSLog(@"file exist at url: %d",[fileM fileExistsAtPath:[NSString stringWithFormat:@"%@", [fileURL_ path]]]);
		NSLog(@"remove file at url: %d", [fileM removeItemAtPath:[NSString stringWithFormat:@"%@", [fileURL_ path]] error:nil]);
		fileURL_ = [NSURL URLWithString:@"empty"];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
		
		logo.frame = CGRectMake(self.view.frame.size.width-140, 10, 125, 31);
		[self.webView stringByEvaluatingJavaScriptFromString: @"sketcher.resize(751, 926); sketcher.specs.scale = 1; sketcher.repaint();" ];
		[self.webView stringByEvaluatingJavaScriptFromString:@"if (sketcher.lasso.isActive() ) sketcher.lasso.empty();"];
		
	} else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		
		logo.frame = CGRectMake(self.view.frame.size.width-140, 10, 125, 31);
		[self.webView stringByEvaluatingJavaScriptFromString: @"sketcher.resize(1006, 670); sketcher.specs.scale = 1; sketcher.repaint();" ];
		[self.webView stringByEvaluatingJavaScriptFromString:@"if (sketcher.lasso.isActive() ) sketcher.lasso.empty();"];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissModalView {
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	
    if ([requestString hasPrefix:@"ios-log:"]) {
        NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
		NSLog(@"UIWebView console: %@", logString);
        return NO;
    } else if ([[[request URL] absoluteString] isEqualToString:@"http://loadmolecule.com/"] || [[[request URL] absoluteString] isEqualToString:@"http://savemolecule.com/"] ) {
		
		NSLog(@"%@", [[request URL] absoluteString]);
		if ([[[request URL] absoluteString] isEqualToString:@"http://loadmolecule.com/"]) {
			if ([self.parentViewController childViewControllers].count == 2) {
				NSLog(@"Good!");
			}
			[self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"lsDocNavController"] animated:YES completion:^{
				
				UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModalView)];
				
				((UIViewController *)[[((UINavigationController *)self.presentedViewController) viewControllers] objectAtIndex:0]).navigationItem.leftBarButtonItem = closeBtn;
			}];
		}
		
		return NO;
	}
	
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	int interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
		[self.webView stringByEvaluatingJavaScriptFromString: @"sketcher.resize(751, 926); sketcher.specs.scale = 1; sketcher.repaint();" ];
	} else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[self.webView stringByEvaluatingJavaScriptFromString: @"sketcher.resize(1006, 670); sketcher.specs.scale = 1; sketcher.repaint();" ];
	}
	
	if (![[fileURL_ absoluteString] isEqualToString:@"empty"]) {
		
		[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
															  ChemDoodle.io.file.content('%@', function(fileContent){\
															  var newMol2Load = ChemDoodle.readMOL(fileContent);\
															  \
															  newMol2Load.check();\
															  sketcher.loadMolecule(newMol2Load);\
															  //sketcher.toolbarManager.buttonLasso.getElement().click();\
															  //var newSelMol = sketcher.getMolecule();\
															  //sketcher.tools.lasso.select(newSelMol.atoms, []);\
															  });", [fileURL_ path]]];
		
		[fileM removeItemAtPath:[NSString stringWithFormat:@"%@", [fileURL_ relativePath]] error:nil];
		fileURL_ = [NSURL URLWithString:@"empty"];
	}
	
	if ([[[[self.webView request] URL] absoluteString] isEqualToString:@"http://www.lewisdots.com/ChemPaint/iPad/html/"]) {
		[internetAlert dismissWithClickedButtonIndex:0 animated:YES];
		[self alertSaveLocally:[fileURL_ relativePath]];
	}
	
	[((UIActivityIndicatorView *)[self.webView viewWithTag:99]) stopAnimating];
	self.webView.userInteractionEnabled = YES;
	infoBtn.hidden = NO;
}


- (void)loadPNG:(id)sender {
	
	if ( [[self.webView stringByEvaluatingJavaScriptFromString: @"sketcher.lasso.isActive();"] boolValue]) {
		
		[self.webView stringByEvaluatingJavaScriptFromString:@"\
		 \
		     \
		     var currScale = sketcher.specs.scale;\
			 sketcher.specs.scale = 1;\
			 var ctxSketcher = document.getElementById(sketcher.id).getContext('2d');\
			 var originX = 2 * sketcher.lasso.bounds.minX;\
			 var originY = 2 * sketcher.lasso.bounds.minY;\
			 var selWidth = 2 * (sketcher.lasso.bounds.maxX-sketcher.lasso.bounds.minX);\
			 var selHeight = 2 * (sketcher.lasso.bounds.maxY-sketcher.lasso.bounds.minY);\
			 sketcher.lasso.empty();\
			 var sectionCanvas = document.createElement('canvas');\
			 sectionCanvas.width = selWidth;\
			 sectionCanvas.height = selHeight;\
			 sectionCanvas.id = 'myPNG';\
			 document.getElementById('tempBox').appendChild(sectionCanvas);\
			 var sectionImage = ctxSketcher.webkitGetImageDataHD(originX, originY, selWidth, selHeight);\
		     sketcher.specs.scale = currScale;\
		     sketcher.repaint();\
			 var ctxPNG = document.getElementById(sectionCanvas.id).getContext('2d');\
		 \
		 "];
		
		 
		[self.webView stringByEvaluatingJavaScriptFromString:@"\
		 \
		var imageData = sectionImage.data;\
		var length = imageData.length;\
		for ( var i = 3; i < length; i = i + 4 ) {\
		 \
		 if ( imageData[i] == 0 ) {\
		 \
				imageData[i] = 1;\
			}\
		}\
		sectionImage.data = imageData;\
		 \
		 "];
		 
		 
		NSString *pngString = [NSString stringWithFormat:@"%@", [self.webView stringByEvaluatingJavaScriptFromString:@"\
																 ctxPNG.webkitPutImageDataHD(sectionImage, 0, 0);\
																 document.getElementById(sectionCanvas.id).toDataURL('image/png');"]];
		
		[self.webView stringByEvaluatingJavaScriptFromString:@"\
															document.getElementById('tempBox').removeChild(sectionCanvas);\
															//sketcher.toolbarManager.buttonLasso.getElement().click();\
															"];
		
		NSURL *pngURL = [NSURL URLWithString:pngString];
		
		NSData *pngData = [NSData dataWithContentsOfURL:pngURL];
		
		NSString *myContent = [self.webView stringByEvaluatingJavaScriptFromString:@"\
		 \
		 var printMols = [];\
		 var printShapes = [];\
		 printMols = sketcher.getMolecules();\
		 printShapes = sketcher.getShapes();\
		 ChemDoodle.writeJSON(printMols, printShapes);\
		 "];
		
		NSDictionary *pasteMyContent = [NSDictionary dictionaryWithObjectsAndKeys:pngData, @"public.png", (id)myContent, @"com.ChemDoodle.json", nil];
		NSArray *arr = [[NSArray alloc] initWithObjects:pasteMyContent, nil];
		[UIPasteboard generalPasteboard].items = arr;
		
//		MyCreateCGImageFromFile(pngURL);
//		CGImageRef myImage = MyCreateCGImageFromFile(pngURL);
//		NSLog(@"%@", CGImageGetDataProvider(myImage));
//		if ( myImage != NULL ) {
//			copyCGImageRefToPasteboard(myImage);
//			NSLog(@"%@", (__bridge NSDictionary *)CGImageSourceCopyProperties(MyCreateCGImageRefFromFile(pngURL), NULL));
//		}
	}
}


void copyCGImageRefToPasteboard(CGImageRef ref) {
	
    CFMutableDataRef url = CFDataCreateMutable(kCFAllocatorDefault, 0);
	
    CFStringRef type = (__bridge CFStringRef)@"public.png";
    size_t count = 1;
    CFDictionaryRef options = NULL;
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(url, type, count, options);
    CGImageDestinationAddImage(dest, ref, NULL);
    CGImageDestinationFinalize(dest);
	
    [[UIPasteboard generalPasteboard] setData:(__bridge NSData *)(url) forPasteboardType:@"public.png"];
}

CGImageRef MyCreateCGImageFromFile (NSURL* url) {
	
    // Get the URL for the pathname passed to the function.
    // NSURL *url = [NSURL fileURLWithPath:path];
    CGImageRef        myImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
	
    // Set up options if you want them. The options here are for
    // caching the image in a decoded form and for using floating-point
    // values if the image format supports them.
	CFTypeRef chemJSON = (__bridge CFTypeRef)@"kUTTypeChemJSON";
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
	myKeys[2] = (__bridge CFStringRef)@"ChemJSON";
	myValues[2] = chemJSON;
    // Create the dictionary
    myOptions = CFDictionaryCreate( kCFAllocatorDefault, (const void **) myKeys,
								   (const void **) myValues, 2,
								   &kCFTypeDictionaryKeyCallBacks,
								   & kCFTypeDictionaryValueCallBacks);
    // Create an image source from the URL.
    myImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, myOptions);
    CFRelease(myOptions);
    // Make sure the image source exists before continuing
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    // Create an image from the first item in the image source.
    myImage = CGImageSourceCreateImageAtIndex(myImageSource,
											  0,
											  NULL);
	
    CFRelease(myImageSource);
	//CFDictionaryRef fileProps = CGImageSourceCopyProperties(myImageSource, nil);
    // Make sure the image exists before continuing
    if (myImage == NULL){
		fprintf(stderr, "Image not created from image source.");
		return NULL;
    }
    return myImage;
}

CGImageSourceRef MyCreateCGImageRefFromFile (NSURL* url) {
	
    // Get the URL for the pathname passed to the function.
    // NSURL *url = [NSURL fileURLWithPath:path];
    //CGImageRef        myImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
	
    // Set up options if you want them. The options here are for
    // caching the image in a decoded form and for using floating-point
    // values if the image format supports them.
	CFTypeRef chemJSON = (__bridge CFTypeRef)@"kUTTypeChemJSON";
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
	myKeys[2] = (__bridge CFStringRef)@"ChemJSON";
	myValues[2] = chemJSON;
    // Create the dictionary
    myOptions = CFDictionaryCreate( kCFAllocatorDefault, (const void **) myKeys,
								   (const void **) myValues, 2,
								   &kCFTypeDictionaryKeyCallBacks,
								   & kCFTypeDictionaryValueCallBacks);
    // Create an image source from the URL.
    myImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, myOptions);
    CFRelease(myOptions);
    // Make sure the image source exists before continuing
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
	
	return myImageSource;
}

-(void)openDocumentIn {
	
    sendFileURL_  = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"My PDF" ofType:@"pdf"]];
    documentController_ = [UIDocumentInteractionController interactionControllerWithURL:sendFileURL_];
    documentController_.delegate = self;
    documentController_.UTI = @"text/plain";
    [documentController_ presentOpenInMenuFromRect:CGRectMake(40, 40, 40, 40)
										   inView:self.view
										 animated:YES];
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	
}


@end
