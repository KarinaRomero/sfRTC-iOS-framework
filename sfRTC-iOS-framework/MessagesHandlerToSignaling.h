//
//  MessagesHandlerToSignaling.h
//  VideoCall-WebRTC
//
//  Created by Karina Betzabe Romero Ulloa on 29/05/18.
//  Copyright © 2018 Karina Betzabe Romero Ulloa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WebRTC/RTCSessionDescription.h>
#import <SocketRocket/SocketRocket.h>

@protocol CSonMessageProtocol <NSObject>

- (void)onLogin:(BOOL *)success;
- (void)onOffer:(NSString *)offer otherName:(NSString*)otherName;
- (void)onAnswer:(NSString *)answer;
- (void)onCandidate:(NSString*)sdp midParameter:(NSString*)mid lineiIndexParameter:(int)mLineIndex;
@end

@interface MessagesHandlerToSignaling : NSObject <SRWebSocketDelegate>
typedef enum {
    login,
    offer,
    answer,
    candidate,
    leave
} signalingMessages;

@property (nonatomic) id<CSonMessageProtocol> delegate;

@property (nonatomic) NSString* url;
@property (nonatomic) NSString* userName;
@property (nonatomic) SRWebSocket* webSocket;
@property (nonatomic) NSMutableDictionary * cases;


-(id)initWhitNameURL: (NSString*) userName : (NSString *) url : (id) delegate;
-(void)sendMessage:(NSString *) message;
-(void)close;

@end
