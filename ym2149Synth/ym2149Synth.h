#import <Cocoa/Cocoa.h>
#import "CAOutputUnit.h"
//#import "emu2212.h"
#import "emu2149.h"

@interface ym2149Synth : NSObject
{
    float shortMax ; //= 1.0f / ((float) 0x7fff);
    bool whichBuffer;
    CAOutputUnit *m_OutputUnit;
    AudioStreamBasicDescription myAudioProperty;
    ComponentResult	returnedValue;
    
    PSG *psgChip;
    
    short psgBuffer[2][44100];
    int position;
    int bufferSize;
    int sampleRate;
}


- (id)generateBuffer;



@end