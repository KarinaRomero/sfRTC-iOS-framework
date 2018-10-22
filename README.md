# sfRTC-iOS-framework

This is a framework to simplify implementation webRTC protocol to iOS apps.

## Tools

- Xcode IDE.

## Generate module library

- Open the sfRTC-iOS-framework project and select Generic iOS Device or other.

- Then, run the project.

- Next, expand Products gruop and select sfRTC_iOS_framework.framework.

- Finally, right click and select “Show in finder” option.

## Add framework to your project

- Firstly create a new Single View App.

- Next, into your project create new group then drag the sfRTC_iOS_framework.Framework into the group.

- In proyect sfRTC_iOS_framework, into dependences folder drag SocketRocket.framework and WebRTC.framework to your custom gruop too.

- Finally select your project target and General > Embedded Binaries add the three .framework files.

## Usages

To implement the framework you must do the following:

*Note: Before make sure the signaling channel is running, to more information go to [https://github.com/KarinaRomero/signaling](https://github.com/KarinaRomero/signaling)

- In your view Controller.h file :
	- Import the headers PeerConnectionClient.h, RTCEAGLVideoView.h, RTCVideoTrack.h
	- Add elements type RTCEAGLVideoView, RTCVideoTrack and AVCaptureVideoPreviewLayer
	- Implement the RTCEAGLVideoViewDelegate and RTCShowVideoProtocol

```objective-c
#import <sfRTC_iOS_framework/PeerConnectionClient.h>
#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCVideoTrack.h>

// RTCEAGLVideoViewDelegate to show video
// RTCShowVideoProtocol to receive the local an remote video and data
@interface ViewControllerCall : UIViewController <RTCEAGLVideoViewDelegate, RTCShowVideoProtocol, UITextFieldDelegate> {

…

// Elements type View to show video local and remote video
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localView;
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *remoteView;

// Elements to render track local and remote video
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

// To manage the video preview
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
}
```

- In your Controller.m file create the following variables

```objective-c
@interface ViewController ()

    // To create a clientWebRTC
    @property (nonatomic) PeerConnectionClient* peerConnectionClient;

    // Your URL signaling
    @property (nonatomic, assign) NSString* url;

    // To render the video local and remote in the view
    @property (nonatomic, strong) RTCMediaStream *localStream;
    @property (nonatomic, strong) RTCMediaStream *remoteStream;
@end
```

- In the method viewDidLoad setup the client

```objective-c
- (void)viewDidLoad {

…

    // Initialize the url
    _url = @"ws://your.url.signaling";

    // Initialize the client to connect, this constructor receive
    // (NSString*)name           Name or id the user conected
    // (NSString*)url            The url signaling channel
    // (id) videoDelegate        The delegate RTCShowVideoProtocol
    // (bool) enableDataChannel  Boolean value to enable data channel
    _peerConnectionClient =  [[PeerConnectionClient alloc] initWhitNameUrlVideoDelegateEnableDataChannel:_userName :_url: self: true];

}
```

- To manage the functions call, answer, send message and hang up, you should the call the following methods :

*Note: For this example, buttons were added to make the call , hang up, answer and send messages.

```objective-c
// Button call
- (IBAction)actionBtnCall:(id)sender {

// This method allows you to call to other user, receive the name or id of string type
    [_peerConnectionClient call:_txtCallTo.text];
}

// Button hang up
- (IBAction)actionBtnHangUp:(id)sender {

// This method allows you to hang up a call
     [_peerConnectionClient hangUp];
}

// Button answer
- (IBAction)actionBtnAnswer:(id)sender {

// This method allows you to answer
     [_peerConnectionClient answer];
}

// Button send message
- (IBAction)actionBtnSendMessage:(id)sender {

// This method allow you to send message, receive a string type value
    [_peerConnectionClient sendMessageDataChannel:”Hello world!”];
}
```

- Implement the delegate RTCShowVideoProtocol methods :

```objective-c
// This method returns the received messages by the data channel.
- (void)didReceiveData:(NSString *)message {
    NSLog(@"%@", message);
}

// This method return the local video
- (void)didReceiveLocalStream:(RTCMediaStream *)localVideoTrack
{
    // Set the local video track.
    self.localStream = localVideoTrack;

    // Get the size view
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    // Create the RTCEAGLVideoView to show video, receive the size view prefer
    self.localView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(0, height/3, width/2, height/3+100)];

    // Add as a subview to local view
    [self.view addSubview:self.localView];

    // Verifying if the track has content
    if (self.localStream.videoTracks.count > 0) {

        RTCVideoTrack *videoTrack = self.localStream.videoTracks.firstObject;

        // Render the video in the view
        [videoTrack addRenderer:self.localView];
    }
}

// This method returns the video and audio remote
- (void)didReceiveRemoteStream:(RTCMediaStream *)remoteVideoTrack
{
    // Set the local video track.
    self.remoteStream = remoteVideoTrack;

    // Get the size view
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    // Create the RTCEAGLVideoView to show video, receive the size view prefer
    self.remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(width/2, height/3, width/2, height/3+100)];

    // Add as a subview to remote view
    [self.view addSubview:self.remoteView];

    // Verifying if the track has content
    if (self.remoteStream.videoTracks.count > 0) {
        RTCVideoTrack *videoTrack = self.remoteStream.videoTracks.firstObject;

        // Render the video in the view
        [videoTrack addRenderer:self.remoteView];
    }
}

// When a call is received, this method returns the id or name of the calling user.
- (void)didReceiveCall:(NSString *)callId {
    NSLog(@"%@", callId);
}

// This method notify when the remote video is removed.
- (void)didRemoveRemoteStream:(NSString *)callId {
    NSLog(@"%@", callId);

    // Set the remote video when is removed
    self.remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:self.remoteView];
}

// This method returns a notification the call status
- (void)didStatusChanged:(NSString *)status {
    NSLog(@"%@", status);
}
```

*To create a [simple mirror]().

## Demo

Check the [sfRTC-ios-demo](https://github.com/KarinaRomero/sfRTC-ios-demo).

## License

This framework is licenced under [MIT Licence](https://opensource.org/licenses/MIT).
