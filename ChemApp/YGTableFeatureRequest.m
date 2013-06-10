//
//  YGTableFeatureRequest.m
//  ChemPaint
//
//  Created by Yoel R. GARCIA DIAZ on 05/06/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import "YGTableFeatureRequest.h"
#import "YGConnectivity.h"
#import "YGWebServer.h"
#import <QuartzCore/QuartzCore.h>

@interface YGTableFeatureRequest ()

@end

@implementation YGTableFeatureRequest
@synthesize submitBtn;
@synthesize featuresRequested;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[submitBtn addTarget:self action:@selector(submitRequest:) forControlEvents:UIControlEventTouchUpInside];
	featuresRequested = [[NSMutableDictionary alloc] initWithCapacity:5];
	[featuresRequested setObject:@"0" forKey:@"graphicInterface"];
	[featuresRequested setObject:@"0" forKey:@"computingData"];
	[featuresRequested setObject:@"0" forKey:@"exportingOptions"];
	[featuresRequested setObject:@"0" forKey:@"requestSubmitted"];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateProgress:)
												 name:@"requestSent" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(removeProgressView:)
												 name:@"responseFromWebServer" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	float height = 44;
	if ( indexPath.row % 2 != 0 ) {
		height = 55;
	}
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	static NSString *CellAddIdentifier = @"CellAdd";
	UITableViewCell *cell;
	if (indexPath.row % 2 == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		NSMutableAttributedString *attrString;
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Graphic interface:";
				attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / 10", [featuresRequested objectForKey:@"graphicInterface"]]];
				[self updateRequest:attrString :cell];
				break;
			case 2:
				cell.textLabel.text = @"Computing data:";
				attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / 10", [featuresRequested objectForKey:@"computingData"]]];
				[self updateRequest:attrString :cell];
				break;
			case 4:
				cell.textLabel.text = @"Exporting options:";
				attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / 10", [featuresRequested objectForKey:@"exportingOptions"]]];
				[self updateRequest:attrString :cell];
				break;
			default:
				break;
		}
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellAddIdentifier forIndexPath:indexPath];
		UIStepper *stepper;
		if (![cell.contentView viewWithTag:indexPath.row]) {
			stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
			stepper.center = CGPointMake(250, 14);
			stepper.maximumValue = 10;
			stepper.minimumValue = 0;
			stepper.autorepeat = YES;
			stepper.stepValue = 1;
			stepper.continuous = YES;
			stepper.tag = indexPath.row;
			[stepper addTarget:self action:@selector(incrementRequest:) forControlEvents:UIControlEventValueChanged];
			[cell.contentView addSubview:stepper];
		} else {
			stepper = (UIStepper *)[cell.contentView viewWithTag:indexPath.row];
			if ([[featuresRequested objectForKey:@"requestSubmitted"] boolValue]) {
				[stepper setEnabled:NO];
			}
		}
	}
    
    // Configure the cell...
    return cell;
}

-(void)updateRequest:(NSMutableAttributedString *)attrString :(UITableViewCell *)cell {
	
	UIFont *highlightedFont = [UIFont boldSystemFontOfSize:20];
	UIColor *highlightedColour = [UIColor magentaColor];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(220, 2, 65, 40)];
	[attrString setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:highlightedFont, NSFontAttributeName, highlightedColour, NSForegroundColorAttributeName, nil] range:NSMakeRange(0, attrString.length-5)];
	if (![cell.contentView viewWithTag:22]) {
		label.attributedText = attrString;
		label.textAlignment = NSTextAlignmentRight;
		label.font = [UIFont boldSystemFontOfSize:20];
		[cell.contentView addSubview:label];
	} else {
		label = (UILabel *)[cell.contentView viewWithTag:22];
		label.attributedText = attrString;
	}
}

-(void)incrementRequest:(id)sender {
	UIStepper *stepper = (UIStepper *)sender;
	switch (stepper.tag-1) {
		case 0:
			[featuresRequested setObject:[NSString stringWithFormat:@"%d", (int)[stepper value]]  forKey:@"graphicInterface"];
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:stepper.tag-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
			break;
		case 2:
			[featuresRequested setObject:[NSString stringWithFormat:@"%d", (int)[stepper value]]  forKey:@"computingData"];
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:stepper.tag-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
			break;
		case 4:
			[featuresRequested setObject:[NSString stringWithFormat:@"%d", (int)[stepper value]]  forKey:@"exportingOptions"];
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:stepper.tag-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
			break;
		default:
			break;
	}
}

-(void)submitRequest:(id)sender {
	
	if ([YGConnectivity hasConnectivity]) {
		[YGWebServer webServerRequest:[NSDictionary dictionaryWithObjectsAndKeys:featuresRequested, @"message", nil] service:@"MailOut" method:@"POST"];
		[featuresRequested setObject:@"1" forKey:@"requestSubmitted"];
		[submitBtn setTitle:@"Submitting..." forState:UIControlStateNormal];
		progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 10)];
		[titleView addSubview:progressView];
		self.navigationItem.titleView = titleView;
		
		[CATransaction begin];
		[CATransaction setAnimationDuration:(2.f)];
		[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
		
		[progressView setProgress:0.2 animated:YES];
		[CATransaction commit];
		[submitBtn setEnabled:NO];
		[self.tableView reloadData];
	}
}

-(void)updateProgress:(id)sender {
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:(2.f)];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	
	[progressView setProgress:0.8 animated:YES];
	[CATransaction commit];
}

-(void)removeProgressView:(id)sender {
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:(1.f)];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	[CATransaction setCompletionBlock:^{
			
			self.navigationItem.titleView = nil;
			progressView.progress = 0;
			[submitBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
			[submitBtn setTitle:@"Submitted" forState:UIControlStateNormal];
	}];
	[progressView setProgress:1 animated:YES];
	[CATransaction commit];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
