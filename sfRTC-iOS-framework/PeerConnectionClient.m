//
//  PeerConnectionClient.m
//  VideoCall-WebRTC
//
//  Copyright 2018  Karina Betzabe Romero Ulloa
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "PeerConnectionClient.h"

@implementation PeerConnectionClient

static NSString *const urlStun = @"stun:stun.l.google.com:19302";
NSDictionary* mandatoryConstraints;
NSDictionary* optionalConstrains;

RTCIceServer *iceServer;
RTCMediaConstraints * rtcConstrains;
RTCConfiguration * rtcConfiguration;
RTCMediaStream *_localStream;
RTCMediaStream *_remoteStream;
RTCDataChannelConfiguration *dataChannelConfigurations;
bool _enableDataChannel;

-(id)initWhitNameUrlVideoDelegateEnableDataChannel :(NSString*)name :(NSString*)url :(id) videoDelegate :(bool) enableDataChannel{
    if ( self = [super init] ) {
        _enableDataChannel = enableDataChannel;
        _remoteDelegate = self;
        _userName = name;
        _url = url;
        _videoDelegate = videoDelegate;
        _iceServers = [NSMutableArray array];
        [self createLocalStream];
        return self;
    }
    return nil;
}

- (void)createLocalStream {
    //Initialize Signaling connection
    _messageHandler = [[MessagesHandlerToSignaling alloc] initWhitNameURL:_userName:_url:self];
    
    // Create PeerConnectionFactory
    _factory =[[RTCPeerConnectionFactory alloc] init];
    
    // Create local stream
    _localStream =[_factory mediaStreamWithStreamId:@"ARDAMS"];
    
    // Create sources
    RTCAVFoundationVideoSource *source =[_factory avFoundationVideoSourceWithConstraints:nil];
    RTCVideoTrack *videoTrack = [_factory videoTrackWithSource:source trackId:@"ARDAMSv0"];
    
    RTCAudioSource *audioSource = [_factory audioSourceWithConstraints:rtcConstrains];
    RTCAudioTrack *track = [_factory audioTrackWithSource:audioSource
                                                  trackId:@"ARDAMSa0"];
    if (videoTrack) {
        [_localStream addVideoTrack:videoTrack];
        [_localStream addAudioTrack:track];
        NSLog(@"Local Stream added................... :D");
    }
    // Callback to receive local video and audio
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_videoDelegate didReceiveLocalStream:_localStream];
    });
    // Add ice servers
    iceServer = [[RTCIceServer alloc] initWithURLStrings:@[urlStun]];
    [_iceServers addObject:iceServer];
    
    // Create constrains
    mandatoryConstraints = @{
                             @"OfferToReceiveAudio" : @"true",
                             @"OfferToReceiveVideo" : @"true"
                             };
    optionalConstrains = @{@"DtlsSrtpKeyAgreement":@"true"};
    
    rtcConstrains = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:optionalConstrains];
    
    rtcConfiguration = [[RTCConfiguration alloc] init];
    rtcConfiguration.iceServers = _iceServers;
    
    //create peerConnection
    _peerConnection = [_factory peerConnectionWithConfiguration:rtcConfiguration constraints: rtcConstrains delegate:self];
    // If enableDataChannel, create DataChannel
    if(_enableDataChannel){
        [self setupDataChannelConnection];
    }
    [_peerConnection addStream:_localStream];
}
-(void)setupDataChannelConnection {
    dataChannelConfigurations = [[RTCDataChannelConfiguration alloc] init];
    dataChannelConfigurations.isNegotiated = NO;
    dataChannelConfigurations.isOrdered = YES;
    dataChannelConfigurations.maxRetransmits = 30;
    dataChannelConfigurations.channelId = 1;
    
    _dataChannel = [_peerConnection dataChannelForLabel:@"DataChannel" configuration:dataChannelConfigurations];
    _dataChannel.delegate = self;
}
- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate);
    }
    return maxFramerate;
}

-(void)call:(NSString*)otherName {
    _otherName = otherName;
    [self createOffer];
}

-(void)hangUp {
    NSDictionary *formatoJson= @{@"type": @"leave", @"name": _otherName};
    id jsonObject = [NSJSONSerialization dataWithJSONObject:formatoJson options:0 error:nil];
    // Send leave through the signaling channel of our application
    [self->_messageHandler sendMessage:jsonObject];
    // Close Peer Connection
    [self disconnect];
}

-(void)createOffer {
    [_peerConnection offerForConstraints:rtcConstrains completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        __weak RTCPeerConnection *peerConnection = self->_peerConnection;
        NSLog(@"Llamando a setLocalDescriptionOffer");
        [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer) {
                
                NSDictionary *formatoJson= @{@"type": @"offer", @"offer": @{@"type": @"offer", @"sdp": peerConnection.localDescription.sdp}, @"name": self->_otherName};
                id jsonObject = [NSJSONSerialization dataWithJSONObject:formatoJson options:0 error:nil];
                // Send offer through the signaling channel of our application
                [self->_messageHandler sendMessage:jsonObject];
            }
        }];
    }];
}

#pragma mark--RTCPeerConnectionDelegate
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream {
    //Process the stream
    _remoteStream = stream;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_videoDelegate didReceiveLocalStream:_localStream];
        [self->_videoDelegate didReceiveRemoteStream:_remoteStream];
    });
    
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    
}

-(BOOL)sendMessageDataChannel:(NSString*) message {
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding] isBinary:NO];
    if(_remoteDataChannel != nil){
        BOOL x = [_remoteDataChannel sendData:buffer];
        return x;
    } else{
        BOOL x = [_dataChannel sendData:buffer];
        return x;
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    NSDictionary *formatoJson= @{@"type": @"candidate", @"candidate": @{@"candidate": candidate.sdp, @"sdpMid": candidate.sdpMid, @"sdpMLineIndex": [NSNumber numberWithInt:candidate.sdpMLineIndex]}, @"name": _otherName};
    id jsonObject = [NSJSONSerialization dataWithJSONObject:formatoJson options:0 error:nil];
    [_messageHandler sendMessage:jsonObject];
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didOpenDataChannel:(nonnull RTCDataChannel *)dataChannel {
    _remoteDataChannel = dataChannel;
    _remoteDataChannel.delegate = _remoteDelegate;
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream {
   
}

- (void)peerConnectionShouldNegotiate:(nonnull RTCPeerConnection *)peerConnection {
    
}

#pragma mark--RTCDataChannelDelegate
- (void)dataChannel:(nonnull RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(nonnull RTCDataBuffer *)buffer {
    NSData* messageData = buffer.data;
    NSString* message = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    [_videoDelegate didReceiveData:message];
}

- (void)dataChannelDidChangeState:(nonnull RTCDataChannel *)dataChannel {
    
}

#pragma mark--CSonMessageDelegate

- (void)onLogin:(BOOL *)success {
    NSLog(@"succes: %@", (success ? @"True" : @"False"));
}

- (void)onAnswer:(NSString *)answer {
    //NSLog(@"%@", answer);
    RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:answer];
    __weak RTCPeerConnection *peerConnection = _peerConnection;
    [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"An error has ocurred: %@",error);
        }
    }];
}

- (void)onCandidate:(NSString*)sdp midParameter:(NSString*)mid lineiIndexParameter:(int)mLineIndex {
    //NSLog(@"Candidate: %@ SDPMid: %@ index: %d ",sdp,mid,mLineIndex);
    RTCIceCandidate *rtcCandidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:mLineIndex sdpMid:mid];
    [_peerConnection addIceCandidate:rtcCandidate];
}

- (void)onOffer:(NSString *)offer otherName:(NSString*)otherName {
    //NSLog(@"%s", __func__);
    _otherName = otherName;
    
    RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:offer];
    __weak RTCPeerConnection *peerConnection = _peerConnection;
    
    // Set remote description
    NSLog(@"Llamando a setRemoteDescription onOffer");
    [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
        if(error!=nil){
            NSLog(@"An error has ocurred: %@",error);
        }else{
            [self createAnswer];
        }
    }];
}

-(void)createAnswer {
    [_peerConnection answerForConstraints:rtcConstrains completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        __weak RTCPeerConnection *peerConnection = self->_peerConnection;
        __weak NSString *weakName = self->_otherName;
        NSLog(@"Llamando a setLocalDescription onOffer");
        [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            NSDictionary *formatoJson= @{@"type": @"answer", @"answer": @{@"type": @"answer", @"sdp": peerConnection.localDescription.sdp}, @"name": weakName};
            id jsonObject = [NSJSONSerialization dataWithJSONObject:formatoJson options:0 error:nil];
            // Send response through the signaling channel of our application
            [self->_messageHandler sendMessage:jsonObject];
            
        }];
    }];
}

-(void)onLeave {
    [self disconnect];
}

-(void)disconnect {
    [_dataChannel close];
    [_peerConnection close];
    [_messageHandler close];
    _localStream = nil;
    _remoteStream = nil;
    _peerConnection = nil;
    _dataChannel = nil;
    _messageHandler = nil;
}
@end















