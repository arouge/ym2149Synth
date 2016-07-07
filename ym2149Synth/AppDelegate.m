//
//  AppDelegate.m
//  ym2149Synth
//
//  Created by Rouge, Alexandre on 7/7/16.
//  Copyright © 2016 Rouge, Alexandre. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    ym2149Synth *psgSynthInstance;
    psgSynthInstance = [[ym2149Synth alloc] init];
    
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
