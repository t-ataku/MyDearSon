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

+ (void)initialize {
    // Register the preference defaults early.
     id keys[] = {
         @"langTransURLBase",
         @"langTransURLDo",
         @"langTransURLList",
         @"langTransCredential",
         @"speechURLBase",
         @"speechCredential"
     };
     id objs[] = {
         @"",
         @"v3/translate?version=2018-05-01",
         @"v3/languages?version=2018-05-01",
         @"",
         @"",
         @""
     };
     int dictSize = sizeof(keys) / sizeof(keys[0]) > sizeof(objs) / sizeof(objs[0]) ? sizeof(objs) / sizeof(objs[0]) : sizeof(keys) / sizeof(keys[0]);
     int go = 1;

     NSDictionary *dict = [NSDictionary dictionaryWithObjects:objs forKeys:keys count: dictSize];
     NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
     if (go)
         [pref registerDefaults:dict];
}

- (void)awakeFromNib {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [pref dictionaryRepresentation];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

        if ([key compare:@"langTransURLBase"] == NSOrderedSame) {
            _prefLangtransURLBase.stringValue = obj;
        } else if ([key compare:@"langTransURLDo"] == NSOrderedSame) {
            _prefLangtransURLDo.stringValue = obj;
        } else if ([key compare:@"langTransURLList"] == NSOrderedSame) {
            _prefLangtransURLList.stringValue = obj;
        } else if ([key compare:@"langTransCredential"] == NSOrderedSame) {
            _prefLangtransCred.stringValue = obj;
        } else if ([key compare:@"speechURLBase"] == NSOrderedSame) {
            _prefSpeechURL.stringValue = obj;
        } else if ([key compare:@"speechCredential"] == NSOrderedSame) {
            _prefSpeechCred.stringValue = obj;
        }
    }];
}

- (void)doing {
    NSLog(@"Doing");
//[textView performSelectorOnMainThread:@selector(setText:)
//withObject:text
//waitUntilDone:NO];
//    [_goButton performSelectorOnMainThread:@selector(setEnabled:) withObject:NO waitUntilDone:NO];
    [_goButton setEnabled:NO];
}

// Must be called like
//     [_goButton performSelectorOnMainThread:@selector(done:) withObject:nil waitUntilDone:NO];
- (void)done: (id)dummy {
    NSLog(@"Done");
    [_goButton setEnabled:YES];
}

- (BOOL)isdoing {
    return !_goButton.enabled;
}

- (IBAction)prefSave:(id)sender {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [pref dictionaryRepresentation];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSTextField *prefItem;
        if ([key compare:@"langTransURLBase"] == NSOrderedSame) {
            prefItem = _prefLangtransURLBase;
        } else if ([key compare:@"langTransURLDo"] == NSOrderedSame) {
            prefItem = _prefLangtransURLDo;
        } else if ([key compare:@"langTransURLList"] == NSOrderedSame) {
            prefItem = _prefLangtransURLList;
        } else if ([key compare:@"langTransCredential"] == NSOrderedSame) {
            prefItem = _prefLangtransCred;
        } else if ([key compare:@"speechURLBase"] == NSOrderedSame) {
            prefItem = _prefSpeechURL;
        } else if ([key compare:@"speechCredential"] == NSOrderedSame) {
            prefItem = _prefSpeechCred;
        } else
            return;
        
        if ([prefItem.stringValue compare:obj] != NSOrderedSame)
            [pref setObject:prefItem.stringValue forKey:key];
    }];
    [_preferences orderOut:self];
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
    NSRange rng;
    rng.location = 0;
    rng.length = [[[_destText documentView] string] length];
    [[_destText documentView] replaceCharactersInRange:rng withString:data];
    return self;
}

-(NSString *)getBasicRelm: (NSURLCredential *)cred {
    NSString *relmStr = [NSMutableString stringWithCapacity:10];
    relmStr = [[[relmStr stringByAppendingString:cred.user] stringByAppendingString:@":"] stringByAppendingString:cred.password];
    NSString *b64Relm = [[NSData dataWithBytes:relmStr.UTF8String length:strlen(relmStr.UTF8String)] base64EncodedStringWithOptions:0];
    
    return [@"Basic " stringByAppendingString:b64Relm];
}

- (NSString *)getLangTransSourceText {
    NSString *jsonFmt = @"{ \"text\": [%@], \"model_id\": \"%@-%@\" }";
    NSString *jsonData = @"";
    NSString *jsonMsg;
    NSString *stext = [[_sourceText documentView] string];
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
    
    if ([stext length] > 0) { //No LF data exists
        NSLog(@"%@", stext);
        if ([jsonData length] > 0) {
            jsonData = [jsonData stringByAppendingString:@",\n"];
        }
        jsonData = [jsonData stringByAppendingFormat:@"\"%@\"", stext];
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
        [self performSelectorOnMainThread:@selector(done:) withObject:nil waitUntilDone:NO];
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
    NSString *stext = [[_destText documentView] string];
    NSUInteger start, end;
    NSRange linepos; //linepos.location linepos.length

    if ([stext length] == 0)
        return nil;
    
    while ([stext length] > 0) {
        linepos = [stext rangeOfString:@"\"translation\" : "];
        if (linepos.location == NSNotFound)     // No more target
            break;
        stext = [stext substringFromIndex:(linepos.location + linepos.length + 1)];
        linepos = [stext rangeOfString:@"\"\n"];
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

- (NSString *)getVoiceModel: (NSString *)lang {
    if ([lang compare:@"en"] == NSOrderedSame)
        return @"en-US_AllisonV3Voice";
    else if ([lang compare:@"ja"] == NSOrderedSame)
        return @"ja-JP_EmiVoice";
    else if ([lang compare:@"zh"] == NSOrderedSame)
        return @"zh-CN_LiNaVoice";
    else if ([lang compare:@"ko"] == NSOrderedSame)
        return @"ko-KR_YoungmiVoice";
    return @"";
}

- doSpeech {
    NSString *testMsg = @"Our Business Conduct Guidelines are framed as a living document.";
    NSString *jsonMsg = [NSString stringWithFormat:@"{  \"text\": \"%@\" }", [self getSpeechSourceText]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getUrl:@"speech" withVoice:[self getVoiceModel:[[_destLanguage selectedItem] title]]]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSData dataWithBytes:[jsonMsg UTF8String] length:strlen([jsonMsg UTF8String])];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"audio/wav" forHTTPHeaderField:@"Accept"];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"apikey" password:[_prefSpeechCred stringValue] persistence:0];
    NSLog(@"Authorization: %@", [self getBasicRelm: credential]);
    [request setValue:[self getBasicRelm: credential] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *dtask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
//                                           ^(NSData *_dt, NSURLResponse *_resp, NSError *error) {
//                                           ^(NSData *_dt, NSHTTPURLResponse *_resp, NSError *error) {
                                           ^(NSData *_dt, id _resp, NSError *error) {
        [self performSelectorOnMainThread:@selector(done:) withObject:nil waitUntilDone:NO];
                if (_dt == nil) {
                    NSLog(@"%@", error);
                    return;
                }
        NSLog(@"URL=%@", [[_resp URL] absoluteURL]);
        NSLog(@"statusCode=%ld", [_resp statusCode]);
        if ([_resp statusCode] >= 300) {
            return;
        }
        
                NSLog(@"DataLen=%lu", (unsigned long)[_dt length]);
    //            NSString *data = [[NSString alloc] initWithBytes:[_dt bytes] length:[_dt length] encoding:NSJapaneseEUCStringEncoding];

        //        NSLog(@"%@", _resp);
        //        NSLog(@"%@", data);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotVoice: _dt];
                    self->_playButton.enabled = YES;
                });
            }];

        [dtask resume];
    return self;
}

- (IBAction)doInterpretation:(id)sender {
    if ([self isdoing])
        return;
    if ([[[_sourceText documentView] string] length] == 0)    // Nothing to do
        return;

    if ([_isInit state] != NSOffState) {    // It's a ON state
        NSRange rng;
        rng.location = 0;
        rng.length = [[[_destText documentView] string] length];
        [[_destText documentView] replaceCharactersInRange:rng withString:@""];
        _playButton.enabled = NO;
        _isInit.state = NSOffState;
    }
    
    [self doing];
    if ([[[_destText documentView] string] length] == 0) {
        NSLog(@"DoLangTrans:Source Lang(%@) -> Dest Lang(%@)", _sourceLanguage.titleOfSelectedItem, _destLanguage.titleOfSelectedItem);
        _playButton.enabled = NO;
        [self doLangTrans];
    } else {
        NSLog(@"doSpeech");
        _playButton.enabled = NO;
        [self doSpeech];
    }
//    [self done];
}
@end
