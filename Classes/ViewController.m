#import "ViewController.h"

#import "SimpleSound.h"
#import "UIViewQuadBody.h"
#import "BWButton.h"
#import "BWShooter.h"
#import "BWScorePost.h"
#import "BWBumper.h"
#import "Random.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageViewBody2.h"
#import "BWBodyLayer.h"

static NSString *borderType = @"borderType";

#pragma mark - Collisions

void postStepRemove(cpSpace *space, cpShape *shape, void *unused)
{
    BWScorePost *scorePost = shape->data;
    [scorePost retain];
    [scorePost removeFromSuperview];
    
    if( cpBodyIsStatic(shape->body) == NO )
        cpSpaceRemoveBody(space, shape->body);
    
    cpSpaceRemoveShape(space, shape);
    
    [scorePost release];
}

void postStepRemove2(cpSpace *space, cpShape *shape, void *unused)
{
    UIView *scorePost = shape->data;
    [scorePost retain];
    [scorePost removeFromSuperview];
    
    if( cpBodyIsStatic(shape->body) == NO )
        cpSpaceRemoveBody(space, shape->body);
    
    cpSpaceRemoveShape(space, shape);
    
    [scorePost release];
}

void postSolveCollisionWithButtonAndScorePost(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWButton *button = a->data;
    ViewController *viewController = data;
    
    if( button.color == ButtonColorGreen )
        viewController.topScore.text = [NSString stringWithFormat:@"%d", [viewController.topScore.text intValue] + 1];
    else
        viewController.bottomScore.text = [NSString stringWithFormat:@"%d", [viewController.bottomScore.text intValue] + 1];
    
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemove, b, NULL);
}

void postSolveCollisionWithButtonAndBumper(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWBumper *bumper = b->data;
    
    [UIView animateWithDuration:.1 animations:^{
       // I want to animate a custom property on the view.  Is this possible? 
    }];
    
    cpBodySetPos(bumper.body, CGPointMake(cpBodyGetPos(bumper.body).x+20, cpBodyGetPos(bumper.body).y));
}

void postSolveCollision(cpArbiter *arbiter, cpSpace *space, void *data) {
    
	if( cpArbiterIsFirstContact(arbiter) == NO ) 
        return;
    
	cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arbiter));
	
	float volume = MIN(impulse/500.0f, 1.0f);
	if(volume > 0.05f){
		[SimpleSound playSoundWithVolume:volume];
	}
}


#pragma mark -

@implementation ViewController
@synthesize topScore;
@synthesize bottomScore;

- (void)viewDidLoad {
	[super viewDidLoad];

	space = cpSpaceNew();
    cpSpaceSetIterations(space, 10);
    
    cpBody *floorBody = cpSpaceGetStaticBody(space);

    // left
	cpShape *floorShape = cpSegmentShapeNew(floorBody, cpv(0, 0), cpv(0, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // right
    floorShape = cpSegmentShapeNew(floorBody, cpv(self.view.bounds.size.width, 0), cpv(self.view.bounds.size.width, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // top
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, 0), cpv(self.view.bounds.size.width, 0), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // bottom
    floorShape = cpSegmentShapeNew(floorBody, cpv(0, self.view.bounds.size.height), cpv(self.view.bounds.size.width, self.view.bounds.size.height), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);
    

    
    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollision, NULL, NULL);
    cpSpaceAddCollisionHandler(space, 1, 2, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndScorePost, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 3, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndBumper, NULL, self);    

    BWShooter *shooter = [[[BWShooter alloc] initWithFrame:CGRectMake(0, 0, 270, 270) color:ButtonColorGreen] autorelease];
    [shooter makeStaticBodyWithPosition:CGPointMake(self.view.bounds.size.width/2.0, 0)];
    shooter.gameDelegate = self;
    cpSpaceAddShape(space, shooter.shape);
    [self.view addSubview:shooter];
    
    BWShooter *bottomShooter = [[[BWShooter alloc] initWithFrame:CGRectMake(0, 0, 270, 270) color:ButtonColorOrange] autorelease];
    [bottomShooter makeStaticBodyWithPosition:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height)];
    bottomShooter.gameDelegate = self;
    cpSpaceAddShape(space, bottomShooter.shape);
    [self.view addSubview:bottomShooter];
    
    UISwipeGestureRecognizer *swipeCleanGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeClean:)] autorelease];
    [self.view addGestureRecognizer:swipeCleanGesture];
    
    [self createScorePosts];
    
    topScore = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 100, 50)];
    topScore.text = @"0";
    topScore.font = [UIFont boldSystemFontOfSize:24];    
    [self.view addSubview:topScore];
    
    bottomScore = [[UILabel alloc] initWithFrame:CGRectMake(100, self.view.bounds.size.height-75, 100, 50)];
    bottomScore.text = @"0";
    bottomScore.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:bottomScore];
    
//    UIImageViewBody2 *buttonTest = [[[UIImageViewBody2 alloc] initWithFrame:CGRectMake(50, 50, 50, 50)] autorelease];
//    buttonTest.image = [UIImage imageNamed:@"ButtonGreen.png"];
//    [self.view addSubview:buttonTest];
//    NSLog(@"setting center property");
//    buttonTest.center = CGPointMake(100, 100);
    
    buttonTest2 = [[BWBodyLayer alloc] init];
    buttonTest2.frame = CGRectMake(0, 0, 50, 50);
    buttonTest2.contents = (id)[UIImage imageNamed:@"ButtonGreen.png"].CGImage;
    
    cpSpaceAddBody(space, buttonTest2.body);
    cpSpaceAddShape(space, buttonTest2.shape);
    [self.view.layer addSublayer:buttonTest2];
    cpBodySetPos(buttonTest2.body, cpv(400, 400));
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(moveButton:) userInfo:nil repeats:NO];
}

- (void)moveButton:(NSTimer *)timer {
    cpBodyApplyImpulse(buttonTest2.body, cpv(400, 400), cpvzero);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
	// Set up the display link to control the timing of the animation.
	displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(update)] retain];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];	
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
	[displayLink invalidate];
	displayLink = nil;
}

- (void)update {
	cpFloat dt = displayLink.duration * displayLink.frameInterval;
	cpSpaceStep(space, dt);
	
    for( UIView *aView in self.view.subviews ) {
        if( [[aView class] isSubclassOfClass:[UIViewBody class]] == YES ||
           [[aView class] isSubclassOfClass:[UIImageViewBody class]] == YES )
            [(UIViewBody *)aView updatePosition];
    }
    
    for( CALayer *aLayer in self.view.layer.sublayers ) 
        if( [aLayer isKindOfClass:[BWBodyLayer class]] == YES )
            [(BWBodyLayer *)aLayer updatePosition];
}

#pragma mark GameDelegate
- (void)shootWithShooter:(BWShooter *)shooter {
    BWButton *greenButton = [[[BWButton alloc] initWithFrame:CGRectMake(shooter.body->p.x, shooter.body->p.y, 50, 50) color:shooter.buttonColor] autorelease];
    cpSpaceAddBody(space, greenButton.body);
    cpSpaceAddShape(space, greenButton.shape);
    [self.view addSubview:greenButton];

    cpVect v = cpvmult(cpvforangle(shooter.body->a), 1000.0f);
	cpBodyApplyImpulse(greenButton.body, v, cpvzero);

}
#pragma mark -


- (void)swipeClean:(UISwipeGestureRecognizer *)swipeGesture {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Remove all buttons?" message:@"" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Remove", nil] autorelease];
    [alert show];

}

#pragma mark UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( buttonIndex == 0 )
        return;
    
    [self removeButtons];
    [self removeScorePosts];
    [self createScorePosts];
    
    topScore.text = @"0";
    bottomScore.text = @"0";

}
#pragma mark -

- (void)removeButtons {
    for( UIView *potentialButton in self.view.subviews ) {
        if( [potentialButton isKindOfClass:[BWButton class]] ) {
            BWButton *buttonToRemove = (BWButton *)potentialButton;
            cpSpaceRemoveShape(space, buttonToRemove.shape);
            cpSpaceRemoveBody(space, buttonToRemove.body);
            [potentialButton removeFromSuperview];
        }
    }    
}

- (void)removeScorePosts {
    for( UIView *potentialButton in self.view.subviews ) {
        if( [potentialButton isKindOfClass:[BWScorePost class]] ) {
            BWScorePost *buttonToRemove = (BWScorePost *)potentialButton;
            cpSpaceRemoveShape(space, buttonToRemove.shape);
            [potentialButton removeFromSuperview];
        }
    }        
}

- (void)createScorePosts {
    return;
    [Random seed];
    for( int scorePostCount = 0; scorePostCount < 20; scorePostCount++ ) {
        NSUInteger randomX = [Random randomWithMin:50 max:(NSUInteger)self.view.bounds.size.width-50];
        NSUInteger randomY = [Random randomWithMin:250 max:(NSUInteger)self.view.bounds.size.height-250];
        
        BWScorePost *scorePost = [[[BWScorePost alloc] initWithFrame:CGRectMake(560, 600, 60, 60)] autorelease];
        [scorePost makeStaticBodyWithPosition:CGPointMake(randomX, randomY)];
        cpSpaceAddShape(space, scorePost.shape);
        [self.view addSubview:scorePost];
        
    }
    
    [bumper release];
    bumper = [[BWBumper alloc] init];
    //[bumper makeStaticBodyWithPosition:CGPointMake(250, 500)];
    cpBodySetPos(bumper.body, CGPointMake(250, 500));
    cpSpaceAddBody(space, bumper.body);
    cpSpaceAddShape(space, bumper.shape);
    [self.view addSubview:bumper];
}

- (void)dealloc {
	
	[super dealloc];
}

@end
