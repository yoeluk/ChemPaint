//
//  YGAppDelegate.m
//  ChemApp
//
//  Created by Yoel R. GARCIA DIAZ on 28/03/2013.
//  Copyright (c) 2013 Lewis Dots. All rights reserved.
//

#import "YGAppDelegate.h"

@implementation YGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	
	id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
	
	if (token) {
		[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
	} else [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	
	
	
	if ([url isFileURL]) {
		// This should do it. (Maybe I should move this file to a permanent directory
		// and delete this directory to keep it clean :)
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"openMolFileNotification" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:url, @"urlToOpen", nil]];
	}
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
