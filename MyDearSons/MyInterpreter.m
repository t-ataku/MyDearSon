//
//  MyInterpreter.m
//  MyDearSons
//
//  Created by Toshimi Ataku on 2020/11/25.
//  Copyright © 2020 Toshimi Ataku. All rights reserved.
//

#import "MyInterpreter.h"

@implementation MyInterpreter

NSMutableData *voiceData;
NSUInteger pos;

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
    }
    return nil;
}
- (NSURL *)getUrl: (NSString *)target withVoice:(NSString *)voice {
    if ([target compare:@"speech"] == NSOrderedSame) {
        NSURL *speechUrlBase = [NSURL URLWithString:[[_prefSpeechURL stringValue] stringByAppendingFormat:@"?voice=%@",voice]];
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
//    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:@"/tmp/voice.wav"];
//    [fh writeData:voiceData];
    NSOutputStream *ost = [NSOutputStream outputStreamToFileAtPath:@"/Users/ataku/Downloads/voice.wav" append:NO];
    [ost open];
    [ost write:[voiceData bytes] maxLength:[voiceData length]];
    [ost close];
    NSSound *talk = [[NSSound alloc] initWithData:voiceData];
    [talk play];
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

- (NSString *)getLangTransSourceText {
    NSString *jsonFmt = @"{ \"text\": [%@], \"model_id\": \"%@-%@\" }";
    NSString *jsonData = @"";
    NSString *jsonMsg;
    NSString *stext = [_sourceText stringValue];
    NSRange linepos; //linepos.location linepos.length

    if ([stext length] == 0)
        return nil;
    
    while ([stext length] > 0) {
        linepos = [stext rangeOfString:@"\n"];
        if (linepos.location == NSNotFound)     // No more target
            break;
        if (linepos.location > 0) {            // The TOP of the character is not '\n'
            NSLog(@"%@", [stext substringToIndex:linepos.location]);
            if ([jsonData length] > 0) {
                jsonData = [jsonData stringByAppendingString:@",\n"];
            }
            jsonData = [jsonData stringByAppendingFormat:@"\"%@\"",[stext substringToIndex:linepos.location]];
        }
        stext = [stext substringFromIndex:(linepos.location + 1)];
    }

    jsonMsg = [NSString stringWithFormat:jsonFmt,jsonData,[[_sourceLanguage selectedItem] title], [[_destLanguage selectedItem] title]];
    return jsonMsg;
}

- doLangTrans {
    NSString *testMsg = @"Our Business Conduct Guidelines are framed as a living document.";
    NSString *jsonMsg = [self getLangTransSourceText];
    
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

- (NSString *)getSpeechSourceText {
    NSString *jsonMsg = @"";
    NSString *stext = [_destText stringValue];
    NSUInteger start, end;
    NSRange linepos; //linepos.location linepos.length

    if ([stext length] == 0)
        return nil;
    
    while ([stext length] > 0) {
        linepos = [stext rangeOfString:@"\"translation\" : "];
        if (linepos.location == NSNotFound)     // No more target
            break;
        stext = [stext substringFromIndex:(linepos.location + linepos.length + 1)];
        linepos = [stext rangeOfString:@"\""];
        if (linepos.location == NSNotFound)     // No more target
            break;
        end = linepos.location;
        jsonMsg = [jsonMsg stringByAppendingString:[stext substringToIndex:end]];
        stext = [stext substringFromIndex:(end + 1)];
    }

    return jsonMsg;
}

- (const char *)gettag {
    static char tag[4];
    NSUInteger i;
    const char *bytes = (char *)[voiceData bytes];

    if (pos + 4 >= [voiceData length])
        return NULL;
    for (i = 0; i < 4; i++) {
        tag[i] = bytes[pos + i];
    }
    for (; i < 4; i++)
        tag[i] = '\0';
    pos += i;
    return tag;
}

int getlength(NSUInteger *size)
{
    unsigned long sz;
    const char *bytes = (char *)[voiceData bytes];

    if (pos >= [voiceData length])
        return -1;

    sz = 0;
    sz = sz * 0x100 + ((*(bytes + pos + 3)) & 0xff);
    sz = sz * 0x100 + ((*(bytes + pos + 2)) & 0xff);
    sz = sz * 0x100 + ((*(bytes + pos + 1)) & 0xff);
    sz = sz * 0x100 + ((*(bytes + pos + 0)) & 0xff);
    
    *size = sz;
    pos += 4;
    return 0;
}

void resetlength(NSUInteger newSize)
{
    NSRange mod;
    char byte;
    
    mod.location = pos - 4;
    mod.length = 1;
    
    byte = newSize & 0xff;
    [voiceData replaceBytesInRange:mod withBytes:&byte];
    mod.location++;
 
    newSize = newSize >> 8;
    byte = newSize & 0xff;
    [voiceData replaceBytesInRange:mod withBytes:&byte];
    mod.location++;

    newSize = newSize >> 8;
    byte = newSize & 0xff;
    [voiceData replaceBytesInRange:mod withBytes:&byte];
    mod.location++;

    newSize = newSize >> 8;
    byte = newSize & 0xff;
    [voiceData replaceBytesInRange:mod withBytes:&byte];
    mod.location++;
}

NSUInteger getrestdatalen()
{
    return [voiceData length] - pos;
}

- gotVoice: (NSData *)data {
    voiceData = [NSMutableData dataWithData:data];
    pos = 0;
    const char *tag;
    NSUInteger size;
    
    while (pos < [voiceData length]) {
        tag = [self gettag];
        if (tag == NULL)
            return nil;
        if (strncmp(tag, "WAVE", 4) == 0) {
            NSLog(@"TAG: %.4s", tag);
            continue;
        }
        if (getlength(&size)) {
            return nil;
        }
        // It's ready for TAG and SIZE
        if (strncmp(tag, "RIFF", 4) == 0) {
            if (size == getrestdatalen()) {
                NSLog(@"TAG: %.4s(%lu)", tag, size);
            } else {
                resetlength(getrestdatalen());
                NSLog(@"TAG: %.4s(%lu)<== Should be %lu\n", tag, size, getrestdatalen());
            }
        } else {
            if (size <= getrestdatalen()) {
                NSLog(@"TAG: %.4s(%lu)", tag, size);
            } else {
                resetlength(getrestdatalen());
                NSLog(@"TAG: %.4s(%lu)<== Should be %lu\n", tag, size, getrestdatalen());
            }
            pos += size;
        }
    }
    return self;
}

- doSpeech {
    NSString *testMsg = @"Our Business Conduct Guidelines are framed as a living document.";
    NSString *jsonMsg = [NSString stringWithFormat:@"{  \"text\": \"%@\" }", [self getSpeechSourceText]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrl:@"speech" withVoice:@"ja-JP_EmiVoice"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSData dataWithBytes:[jsonMsg UTF8String] length:strlen([jsonMsg UTF8String])];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"audio/wav" forHTTPHeaderField:@"Accept"];
    
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

        //        NSLog(@"%@", _resp);
        //        NSLog(@"%@", data);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotVoice: _dt];
                    _playButton.enabled = YES;
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
