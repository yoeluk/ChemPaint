//
//  YGWebServer.m
//
//  Created by Yoel R. GARCIA DIAZ on 18/08/2012.
//  Copyright (c) 2012 Lewis Dots. All rights reserved.
//

#import "YGWebServer.h"

@implementation YGWebServer


+ (void)webServerRequest:(NSDictionary *)dictRequest service:(NSString *)service method:(NSString *)method  {
	
	NSError *RequestError = nil;
	NSString *urlHead = @"http://www.lewisdots.com/";
	//NSString *urlHead = @"http://50.116.20.18/";
	NSString *urlString = [NSString stringWithFormat:@"%@%@/index.php", urlHead, service];
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictRequest options:NSJSONWritingPrettyPrinted error:&RequestError];
	NSString *postLength = [NSString stringWithFormat:@"%d", [jsonData length]];
	
	NSURL *serverURL = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:serverURL];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:method];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:jsonData];
	
	if (RequestError) {
		NSLog(@"Request error: %@", RequestError);
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestSent" object:self userInfo:nil];
	}
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
		if ([data length] > 0 && error == nil) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"responseFromWebServer" object:self userInfo:nil];
		} else if (error) {
			NSLog(@"There was a error in the server's response: %@", error);
		}
	}];
}


@end
