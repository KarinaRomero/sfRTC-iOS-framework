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
    
## Demo 

Check the [sfRTC-ios-demo](https://github.com/KarinaRomero/sfRTC-ios-demo).

## Usages

To create a [simple mirror]().

## License

This framework is licenced under [MIT Licence](https://opensource.org/licenses/MIT).
