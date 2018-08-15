//
//  PeerConnectionClient.h
//  VideoCall-WebRTC
//
//  Created by Karina Betzabe Romero Ulloa on 04/06/18.
//  Copyright © 2018 Karina Betzabe Romero Ulloa. All rights reserved.
//

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
