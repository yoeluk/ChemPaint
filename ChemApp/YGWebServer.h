//
//  YGWebServer.h
//
//  Created by Yoel R. GARCIA DIAZ on 18/08/2012.
//  Copyright (c) 2012 Lewis Dots. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGWebServer : NSObject  {
	
}


+ (void)webServerRequest:(NSDictionary *)dictRequest service:(NSString *)service method:(NSString *)method;


@end
