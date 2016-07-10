#import "ym2149Synth.h"
#import <string.h>
#import <math.h>

@implementation ym2149Synth
//#define MSX_CLK (3579545)

- (id) init { 
    self = [super init];
    printf("Audio created\n");
    shortMax = 1.0f / ((float) 0x7fff);
    bufferSize=512;
    sampleRate = 44100;
    
    psgChip = PSG_new(3579545*2, sampleRate);
    
    /*
     BiFi: for channel 2 it's regs 2 and 3 in stead of 0 and 1, reset bit 1 in reg 7 and set volume in reg 9
     BiFi: for channel 3 it's regs 4 and 5, reset bit 2 in reg 7 and set volume in reg 10
    */
    
    PSG_set_quality(psgChip, 1);
    
    //Channel 1
    
    PSG_writeReg(psgChip, 0, 255); //Freq low bit
    PSG_writeReg(psgChip, 1, 1);   //Freq high bit
    PSG_writeReg(psgChip, 7, 190); //mask
    PSG_writeReg(psgChip, 8, 15);  //Channel Volume
  
    PSG_writeReg(psgChip, 2, 200); //Freq low bit
    PSG_writeReg(psgChip, 3, 0); //Freq high bit
    PSG_writeReg(psgChip, 7, 188); //mask
    PSG_writeReg(psgChip, 9, 15); //Channel Volume
  
    PSG_writeReg(psgChip, 4, 245); //Freq low bit
    PSG_writeReg(psgChip, 5, 2); //Freq high bit
    PSG_writeReg(psgChip, 7, 186); //mask
    PSG_writeReg(psgChip, 10, 15); //Channel Volume
   
    
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
    myAudioProperty.mSampleRate = sampleRate;
    
    m_OutputUnit = [[CAOutputUnit alloc] init];

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
    
    whichBuffer=!whichBuffer;

    for(int i=0; i<=bufferSize; i++)
    {
        // Calculate
        psgBuffer[whichBuffer][i] = PSG_calc(psgChip);
    }
    
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
        
        if(position>=bufferSize)
        {
            position = 0;
            
            [NSThread detachNewThreadSelector:@selector(generateBuffer) toTarget:self withObject:nil];
        }
        
        position++;
    }

}

@end
