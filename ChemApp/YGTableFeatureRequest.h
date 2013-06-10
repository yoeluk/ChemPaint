//
//  YGTableFeatureRequest.h
//  ChemPaint
//
//  Created by Yoel R. GARCIA DIAZ on 05/06/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGTableFeatureRequest : UITableViewController {
	
	UIProgressView *progressView;
	NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) NSMutableDictionary *featuresRequested;

@end
