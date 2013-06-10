//
//  YGSplitViewController.m
//  ChemApp
//
//  Created by Yoel R. GARCIA DIAZ on 23/04/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import "YGSplitViewController.h"

@interface YGSplitViewController ()

@end

@implementation YGSplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if(self=[super initWithCoder:aDecoder])
	{
		//initialize my object.
		self.delegate = [self.viewControllers objectAtIndex:1];
	}
	
	return self;
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
