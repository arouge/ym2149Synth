//
// CAOutputUnit.m
// 
// Created by Alex Rouge

#import "CAOutputUnit.h"

@implementation CAOutputUnit
static OSStatus CAOutputUnitRenderProc(
                            void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList *ioData)
{
 //   NSAutoreleasePool *ap = [[NSAutoreleasePool alloc] init];
    CAOutputUnit *output = (__bridge CAOutputUnit *)inRefCon;
    OSStatus theErr = noErr;
    if([[output delegate] respondsToSelector:@selector(outputUnit:requestFrames:data:flags:timeStamp:)])
    {
        [[output delegate] outputUnit:output requestFrames:inNumberFrames data:ioData flags:ioActionFlags timeStamp:inTimeStamp];
    }
 //   [ap release];
    return theErr;
}

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString[20];
    *(UInt32 *)(errorString+1) = CFSwapInt32HostToBig(error);
    if(isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4]))
    {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    }
    else
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

- (void)dealloc
{
    if(m_OutputUnit)
    {
        AudioOutputUnitStop(m_OutputUnit);
        AudioUnitUninitialize(m_OutputUnit);
        AudioComponentInstanceDispose(m_OutputUnit);
    }
//    [super dealloc];
}

- (void)matchFormat
{
    [self setDesiredFormat:[self deviceFormat]];
}

- (AudioUnit)outputUnit
{
    if(m_OutputUnit == nil)
    {
        CheckError(NewAUGraph(&graph), "NewAUGraph failed");
        
        AudioComponentDescription desc = { 0 };
        desc.componentType = kAudioUnitType_Output;
        desc.componentSubType = kAudioUnitSubType_DefaultOutput;
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        
        AudioComponent comp = AudioComponentFindNext(NULL, &desc);
        if (comp == NULL)
        {
            printf("Can't get output unit.\n");
            exit (-1);
        }
        
        CheckError(AudioComponentInstanceNew(comp, &m_OutputUnit), "Couldn't open component for outputUnit");
        AURenderCallbackStruct input;
        input.inputProc = CAOutputUnitRenderProc;
        input.inputProcRefCon = (__bridge void * _Nullable)(self);
        CheckError(AudioUnitSetProperty(m_OutputUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &input, sizeof(input)), "AudioUnitSetProperty failed");
        CheckError(AudioUnitInitialize(m_OutputUnit), "Couldn't initialize output unit");
    }
    return m_OutputUnit;
    
}

- (void)start
{
    if([self outputUnit] && ![self isRunning])
        AudioOutputUnitStart([self outputUnit]);
}

- (void)stop
{
    if([self outputUnit] && [self isRunning])
        AudioOutputUnitStop([self outputUnit]);
}

- (id)delegate
{
    return m_Delegate;
}

- (void)setDelegate:(id)delegate
{
    m_Delegate = delegate;
}

- (BOOL)isRunning
{
    UInt32 isRunning = 0;
    if(m_OutputUnit)
    {
        UInt32 propertySize = sizeof(UInt32);
        AudioUnitGetProperty([self outputUnit], kAudioOutputUnitProperty_IsRunning, kAudioUnitScope_Global, 0, &isRunning, &propertySize);
    }
    return (isRunning != 0);
}

- (AudioStreamBasicDescription)deviceFormat
{
    AudioStreamBasicDescription deviceFormat;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    
    AudioUnitGetProperty([self outputUnit], kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &deviceFormat, &size);
    return deviceFormat;
}

- (AudioStreamBasicDescription)desiredFormat;
{
    AudioStreamBasicDescription desiredFormat;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    
    AudioUnitGetProperty([self outputUnit],
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &desiredFormat,
                         &size);
    return desiredFormat;
}

- (ComponentResult)setDesiredFormat:(AudioStreamBasicDescription)desiredFormat
{
    ComponentResult result = AudioUnitSetProperty([self outputUnit],
                                                  kAudioUnitProperty_StreamFormat,
                                                  kAudioUnitScope_Input,
                                                  0,
                                                  &desiredFormat,
                                                  sizeof(AudioStreamBasicDescription));
	return result;
}


@end