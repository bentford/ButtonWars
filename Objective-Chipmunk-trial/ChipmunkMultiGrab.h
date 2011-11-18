#import "ObjectiveChipmunk.h"


@interface ChipmunkMultiGrab : NSObject {
	ChipmunkSpace *_space;
	NSMutableArray *_grabs;
	
	cpFloat _smoothing;
	cpFloat _force;
	
	cpLayers _layers;
	cpGroup _group;
}

@property(nonatomic, assign) cpLayers layers;
@property(nonatomic, assign) cpGroup group;

-(id)initForSpace:(ChipmunkSpace *)space withSmoothing:(cpFloat)smoothing withGrabForce:(cpFloat)force;

// Start tracking a new grab point
-(BOOL)beginLocation:(cpVect)pos;

// Update the position of the grab locations.
//-(void)updateLocations:(cpVect *)locations count:(int)count;

// Shortcut for updating a single grab location (like when using a mouse).
-(void)updateLocation:(cpVect)pos;

// End a grab location
-(void)endLocation:(cpVect)pos;

@end
