#import <Foundation/Foundation.h>

#import "ObjectiveChipmunk.h"

@interface FallingButton : UIView <ChipmunkObject> {
	
	ChipmunkBody *body;
	NSSet *chipmunkObjects;
	
	int touchShapes;
    
    CGPoint previousPoint;
    NSTimeInterval lastTimeStamp;
}

@property (readonly) NSSet *chipmunkObjects;
@property int touchedShapes;

- (void)updatePosition;

@end
