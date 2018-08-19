//
//  MessagesHandlerToSignaling.h
//  VideoCall-WebRTC
//
//  Copyright 2018  Karina Betzabe Romero Ulloa
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
