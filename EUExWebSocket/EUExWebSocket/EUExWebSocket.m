//
//  EUExWebSocket.m
//  EUExWebSocket
//
//  Created by wang on 16/11/17.
//  Copyright © 2016年 com.dingding.com. All rights reserved.
//

#import "EUExWebSocket.h"
#import <SocketRocket/SocketRocket.h>

@interface EUExWebSocket()<SRWebSocketDelegate>
@property(nonatomic,assign)int type;
@end
@implementation EUExWebSocket{
    SRWebSocket *_webSocket;
}

-(void)open:(NSMutableArray*)inArguments{
    if(inArguments.count<1){
        return;
    }
    ACArgsUnpack(NSDictionary* info) = inArguments;
    NSString* url = info[@"url"];
    if(!_webSocket){
        _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url]];
        _webSocket.delegate = self;
        [_webSocket open];
    }
   
}

- (void)send:(NSMutableArray*)inArguments{
    ACArgsUnpack(NSDictionary* info)=inArguments;
    NSString *message = info[@"data"];
    /*
    if([mes isKindOfClass:[NSString class]]){
        isString = YES;
        if (base64) {
            NSData *nsdata = [mes dataUsingEncoding:NSUTF8StringEncoding];
            message = [nsdata base64EncodedStringWithOptions:0];
            isBase64 = YES;
        }else{
            message = mes;
        }
    }
    if([mes isKindOfClass:[NSNumber class]]){
        message = [mes stringValue];
        isString = NO;
    }
    if([mes isKindOfClass:[NSDictionary class]] || [mes isKindOfClass:[NSArray class]]){
        message = [mes ac_JSONFragment];
        isString = NO;
    }
     */
    message = message?:@" ";
    
    [_webSocket sendString:message error:NULL];
    
}


-(void)close:(NSMutableArray*)inArguments{
    if (_webSocket) {
        [_webSocket close];
    }
    
}

///--------------------------------------
#pragma mark - SRWebSocketDelegate
///--------------------------------------

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWebSocket.onConnect" arguments:ACArgsPack(nil)];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(nonnull NSString *)string
{
    NSString *returnString = string;
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWebSocket.onMessage" arguments:ACArgsPack(returnString)];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _webSocket.delegate = nil;
    _webSocket = nil;
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWebSocket.onClose" arguments:ACArgsPack(nil)];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"WebSocket received pong:%@",pongPayload);
}

@end
