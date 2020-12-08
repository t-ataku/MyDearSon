//
//  MyInterpreter.h
//  MyDearSons
//
//  Created by Toshimi Ataku on 2020/11/25.
//  Copyright © 2020 Toshimi Ataku. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyInterpreter : NSObject
@property (weak) IBOutlet NSPopUpButton *sourceLanguage;
@property (weak) IBOutlet NSPopUpButton *destLanguage;
@property (weak) IBOutlet NSScrollView *sourceText;
@property (weak) IBOutlet NSScrollView *destText;
@property (weak) IBOutlet NSButtonCell *playButton;
@property (weak) IBOutlet NSButton *isInit;
@property (weak) IBOutlet NSButton *isStep;
@property (weak) IBOutlet NSTextField *prefLangtransCred;
@property (weak) IBOutlet NSTextField *prefLangtransURLBase;
@property (weak) IBOutlet NSTextField *prefLangtransURLDo;
@property (weak) IBOutlet NSTextField *prefLangtransURLList;
@property (weak) IBOutlet NSPanel *preferences;
@property (weak) IBOutlet NSButton *goButton;

@property (weak) IBOutlet NSTextField *prefSpeechCred;
@property (weak) IBOutlet NSTextField *prefSpeechURL;

@property (weak) IBOutlet NSTextField *credential;
@property (weak) IBOutlet NSTextField *url;

- (IBAction)doInterpretation:(id)sender;
- (IBAction)playVoice:(id)sender;
- (IBAction)listLanguages:(id)sender;
- (IBAction)prefSave:(id)sender;

@end

NS_ASSUME_NONNULL_END
