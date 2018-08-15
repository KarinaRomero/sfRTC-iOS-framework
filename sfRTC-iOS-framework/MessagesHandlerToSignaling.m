//
//  MessagesHandlerToSignaling.m
//  VideoCall-WebRTC
//
//  Created by Karina Betzabe Romero Ulloa on 29/05/18.
//  Copyright © 2018 Karina Betzabe Romero Ulloa. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import "MessagesHandlerToSignaling.h"

@implementation MessagesHandlerToSignaling

-(id)initWhitNameURL: (NSString*) userName : (NSString *) url : (id) delegate {
    if ( self = [super init] ) {
        _url = url;
        _userName = userName;
        _delegate = delegate;
        [self setupConnection];
        return self;
    }
    return nil;
}

-(void)setupConnection {
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:_url]];
    _webSocket.delegate = self;
    
    _cases = [[NSMutableDictionary alloc] initWithCapacity:2];
    [_cases setObject:[NSNumber numberWithInt:login] forKey:@"login"];
    [_cases setObject:[NSNumber numberWithInt:offer] forKey:@"offer"];
    [_cases setObject:[NSNumber numberWithInt:answer] forKey:@"answer"];
    [_cases setObject:[NSNumber numberWithInt:candidate] forKey:@"candidate"];
    [_cases setObject:[NSNumber numberWithInt:leave] forKey:@"leave"];
    
    [_webSocket open];
}

-(void)sendMessage:(NSString *)message {
    [_webSocket send:message];
}

-(void)close {
    [_webSocket close];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSDictionary *formatoJson= @{@"type": @"login", @"name": _userName};
    
    id jsonObject = [NSJSONSerialization dataWithJSONObject:formatoJson options:0 error:nil];
    
    [self sendMessage:jsonObject];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self setupConnection];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self setupConnection];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if([message isEqualToString:@"Hello world"]){
    }else{
        NSError *jsonError;
        NSData *objectData = [message dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if(jsonError){
            NSLog(@"Error al leer json: %@",jsonError);
        }
        
        NSString *type = [json objectForKey:@"type"];
        BOOL success;
        
        switch ([[_cases objectForKey: type ] intValue])
        {
            case login:
                success=[[json objectForKey:@"success"] boolValue];
                [_delegate onLogin:&success];
                break;
            case offer:
                [_delegate onOffer:[[json objectForKey:@"offer"]valueForKey:@"sdp"] otherName:[json objectForKey:@"name"]];
                break;
            case answer:
                [_delegate onAnswer:[[json objectForKey:@"answer"]valueForKey:@"sdp"]];
                break;
            case candidate:
                [_delegate onCandidate: [[json objectForKey:@"candidate"]valueForKey:@"candidate"]
                          midParameter: [[json objectForKey:@"candidate"]valueForKey:@"sdpMid"]
                   lineiIndexParameter: (int)[[json objectForKey:@"candidate"]valueForKey:@"sdpMLineIndex"]
                 ];
                break;
            case leave:
                [_delegate onLogin:&success];
                break;
            default:
                NSLog(@"The message is not recognized.");
                break;
        }
    }
}
@end
