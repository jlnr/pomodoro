// Pomodoro Desktop - Copyright (c) 2009-2011, Ugo Landini (ugol@computer.org)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// * Neither the name of the <organization> nor the
// names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "ShortcutController.h"
#import "PTHotKeyCenter.h"
#import "PTHotKey.h"
#import "Carbon/Carbon.h"
#import "PomoNotifications.h"



@implementation ShortcutController

@synthesize delegate, startRecorder, interruptRecorder, internalInterruptRecorder, muteRecorder, quickStatsRecorder, resetRecorder, resumeRecorder;

#pragma mark - Shortcut recorder callbacks & support

- (void)switchKey: (NSString*)name forKey:(PTHotKey*)key withMethod:(SEL)method withRecorder:(SRRecorderControl*)recorder {
    
	if (key != nil) {
		[[PTHotKeyCenter sharedCenter] unregisterHotKey: key];
	}
	
	//NSLog(@"Code %d flags: %u, PT flags: %u", [recorder keyCombo].code, [recorder keyCombo].flags, [recorder cocoaToCarbonFlags: [recorder keyCombo].flags]);
    
    NSInteger code = [recorder.objectValue[SRShortcutKeyCode] integerValue];
    NSInteger flags = [recorder.objectValue[SRShortcutModifierFlagsKey] integerValue];
    
	key = [[PTHotKey alloc] initWithIdentifier:name keyCombo:[PTKeyCombo keyComboWithKeyCode:code modifiers:SRCocoaToCarbonFlags(flags)]];
	[key setTarget: self];
	[key setAction: method];
	[[PTHotKeyCenter sharedCenter] registerHotKey: key];

    [[NSUserDefaults standardUserDefaults] setObject:@(code) forKey:[NSString stringWithFormat:@"%@%@", name, @"Code"]];
	[[NSUserDefaults standardUserDefaults] setObject:@(flags) forKey:[NSString stringWithFormat:@"%@%@", name, @"Flags"]];
	
}

- (void)shortcutRecorderDidEndRecording:(SRRecorderControl *)aRecorder {
    
	if (aRecorder == muteRecorder) {
		[self switchKey:@"mute" forKey:muteKey withMethod:@selector(keyMute) withRecorder:aRecorder];
	} else if (aRecorder == startRecorder) {
		[self switchKey:@"start" forKey:startKey withMethod:@selector(keyStart) withRecorder:aRecorder];
	} else if (aRecorder == resetRecorder) {
		[self switchKey:@"reset" forKey:resetKey withMethod:@selector(keyReset) withRecorder:aRecorder];
	} else if (aRecorder == interruptRecorder) {
		[self switchKey:@"interrupt" forKey:interruptKey withMethod:@selector(keyInterrupt) withRecorder:aRecorder];
	} else if (aRecorder == internalInterruptRecorder) {
		[self switchKey:@"internalInterrupt" forKey:internalInterruptKey withMethod:@selector(keyInternalInterrupt) withRecorder:aRecorder];
	} else if (aRecorder == resumeRecorder) {
		[self switchKey:@"resume" forKey:resumeKey withMethod:@selector(keyResume) withRecorder:aRecorder];
	} else if (aRecorder == quickStatsRecorder) {
		[self switchKey:@"quickStats" forKey:quickStatsKey withMethod:@selector(keyQuickStats) withRecorder:aRecorder];
	} 
}

- (void) updateShortcuts {
    muteKeyCombo = @{
        SRShortcutKeyCode: [[NSUserDefaults standardUserDefaults] objectForKey:@"muteCode"],
        SRShortcutModifierFlagsKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"muteFlags"],
    };
    startKeyCombo = @{
        SRShortcutKeyCode: [[NSUserDefaults standardUserDefaults] objectForKey:@"startCode"],
        SRShortcutModifierFlagsKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"startFlags"],
    };
    resetKeyCombo = @{
        SRShortcutKeyCode: [[NSUserDefaults standardUserDefaults] objectForKey:@"resetCode"],
        SRShortcutModifierFlagsKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"resetFlags"],
    };
    interruptKeyCombo = @{
        SRShortcutKeyCode: [[NSUserDefaults standardUserDefaults] objectForKey:@"interruptCode"],
        SRShortcutModifierFlagsKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"interruptFlags"],
    };
    internalInterruptKeyCombo = @{
        SRShortcutKeyCode: [[NSUserDefaults standardUserDefaults] objectForKey:@"internalInterruptCode"],
        SRShortcutModifierFlagsKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"internalInterruptFlags"],
    };
    resumeKeyCombo = @{
        SRShortcutKeyCode: [[NSUserDefaults standardUserDefaults] objectForKey:@"resumeCode"],
        SRShortcutModifierFlagsKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"resumeFlags"],
    };
    quickStatsKeyCombo = @{
        SRShortcutKeyCode: [[NSUserDefaults standardUserDefaults] objectForKey:@"quickStatsCode"],
        SRShortcutModifierFlagsKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"quickStatsFlags"],
    };

	[muteRecorder setObjectValue:muteKeyCombo];
	[startRecorder setObjectValue:startKeyCombo];
	[resetRecorder setObjectValue:resetKeyCombo];
	[interruptRecorder setObjectValue:interruptKeyCombo];
	[internalInterruptRecorder setObjectValue:internalInterruptKeyCombo];
	[resumeRecorder setObjectValue:resumeKeyCombo];
	[quickStatsRecorder setObjectValue:quickStatsKeyCombo];
}

#pragma mark ---- Key management methods ----

-(void) keyMute {
    [delegate keyMute];
}

-(void) keyStart {
    [delegate keyStart];	
}

-(void) keyReset {
    [delegate keyReset];
}

-(void) keyInterrupt {
    [delegate keyInterrupt];
}

-(void) keyInternalInterrupt {
    [delegate keyInternalInterrupt];
}

-(void) keyResume {
    [delegate keyResume];
}

-(void) keyQuickStats {
    [delegate keyQuickStats];
}


#pragma mark ---- Lifecycle methods ----

- (void)awakeFromNib {
    
    [self updateShortcuts];
    [self registerForPomodoro:_PMResetDefault method:@selector(updateShortcuts)];


}


@end
