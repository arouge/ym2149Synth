#import "ym2149.h"

static id _sharedInstance; 

@implementation ym2149

/*
+(id)sharedInstance { 
    if (!_sharedInstance) 
        _sharedInstance = [[[self class] alloc] init]; 
    
    return _sharedInstance; 
} 

- (id) init { 
    if (_sharedInstance) { 
        [self dealloc];
        self = [_sharedInstance retain];
    } else { 
        self = [super init]; 
        if (self != nil) { 
			
		}
        _sharedInstance = self; 
    }
	
	return self; 
} 
*/
- (id)generateBuffer
{	
 //   NSAutoreleasePool * localPool = [[NSAutoreleasePool alloc] init];
	NSLock *threadLock;

	threadLock = [[NSLock alloc] init];
	
	[threadLock lock];
	

	
	
//		KSSPLAY_calc(kssplay, shortBuffer[whichBuffer], [[self bufferSize] intValue]) ;
	

    
	return 0;

}

- (void)outputUnit:(CAOutputUnit *)outputUnit requestFrames:(UInt32)frames data:(AudioBufferList *)data flags:(AudioUnitRenderActionFlags *)flags timeStamp:(const AudioTimeStamp *)timeStamp;
{
 //   NSAutoreleasePool * localPool = [[NSAutoreleasePool alloc] init];
    int i = 0 ,j = 0;
    float *bufferLeft, *bufferRight;
	
	bufferLeft = (float *)(data->mBuffers[0].mData);
	bufferRight = (float *)(data->mBuffers[1].mData);

	for (j = 0; j < data->mBuffers[i].mDataByteSize/4; j ++)
	{
		
    //    bufferRight[j] = ((float)shortBuffer[!whichBuffer][position]) * shortMax;
	//	bufferLeft[j] = ((float)shortBuffer[!whichBuffer][position+1]) * shortMax;

		if(position>=(([[self bufferSize] intValue]*2)-2))		{
			position = 0;
         
            whichBuffer=!whichBuffer;
            
            [NSThread detachNewThreadSelector:@selector(generateBuffer) toTarget:self withObject:nil];	
		}
		
		position=position+2;
	}

//	[localPool release];

} 



@end
