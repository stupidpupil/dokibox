//
//  LastFMScrobblerPluginAPICall.m
//  dokibox
//
//  Created by Miles Wu on 16/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "LastFMScrobblerPluginAPICall.h"
#import <CommonCrypto/CommonDigest.h>

#define API_KEY @"49b84b69fd527ce2cee337b28b266fe3"
#define API_SECRET @"07442538f74767dfb2526800c8525d3b"

@implementation LastFMScrobblerPluginAPICall

-(id)init
{
    self = [super init];
    if(self) {
        _parameters = [[NSMutableDictionary alloc] init];
        [self setParameter:@"api_key" value:API_KEY];
    }
    return self;
}

-(void)setParameter:(NSString*)name value:(NSString*)value
{
    [_parameters setValue:value forKey:name];
}

-(NSXMLDocument*)performGET
{
    return [self performRequest:NO];
}

-(NSXMLDocument*)performPOST
{
    return [self performRequest:YES];
}

-(NSXMLDocument*)performRequest:(BOOL)isPost;
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"https://ws.audioscrobbler.com/2.0/"];

    NSMutableString *parameterString = [[NSMutableString alloc] init];
    NSMutableString *signatureString = [[NSMutableString alloc] init];
    NSArray *sortedParameterNames = [[_parameters allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for(NSString *name in sortedParameterNames) {
        [parameterString appendString:name];
        [parameterString appendString:@"="];
        [parameterString appendString:[[_parameters objectForKey:name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [parameterString appendString:@"&"];
        
        [signatureString appendString:name];
        [signatureString appendString:[_parameters objectForKey:name]];
    }
    [signatureString appendString:API_SECRET];
    
    [parameterString appendString:@"api_sig="];
    
    const char *sigstring = [signatureString UTF8String];
    unsigned char digest[16];
    CC_MD5(sigstring, (CC_LONG)strlen(sigstring), digest);
    for(unsigned int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [parameterString appendFormat:@"%02x", digest[i]];
        
    NSMutableURLRequest *urlReq;
    if(isPost) {
        urlReq = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [urlReq setHTTPMethod:@"POST"];
        [urlReq setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        [urlString appendString:@"?"];
        [urlString appendString:parameterString];
        urlReq = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    }

    NSError *err;
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&err];
    if(err) {
        DDLogError(@"HTTP error");
        DDLogError(@"%@", [err localizedDescription]);
        return nil;
    }
        
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:&err];
    if(err) {
        DDLogError(@"XML parsing error");
        DDLogError(@"%@", [err localizedDescription]);
        return nil;
    }
    
    return doc;
}

+(NSString *)apiKey
{
    return API_KEY;
}

@end
