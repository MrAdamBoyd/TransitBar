//
//  TouchBar.h
//  TransitBar
//
//  Created by Adam on 1/9/18.
//  Copyright © 2018 adam. All rights reserved.
//

#import <AppKit/AppKit.h>

extern void DFRElementSetControlStripPresenceForIdentifier(NSString *, BOOL);
extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);

@interface NSTouchBarItem ()

+ (void)addSystemTrayItem:(NSTouchBarItem *)item;

@end

@interface NSTouchBar ()

+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSString *)identifier;

@end
