#import <Cocoa/Cocoa.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>

@interface CAOutputUnit : NSObject {
	AudioUnit m_OutputUnit;
    AUGraph graph;
    
    id m_Delegate;
}
- (void)start;
- (void)stop;
- (id)delegate;
- (void)setDelegate:(id)delegate;
- (AudioUnit)outputUnit;
- (BOOL)isRunning;
- (AudioStreamBasicDescription)deviceFormat;
- (AudioStreamBasicDescription)desiredFormat;
- (ComponentResult)setDesiredFormat:(AudioStreamBasicDescription)desiredFormat;
- (void)matchFormat;
@end
@interface NSObject(CAOutputUnitDelegate)
- (void)outputUnit:(CAOutputUnit *)outputUnit requestFrames:(UInt32)frames data:(AudioBufferList *)data flags:(AudioUnitRenderActionFlags *)flags timeStamp:(const AudioTimeStamp *)timeStamp;
@end