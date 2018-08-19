//
//  PeerConnectionClient.h
//  VideoCall-WebRTC
//
//  Copyright 2018  Karina Betzabe Romero Ulloa
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCDataChannel.h>
#import <WebRTC/RTCDataChannelConfiguration.h>
#import <WebRTC/RTCIceCandidate.h>
#import <WebRTC/RTCCameraVideoCapturer.h>

#import "MessagesHandlerToSignaling.h"

@protocol RTCShowVideoProtocol <NSObject>
- (void)didReceiveLocalStream:(RTCMediaStream *)localVideoTrack;
- (void)didReceiveRemoteStream:(RTCMediaStream *)remoteVideoTrack;
- (void)didReceiveData:(NSString*)message;
@end

@interface PeerConnectionClient : NSObject<RTCPeerConnectionDelegate, CSonMessageProtocol, RTCDataChannelDelegate>

@property(nonatomic) id<RTCShowVideoProtocol> videoDelegate;
@property(strong, nonatomic) MessagesHandlerToSignaling *messageHandler;
@property(strong, nonatomic) NSString *url;
@property(strong, nonatomic) NSString *userName;
@property(strong, nonatomic) NSString *otherName;

@property(nonatomic) RTCPeerConnection *peerConnection;
@property(nonatomic) RTCDataChannel *dataChannel;
@property(nonatomic) RTCDataChannel* remoteDataChannel;
@property(nonatomic) RTCPeerConnectionFactory *factory;
@property(nonatomic) NSMutableArray *iceServers;
@property(nonatomic) id<RTCDataChannelDelegate> remoteDelegate;

-(id)initWhitNameUrlVideoDelegateEnableDataChannel :(NSString*)name :(NSString*)url :(id) videoDelegate :(bool) enableDataChannel;
-(void)call:(NSString*)otherName;
-(void)hangUp;
-(BOOL)sendMessageDataChannel:(NSString*) message;
@end
