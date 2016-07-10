#import <Cocoa/Cocoa.h>
#import "CAOutputUnit.h"
#import "emu2212.h"


@interface ym2149Synth : NSObject
{
    float shortMax ; //= 1.0f / ((float) 0x7fff);
    bool whichBuffer;
    CAOutputUnit *m_OutputUnit;
    AudioStreamBasicDescription myAudioProperty;
    ComponentResult	returnedValue;
    
    SCC *sccChip;
    
    short sccBuffer[2][44100];
    short position;
    short bufferSize;
}


- (id)generateBuffer;



@end