#import "ym2149Synth.h"
#import <string.h>

//static id _sharedInstance;
#define MSX_CLK (3579545)


@implementation ym2149Synth

- (id) init {
    self = [super init];
    printf("Audio created\n");
    shortMax = 1.0f / ((float) 0x7fff);
    bufferSize=44100;
    
    sccChip = SCC_new(3579545, 44100);
    
    
    
    m_OutputUnit = [[CAOutputUnit alloc] init];
    
    myAudioProperty.mChannelsPerFrame = 2;
    myAudioProperty.mBitsPerChannel = 32;
    myAudioProperty.mBytesPerFrame = 4;
    myAudioProperty.mBytesPerPacket = 4;
    
    #ifdef __BIG_ENDIAN__
        myAudioProperty.mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    #else
        myAudioProperty.mFormatFlags = kLinearPCMFormatFlagIsFloat | kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    #endif
    
    myAudioProperty.mFormatID = kAudioFormatLinearPCM;
    myAudioProperty.mFramesPerPacket = 1;
    myAudioProperty.mSampleRate = 44100;
    
    returnedValue = [m_OutputUnit setDesiredFormat:myAudioProperty];
    [m_OutputUnit setDelegate:self];
    [m_OutputUnit start];
    
    return self;
}

- (id)generateBuffer
{
    NSLock *threadLock;
    threadLock = [[NSLock alloc] init];
    [threadLock lock];
    
    PSG_setMask(psgChip, 7);
    for(int i=0; i<bufferSize; i++)
    {
        
        // Calculate
        psgBuffer[whichBuffer][i] = PSG_calc(psgChip);

    }

    whichBuffer=!whichBuffer;

    [threadLock unlock];
    
    return 0;
    
}

- (void)outputUnit:(CAOutputUnit *)outputUnit requestFrames:(UInt32)frames data:(AudioBufferList *)data flags:(AudioUnitRenderActionFlags *)flags timeStamp:(const AudioTimeStamp *)timeStamp;
{
    int i = 0 ,j = 0;
    float *bufferLeft, *bufferRight;
    
    bufferLeft = (float *)(data->mBuffers[0].mData);
    bufferRight = (float *)(data->mBuffers[1].mData);
    
    for (j = 0; j < data->mBuffers[i].mDataByteSize/4; j ++)
    {
        bufferRight[j] = ((float)psgBuffer[!whichBuffer][j]) * shortMax;
        bufferLeft[j] = ((float)psgBuffer[!whichBuffer][j]) * shortMax;
    }
    [NSThread detachNewThreadSelector:@selector(generateBuffer) toTarget:self withObject:nil];

}



@end