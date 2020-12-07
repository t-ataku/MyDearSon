//
//  MyInterpreter.m
//  MyDearSons
//
//  Created by Toshimi Ataku on 2020/11/25.
//  Copyright © 2020 Toshimi Ataku. All rights reserved.
//

#import "MyInterpreter.h"

@implementation MyInterpreter

void completeData(NSData *data, NSURLResponse *response, NSError *error)
{
    return;
}

- gotList: data {
    NSLog(@"Data: %@", data);
//    NSRange range = NSMakeRange(0, [[_destText string] length]);
//    [_destText replaceCharactersInRange:range withString:@""];
    return self;
}

- (NSURL *)getUrl: (NSString *)target {
    int dbg = 0;

    if ([target compare:@"langTransDo"] == NSOrderedSame) {
        NSURL *langTransUrlDoBase = [NSURL URLWithString:[[[_prefLangtransURLBase stringValue] stringByAppendingString:@"/"] stringByAppendingString: [_prefLangtransURLDo stringValue]]];
        if (dbg)
            langTransUrlDoBase = [NSURL URLWithString:[[@"http://localhost:9025" stringByAppendingString:@"/"] stringByAppendingString:[_prefLangtransURLDo stringValue]]];
        return langTransUrlDoBase;
    } else if ([target compare:@"langTransList"] == NSOrderedSame) {
        NSURL *langTransUrlListBase = [NSURL URLWithString:[[[_prefLangtransURLBase stringValue] stringByAppendingString:@"/"]  stringByAppendingString:[_prefLangtransURLList stringValue]]];
        return langTransUrlListBase;
    } else if ([target compare:@"speech"] == NSOrderedSame) {
        NSURL *speechUrlBase = [NSURL URLWithString:[_prefSpeechURL stringValue]];
        return speechUrlBase;
    }
    return nil;
}

- (IBAction)listLanguages:(id)sender {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrl:@"langTransList"]];
    request.HTTPMethod = @"GET";
    request.HTTPBody = nil;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"apikey" password:[_prefLangtransCred stringValue] persistence:0];
    NSLog(@"Authorization: %@", [self getBasicRelm: credential]);
    [request setValue:[self getBasicRelm: credential] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *dtask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
                                           ^(NSData *_dt, NSURLResponse *_resp, NSError *error) {
                if (_dt == nil) {
                    NSLog(@"%@", error);
                    return;
                }
                NSLog(@"DataLen=%lu", (unsigned long)[_dt length]);
    //            NSString *data = [[NSString alloc] initWithBytes:[_dt bytes] length:[_dt length] encoding:NSJapaneseEUCStringEncoding];
                NSString *data = [[NSString alloc] initWithBytes:[_dt bytes] length:[_dt length] encoding:NSUTF8StringEncoding];

        //        NSLog(@"%@", _resp);
        //        NSLog(@"%@", data);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotList:data];
                });
            }];

        [dtask resume];
}

- (IBAction)playVoice:(id)sender {
    NSLog(@"playVoice");
}

- gotText: data {
    NSLog(@"Data: %@", data);
    _destText.stringValue = data;
    return self;
}

-(NSString *)getBasicRelm: (NSURLCredential *)cred {
    NSMutableString *relmStr = [NSMutableString stringWithCapacity:10];
    relmStr = [[[relmStr stringByAppendingString:cred.user] stringByAppendingString:@":"] stringByAppendingString:cred.password];
    NSString *b64Relm = [[NSData dataWithBytes:relmStr.UTF8String length:strlen(relmStr.UTF8String)] base64EncodedStringWithOptions:0];
    
    return [@"Basic " stringByAppendingString:b64Relm];
}

- doLangTrans {
    NSString *testMsg = @"Our Business Conduct Guidelines are framed as a living document.";
    NSString *jsonMsg = [NSString stringWithFormat:@"{  \"text\": [\"%@\"], \"model_id\": \"%@-%@\" }",
     [_sourceText stringValue], [[_sourceLanguage selectedItem] title], [[_destLanguage selectedItem] title]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrl:@"langTransDo"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSData dataWithBytes:[jsonMsg UTF8String] length:strlen([jsonMsg UTF8String])];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"apikey" password:[_prefLangtransCred stringValue] persistence:0];
    NSLog(@"Authorization: %@", [self getBasicRelm: credential]);
    [request setValue:[self getBasicRelm: credential] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *dtask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
                                           ^(NSData *_dt, NSURLResponse *_resp, NSError *error) {
                if (_dt == nil) {
                    NSLog(@"%@", error);
                    return;
                }
                NSLog(@"DataLen=%lu", (unsigned long)[_dt length]);
    //            NSString *data = [[NSString alloc] initWithBytes:[_dt bytes] length:[_dt length] encoding:NSJapaneseEUCStringEncoding];
                NSString *data = [[NSString alloc] initWithBytes:[_dt bytes] length:[_dt length] encoding:NSUTF8StringEncoding];

        //        NSLog(@"%@", _resp);
        //        NSLog(@"%@", data);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotText:data];
                });
            }];

        [dtask resume];
    return self;
}

- (NSString *)getSpeechText {
    
}

- doSpeech {
    NSString *testMsg = @"Our Business Conduct Guidelines are framed as a living document.";
    NSString *jsonMsg = [NSString stringWithFormat:@"{  \"text\": [\"%@\"], \"model_id\": \"%@-%@\" }",
     [_sourceText stringValue], [[_sourceLanguage selectedItem] title], [[_destLanguage selectedItem] title]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrl:@"speech"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSData dataWithBytes:[jsonMsg UTF8String] length:strlen([jsonMsg UTF8String])];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"apikey" password:[_prefSpeechCred stringValue] persistence:0];
   NSLog(@"Authorization: %@", [self getBasicRelm: credential]);
    [request setValue:[self getBasicRelm: credential] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *dtask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
                                           ^(NSData *_dt, NSURLResponse *_resp, NSError *error) {
                if (_dt == nil) {
                    NSLog(@"%@", error);
                    return;
                }
                NSLog(@"DataLen=%lu", (unsigned long)[_dt length]);
    //            NSString *data = [[NSString alloc] initWithBytes:[_dt bytes] length:[_dt length] encoding:NSJapaneseEUCStringEncoding];
                NSString *data = [[NSString alloc] initWithBytes:[_dt bytes] length:[_dt length] encoding:NSUTF8StringEncoding];

        //        NSLog(@"%@", _resp);
        //        NSLog(@"%@", data);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotText:data];
                });
            }];

        [dtask resume];
    return self;
}

- (IBAction)doInterpretation:(id)sender {
    NSLog(@"Source Lang(%@) -> Dest Lang(%@)", _sourceLanguage.titleOfSelectedItem, _destLanguage.titleOfSelectedItem);
    if ([_isInit state] != NSOffState) {    // It's a ON state
        _destText.stringValue = @"";
        _playButton.enabled = NO;
        _isInit.state = NSOffState;
    }
    
    if ([[_sourceText stringValue] length] == 0)    // Nothing to do
        return;
    if ([[_destText stringValue] length] == 0) {
        NSLog(@"DoLangTrans");
        [self doLangTrans];
    } else {
        NSLog(@"doSpeech");
        [self doSpeech];
    }
}
@end
