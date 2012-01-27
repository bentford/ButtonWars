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
#import "BWChipmunkLayer.h"
#import "UIViewBody.h"
#import "BWRotatingBumper.h"
#import "BWSlidingBox.h"
#import "ChipmunkLayerView.h"
#import "BaseWall.h"
#import "BWLevelWall.h"
#import "BWProgressBar.h"
#import "BWProgressBarAnimator.h"
#import "JelloPopupAnimation.h"
#import "BWSlidingBoxWithBounce.h"
#import "NSString+Ext.h"

static NSString *borderType = @"borderType";

#pragma mark - Collisions

void postStepRemove(cpSpace *space, cpShape *shape, void *unused)
{
    BWScorePost *scorePost = shape->data;
    [scorePost retain];
    [scorePost removeFromSuperview];
    
    cpSpaceRemoveShape(space, shape);
    
    [scorePost release];
}

void postStepRemoveButton(cpSpace *space, cpShape *shape, void *unused) {
    BWButton *button = shape->data;
    [button retain];
    [button removeFromSuperview];
    
    cpSpaceRemoveBody(space, button.chipmunkLayer.body);
    cpSpaceRemoveShape(space, shape);
    
    [button release];
}

void postStepRemoveButtonBodyFromSpace(cpSpace *space, cpShape *shape, void *unused) {
    BWButton *button = shape->data;
    cpSpaceRemoveBody(space, button.chipmunkLayer.body);
}

int beginCollisionWithButtonAndScorePost(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWButton *button = a->data;
    BWScorePost *scorePost = b->data;
    ViewController *viewController = data;
    
    if( viewController.gameSuspended == YES )
        return 0;
    
    if( button.color == ButtonColorGreen && scorePost.buttonColor != ButtonColorGreen ) {
        viewController.greenScore += 1;

        if( scorePost.buttonColor == ButtonColorOrange ) 
            viewController.orangeScore = fmaxf(viewController.orangeScore - 1, 0);
    } 
    if( button.color == ButtonColorOrange && scorePost.buttonColor != ButtonColorOrange ) {
        viewController.orangeScore += 1;
        
        if( scorePost.buttonColor == ButtonColorGreen ) 
            viewController.greenScore = fmaxf(viewController.greenScore - 1, 0);
    }
    
    scorePost.buttonColor = button.color;
    [viewController checkForWinner];
    
    return 0;
}

int beginCollisionWithButtonAndShooter(cpArbiter *arbiter, cpSpace *space, void *data) {

    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWButton *button = a->data;
    BWShooter *shooter = b->data;
    
    if( button.canDie == YES && button.color == shooter.buttonColor ) 
        return 0;
    else
        return 1;
}

void postSolveCollisionWithButtonAndInnerShooter(cpArbiter *arbiter, cpSpace *space, void *data) {
    
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWButton *button = a->data;
    BWShooter *shooter = b->data;
    
    if( button.canDie == YES && button.color == shooter.buttonColor ) {
        shooter.activeButtonCount--;
        cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemoveButton, a, NULL);
    }
}

void postSolveCollisionWithButtonAndSlidingBoxWithBounce(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWSlidingBoxWithBounce *box = b->data;
    BWButton *button = a->data;

    [box bumpButton:button withSpace:space];
}


void postSolveCollisionWithButtonAndBumper(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWBumper *bumper = b->data;
    BWButton *button = a->data;
    ViewController *viewController = data;
     

    cpVect collisionVector = cpvnormalize(cpvsub(cpBodyGetPos(bumper.chipmunkLayer.body), cpBodyGetPos(button.chipmunkLayer.body)));
    cpVect invertedCollisionVector = cpvrotate(collisionVector, cpvforangle(M_PI));
    cpVect impulseVector = cpvmult(invertedCollisionVector, 500);
    cpVect bounceVector = cpvmult(invertedCollisionVector, 10);
    
    // bounce button away
    cpBodyApplyImpulse(button.chipmunkLayer.body, impulseVector, cpvzero);
    
    
    
    if( bumper.isBumping == YES )
        return;

    // bounce the bumper if it's not bumping
    bumper.isBumping = YES;
    cpVect jumpPosition = cpvadd(cpBodyGetPos(bumper.chipmunkLayer.body), bounceVector);
    cpVect resetPosition = cpBodyGetPos(bumper.chipmunkLayer.body);
    cpBodySetPos(bumper.chipmunkLayer.body, jumpPosition);
    NSArray *parameters = [NSArray arrayWithObjects:bumper, [NSValue valueWithCGPoint:resetPosition], nil];
    [viewController performSelector:@selector(resetBumper:) withObject:parameters afterDelay:0.1];
}

void beginSolveCollisionWithButtonAndRotatingBumper(cpArbiter *arbiter, cpSpace *space, void *data) {
    CP_ARBITER_GET_SHAPES(arbiter, a, b);
    BWRotatingBumper *bumper = b->data;
    BWButton *button = a->data;

    [bumper trapButton:button withSpace:space];
}

void postSolveCollision(cpArbiter *arbiter, cpSpace *space, void *data) {
    
	if( cpArbiterIsFirstContact(arbiter) == NO ) 
        return;
    
	cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arbiter));
	
	float volume = MIN(impulse/500.0f, 1.0f);
	if(volume > 0.05f){
		//[SimpleSound playSoundWithVolume:volume];
	}
}


#pragma mark -

@interface ViewController(PrivateMethods)
- (void)populateMapWithFileNamed:(NSString *)textMapName;
- (void)populateWalls;
- (void)populateTestObjects;

- (void)resetMap:(UITapGestureRecognizer *)tapGesture;
- (void)hideWinnerPrompt;
@end

@implementation ViewController
@synthesize greenScore;
@synthesize orangeScore;
@synthesize gameSuspended;

- (void)viewDidLoad {
	[super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    
    currentLevelName = nil;
    topShooter = nil;
    bottomShooter = nil;
    
    CALayer *background = [CALayer layer];
    background.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    background.contents = (id)[UIImage imageNamed:@"Background_1.png"].CGImage;
    [self.view.layer insertSublayer:background atIndex:0];
    
	space = cpSpaceNew();
    cpSpaceSetIterations(space, 10);
    
    cpBody *floorBody = cpSpaceGetStaticBody(space);

    // left
	cpShape *floorShape = cpSegmentShapeNew(floorBody, cpv(0, 120), cpv(0, self.view.bounds.size.height-120), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    // right
    floorShape = cpSegmentShapeNew(floorBody, cpv(self.view.bounds.size.width, 120), cpv(self.view.bounds.size.width, self.view.bounds.size.height-120), 0);
    cpShapeSetElasticity(floorShape, 1.0f);
	cpShapeSetFriction(floorShape, 1.0f);
	cpShapeSetCollisionType(floorShape, kFloorCollisionType);
    cpSpaceAddShape(space, floorShape);

    cpSpaceAddCollisionHandler(space, 0, 1, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollision, NULL, NULL);
    cpSpaceAddCollisionHandler(space, 1, 2, (cpCollisionBeginFunc)beginCollisionWithButtonAndScorePost, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 3, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndBumper, NULL, self);    
    cpSpaceAddCollisionHandler(space, 1, 4, (cpCollisionBeginFunc)beginCollisionWithButtonAndShooter, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 5, (cpCollisionBeginFunc)beginSolveCollisionWithButtonAndRotatingBumper, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 6, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndInnerShooter, NULL, self);
    cpSpaceAddCollisionHandler(space, 1, 7, NULL, NULL, (cpCollisionPostSolveFunc)postSolveCollisionWithButtonAndSlidingBoxWithBounce, NULL, self);
    
    UISwipeGestureRecognizer *swipeCleanGesture = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(chooseNewLevel:)] autorelease];
    [self.view addGestureRecognizer:swipeCleanGesture];

    topMark = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:topMark];

    bottomMark = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:bottomMark belowSubview:topMark];
    
    progressAnimator = [[BWProgressBarAnimator alloc] init];
    progressAnimator.delegate = self;
    
    [self didChooseLevel:@"Level_1"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	// Set up the display link to control the timing of the animation.
	displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(step)] retain];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    for( UIView *potentialView in self.view.subviews )
        if( [potentialView conformsToProtocol:@protocol(AnimatedChipmunkLayer)] )
            [(id<AnimatedChipmunkLayer>)potentialView startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
	[displayLink invalidate];
	displayLink = nil;
    
    for( UIView *potentialView in self.view.subviews )
        if( [potentialView conformsToProtocol:@protocol(AnimatedChipmunkLayer)] )
            [(id<AnimatedChipmunkLayer>)potentialView stopAnimation];
}

- (void)step {
	cpFloat dt = displayLink.duration * displayLink.frameInterval;
	cpSpaceStep(space, dt);
    
    for( CALayer *aLayer in self.view.layer.sublayers ) 
        if( [aLayer isKindOfClass:[BWChipmunkLayer class]] == YES )
            [(BWChipmunkLayer *)aLayer step:dt];
    

    for( UIView *aView in self.view.subviews ) 
        if( [aView isKindOfClass:[BWButton class]] == YES && ((BWButton *)aView).ignoreGuideForce == NO ) {
            if( ((BWButton *)aView).color == ButtonColorGreen )
                [(BWButton *)aView guideTowardPlaneOfPoint:CGPointMake(self.view.bounds.size.width/2.0, 0)];
            else
                [(BWButton *)aView guideTowardPlaneOfPoint:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height)];
        }

}

#pragma mark BWProgressAnimatorDelegate
- (void)valueMaxedOut:(ProgressDirection)maxedDirection {
    NSString *imageName = nil;
    if( maxedDirection == ProgressDirectionLeft ) {
        imageName = @"OrangeWins.png";
        gameSuspended = YES;
    } else if( maxedDirection == ProgressDirectionRight ) {
        imageName = @"GreenWins.png";
        gameSuspended = YES;
    } else
        return;
            
    playerWonPrompt = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    playerWonPrompt.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f);
    playerWonPrompt.userInteractionEnabled = YES;
    [self.view addSubview:playerWonPrompt];
    
    [JelloPopupAnimation animateView:playerWonPrompt];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetMap:)] autorelease];
    [playerWonPrompt addGestureRecognizer:tap];
}
#pragma mark -

#pragma mark GameDelegate
- (void)shootWithShooter:(BWShooter *)shooter {
    
    if( shooter.activeButtonCount >= 1 )
        return;
    
    shooter.activeButtonCount++;
    BWButton *greenButton = [[[BWButton alloc] initWithColor:shooter.buttonColor] autorelease];
    [greenButton setupWithSpace:space position:shooter.center];
    [self.view insertSubview:greenButton belowSubview:topMark];

    cpVect v = cpvmult(cpvforangle(cpBodyGetAngle(shooter.chipmunkLayer.body)), 1000.0f);
	cpBodyApplyImpulse(greenButton.chipmunkLayer.body, v, cpvzero);
}
#pragma mark -

#pragma mark LevelPickerDelegate
- (void)didChooseLevel:(NSString *)levelName {


    [self reloadMapWithLevelNamed:levelName];

}
#pragma mark -

- (void)chooseNewLevel:(UISwipeGestureRecognizer *)swipeGesture {

    if( levelPickerViewController == nil ) {
        levelPickerViewController = [[LevelPickerViewController alloc] init];
        levelPickerViewController.delegate = self;
    }
    
    [self presentViewController:levelPickerViewController animated:YES completion:nil];
}

- (void)removeButtons {
    for( UIView *potentialButton in self.view.subviews ) {
        if( [potentialButton isKindOfClass:[BWButton class]] ) {
            BWButton *buttonToRemove = (BWButton *)potentialButton;
            cpSpaceRemoveShape(space, buttonToRemove.chipmunkLayer.shape);
            cpSpaceRemoveBody(space, buttonToRemove.chipmunkLayer.body);
            [potentialButton removeFromSuperview];
        }
    }  
    topShooter.activeButtonCount = 0;
    bottomShooter.activeButtonCount = 0;
}

- (void)removeLevelItems {
    
    for( UIView *potentialLevelItem in self.view.subviews ) {
        if( [potentialLevelItem conformsToProtocol:@protocol(ChipmunkLayerView)] ) {

            UIView<ChipmunkLayerView> *itemToRemove = (UIView<ChipmunkLayerView> *)potentialLevelItem;
            [itemToRemove removeFromSpace:space];
            [itemToRemove removeFromSuperview];
        }
        
        if( [potentialLevelItem isKindOfClass:[BWProgressBar class]] == YES ) {
            [progressAnimator removeBar:(BWProgressBar *)potentialLevelItem];
            [potentialLevelItem removeFromSuperview];
        }
    }
}

- (void)reloadMapWithLevelNamed:(NSString *)levelName {
    gameSuspended = NO;
    
    if( currentLevelName != levelName ) {
        [currentLevelName release];
        currentLevelName = [levelName retain];
    }
    
    [self hideWinnerPrompt];
    [progressAnimator reset];
    
    greenScore = 0;
    orangeScore = 0;
    
    [self removeButtons];
    [self removeLevelItems];
    
    [self populateMapWithFileNamed:levelName];
}

- (void)resetBumper:(NSArray *)parameters {
    BWBumper *theBumper = [parameters objectAtIndex:0];
    cpVect resetPosition = [(NSValue *)[parameters objectAtIndex:1] CGPointValue];
    cpBodySetPos(theBumper.chipmunkLayer.body, resetPosition);
    theBumper.isBumping = NO;
}

- (void)checkForWinner {
    ProgressDirection newDirection = ProgressDirectionNone;
    CGFloat ratio = 0;
    
    if( orangeScore > greenScore ) {
        newDirection = ProgressDirectionLeft;
        ratio = (CGFloat)orangeScore / (CGFloat)totalScorePosts;
    } else if( orangeScore < greenScore ) {
        newDirection = ProgressDirectionRight;
        ratio = (CGFloat)greenScore / (CGFloat)totalScorePosts;
    }
    CGFloat rate = 1.1 - ratio;
    
    [progressAnimator setRate:rate direction:newDirection];
}

- (void)fireTrappedButton:(NSArray *)parameters {
    BWButton *button = [parameters objectAtIndex:0];
    BWRotatingBumper *bumper = [parameters objectAtIndex:1];

    cpBodySetAngVel(bumper.chipmunkLayer.body, 0);
    cpBodySetVel(button.chipmunkLayer.body, cpvzero);
    cpSpaceAddBody(space, button.chipmunkLayer.body);
    cpBodyApplyImpulse(button.chipmunkLayer.body, cpv(-1000,0), cpvzero);
}

- (void)dealloc {
	
	[super dealloc];
}

@end

@implementation ViewController(PrivateMethods)
- (void)populateMapWithFileNamed:(NSString *)textMapName {
    
    totalScorePosts = 0;
    
    [self populateWalls];
    [self populateTestObjects];
    
    NSUInteger mapRowCount = 33;
    NSUInteger mapColumnCount = 65;
    
    CGFloat perRowAmount = 1024.0/((CGFloat)mapRowCount-1);
    CGFloat perColumnAmount = 768.0/((CGFloat)mapColumnCount-1);
    
    NSUInteger middleRow = ((mapRowCount-1)/2)+1; // 17
    NSUInteger middleColumn = ((mapColumnCount-1)/2)+1; // 33
    
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *mapPath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", textMapName]];
    NSError *fileLoadError = nil;
    NSString *mapText = [NSString stringWithContentsOfFile:mapPath encoding:NSUTF8StringEncoding error:&fileLoadError];
    if( fileLoadError != nil ) {
        NSLog(@"Error reading file: %@ with reason: %@", mapPath, [fileLoadError localizedDescription]);
        return;
    }
    
    NSArray *mapRows = [mapText componentsSeparatedByString:@"\n"];
    
    if( [mapRows count] < mapRowCount - 1)
        NSLog(@"WARNDING: map is missing %d rows", mapRowCount - [mapRows count]);
    
    NSMutableDictionary *wallPointDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSUInteger currentRow = 0;
    NSUInteger currentColumn = 0;
    for( NSString *row in mapRows ) {
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:row.length];
        for( NSUInteger i = 0; i < row.length; i++) {
            NSString *character  = [NSString stringWithFormat:@"%c", [row characterAtIndex:i]];
            [columns addObject:character];
        }
        
        NSString *previousCharacter = @" ";
        for( NSString *character in columns ) {
            
            // create a phrase that is at least 5 characters long
            NSString *phrase = [row substringFromIndex:currentColumn];
            while( [phrase length] < 5 )
                phrase = [NSString stringWithFormat:@"%@ ", phrase];
            
            CGFloat xPoint = 0;
            CGFloat yPoint = 0;
            
            // get xPoint 
            if( currentRow < middleRow )
                yPoint = currentRow*perRowAmount;
            else if( currentRow == middleRow )
                yPoint = 1024.0/2.0;
            else if( currentRow > middleRow )
                yPoint = ((currentRow-(middleRow-1))*perRowAmount)+(1024.0/2.0);
            
            // get yPoint
            if( currentColumn < middleColumn )
                xPoint = currentColumn * perColumnAmount;
            else if( currentColumn == middleColumn ) 
                xPoint = 768.0/2.0;
            else if( currentColumn > middleColumn )
                xPoint = ((currentColumn-(middleColumn-1))*perColumnAmount)+(768.0/2.0);
            
            CGPoint currentPosition = CGPointMake(xPoint, yPoint);
            
            if( [character isEqualToString:@"p"] == YES ) {
                BWScorePost *scorePost = [[[BWScorePost alloc] init] autorelease];
                [scorePost setupWithSpace:space position:currentPosition];
                [self.view addSubview:scorePost];
                totalScorePosts++;
            }
            
            if( [character isEqualToString:@"b"] == YES && [previousCharacter isEqualToString:@"r"] == NO ) {
                BWBumper *bumper = [[[BWBumper alloc] init] autorelease];
                [bumper setupWithSpace:space position:currentPosition];
                [self.view addSubview:bumper];
            }
            
            if( [phrase extBeginsWithString:@"rb"] ) {
                NSUInteger angle = [[phrase substringFromIndex:2] intValue];
                
                BWRotatingBumper *bumper = [[[BWRotatingBumper alloc] init] autorelease];
                [bumper setupWithSpace:space position:currentPosition];
                
                [self.view insertSubview:bumper aboveSubview:topMark];
                [bumper addRelatedViewsToView:self.view withTopMark:topMark bottomMark:bottomMark angle:RADIANS(angle)];

            }

            if( [phrase extBeginsWithString:@"sx"] ) {
                NSString *directionString = [phrase substringWithRange:NSMakeRange(2, 1)];
                
                BWSlidingBoxDirection direction;
                if( [directionString isEqualToString:@"h"] == YES || [directionString isEqualToString:@" "] == YES )
                    direction = BWSlidingBoxDirectionHorizontal;
                else if( [directionString isEqualToString:@"v"] == YES )
                    direction = BWSlidingBoxDirectionVertical;
                else if( [directionString isEqualToString:@"s"] == YES )
                    direction = BWSlidingBoxDirectionStopped;
                
                CGFloat slideAmount = 0.0f;
                NSString *amountString = [phrase substringWithRange:NSMakeRange(3, 3)];
                if( [[amountString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 )
                    slideAmount = 100.0f;
                else
                    slideAmount = [amountString floatValue];
                
                BWSlidingBox *slidingBox = [[[BWSlidingBox alloc] init] autorelease];
                slidingBox.slideDirection = direction;
                slidingBox.slideAmount = slideAmount;
                [slidingBox setupWithSpace:space position:currentPosition];
                [self.view addSubview:slidingBox];
                [slidingBox startAnimation];
                
            }
            
            if( [character isEqualToString:@"s"] == YES && currentColumn+1 < [columns count] && [[columns objectAtIndex:currentColumn+1] isEqualToString:@"y"] == YES ) {            
                BWSlidingBoxWithBounce *slidingBox = [[[BWSlidingBoxWithBounce alloc] init] autorelease];
                [slidingBox setupWithSpace:space position:currentPosition];
                [self.view addSubview:slidingBox];
                [slidingBox startAnimation];
                
            }
            
            // walls
            if( [character isEqualToString:@"w"] == YES ) {
                NSString *wallNumber = [columns objectAtIndex:currentColumn+1];
                NSString *wallIdentifier = [NSString stringWithFormat:@"%@%@", character, wallNumber];
                
                if( [wallPointDictionary.allKeys containsObject:wallIdentifier] == NO )
                    [wallPointDictionary setObject:[NSMutableArray array] forKey:wallIdentifier];
                
                [[wallPointDictionary objectForKey:wallIdentifier] addObject:[NSValue valueWithCGPoint:currentPosition]];
            }

            
            currentColumn++;
            previousCharacter = character;
            if( currentColumn == mapColumnCount+1 )
                break;
        }
        currentColumn = 0;
        currentRow++;
        
        if( currentRow == mapRowCount+1 )
            break;
    }
    
    for( NSString *wallNumber in wallPointDictionary.allKeys ) {
        NSArray *wallPoints = [wallPointDictionary objectForKey:wallNumber];
        
        if( [wallPoints count] != 2 ) {
            NSLog(@"skipping wall because it had %d point(s)", [wallPoints count]);
            continue;
        }
        
        CGPoint firstPoint = [[wallPoints objectAtIndex:0] CGPointValue];
        CGPoint secondPoint = [[wallPoints objectAtIndex:1] CGPointValue];
        
        CGFloat length = cpvlength(cpvsub(firstPoint, secondPoint));
        CGFloat angle = cpvtoangle(cpvnormalize(cpvsub(firstPoint, secondPoint))) - M_PI/2.0;
        
        CGPoint midVect = cpvadd(cpvclamp(cpvsub(firstPoint, secondPoint), length/2.0), secondPoint);
        
        BWLevelWall *wall = [[[BWLevelWall alloc] initWithLength:length] autorelease];
        cpBodySetAngle(wall.chipmunkLayer.body, angle);
        [wall setupWithSpace:space position:midVect];
        
        [self.view addSubview:wall];
    }
}

- (void)populateWalls {
    BaseWall *baseWall = [[[BaseWall alloc] initWithDirection:BaseWallDirectionNormal] autorelease];
    [baseWall setupWithSpace:space position:cpv(self.view.bounds.size.width-153, self.view.bounds.size.height-60)];
    [self.view insertSubview:baseWall belowSubview:bottomMark];
    
    baseWall = [[[BaseWall alloc] initWithDirection:BaseWallDirectionFlippedHorizontal] autorelease];
    [baseWall setupWithSpace:space position:cpv(153, self.view.bounds.size.height-60)];
    [self.view insertSubview:baseWall belowSubview:bottomMark];
    
    baseWall = [[[BaseWall alloc] initWithDirection:BaseWallDirectionFlippedVertical] autorelease];
    [baseWall setupWithSpace:space position:cpv(self.view.bounds.size.width-153, 60)];
    [self.view insertSubview:baseWall belowSubview:bottomMark];
    
    baseWall = [[[BaseWall alloc] initWithDirection:BaseWallDirectionFlippedBoth] autorelease];
    [baseWall setupWithSpace:space position:cpv(153, 60)];
    [self.view insertSubview:baseWall belowSubview:bottomMark];
    
    
    BWProgressBar *bar = [[[BWProgressBar alloc] init] autorelease];
    bar.center = CGPointMake(600, self.view.bounds.size.height-45);
    bar.transform = CGAffineTransformMakeRotation(RADIANS(344));
    [self.view addSubview:bar];
    
    [progressAnimator addBar:bar];
    
    bar = [[[BWProgressBar alloc] init] autorelease];
    bar.center = CGPointMake(168, 45);
    bar.transform = CGAffineTransformMakeRotation(RADIANS(345));
    [self.view addSubview:bar];
    
    [progressAnimator addBar:bar];
    
    
    
    [topShooter release];
    topShooter = [[BWShooter alloc] initWithButtonColor:ButtonColorGreen];
    [topShooter setupWithSpace:space position:CGPointMake(self.view.bounds.size.width/2.0, 0)];
    topShooter.gameDelegate = self;
    [self.view addSubview:topShooter];
    
    [bottomShooter release];
    bottomShooter = [[BWShooter alloc] initWithButtonColor:ButtonColorOrange];
    [bottomShooter setupWithSpace:space position:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height)];
    bottomShooter.gameDelegate = self;
    [self.view addSubview:bottomShooter];
}

- (void)resetMap:(UITapGestureRecognizer *)tapGesture {
    

    [self reloadMapWithLevelNamed:currentLevelName];
}

- (void)populateTestObjects {
    

}

- (void)hideWinnerPrompt {
    [UIView animateWithDuration:0.5 animations:^{
        playerWonPrompt.alpha = 0.0; 
    } completion:^(BOOL finished) {
        if( finished == YES ) {
            [playerWonPrompt removeFromSuperview];
            [playerWonPrompt release];
            playerWonPrompt = nil;
        }
    }];
}
@end