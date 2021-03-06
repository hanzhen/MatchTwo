//
//  ChallengeMenuScene.m
//  MatchTwo
//
//  Created by  on 11-8-14.
//  Copyright 2011年 StupidTent co. All rights reserved.
//

#import "ChallengeMenuScene.h"
#import "MTSharedManager.h"
#import "GameConfig.h"


@implementation ChallengeMenuItem

- (void)setIsEnabled:(BOOL)enabled{
    if (enabled) {
        completeIcon.visible = NO;
        objCompleteIcon.visible = NO;
    }else{
        completeIcon.visible = NO;
        objCompleteIcon.visible = NO;   
    }
    [super setIsEnabled:enabled];
}

- (void)setCompleted:(BOOL)newBool{
    // Add Complete Icon
    completed = newBool;
    if (completed) {
        objCompleteIcon.visible = NO;
        completeIcon.visible = YES;
    }
}

- (BOOL)completed{
    return completed;
}

- (void)setObjCompleted:(BOOL)newBool{
    objCompleted = newBool;
    // Add obj complete icon
    if (objCompleted) {
        objCompleteIcon.visible = YES;
        completeIcon.visible = NO;
    }

}

- (BOOL)objCompleted{
    return objCompleted;
}


#define kMTChallengeMenuIconOffset 100.0f
#define kMTChallengeMenuImage @"Menu.png"

+ (ChallengeMenuItem *)itemWithIndex:(int)index block:(void(^)(id sender))block{
    return [[[self alloc]initWithIndex:index block:block]autorelease];
}

- (id)initWithIndex:(int)theIndex block:(void(^)(id sender))block{
    int realIndex = theIndex % 100 - 1;
    NSAssert(realIndex<=16, @"Index must < 16");
    CCSprite * levelIconNormal = [CCSprite spriteWithFile:kMTChallengeMenuImage
                                              index:realIndex
                                        textureSize:kMTMenuItemSpriteSize
                                         canvasSize:kMTMenuItemCanvasSize];
    CCSprite * levelIconSelected = [CCSprite spriteWithFile:kMTChallengeMenuImage
                                                     index:realIndex + 32
                                               textureSize:kMTMenuItemSpriteSize
                                                canvasSize:kMTMenuItemCanvasSize];    
    CCSprite * levelIconDisabled = [CCSprite spriteWithFile:kMTChallengeMenuImage
                                                      index:realIndex + 16
                                                textureSize:kMTMenuItemSpriteSize
                                                 canvasSize:kMTMenuItemCanvasSize];
    self = [super initFromNormalSprite:levelIconNormal
                        selectedSprite:levelIconSelected
                        disabledSprite:levelIconDisabled
                                 block:block];
    if (self) {
        index = realIndex;
        
        completeIcon = [CCSprite spriteWithFile:kMTChallengeMenuImage 
                                          index:57 
                                    textureSize:kMTMenuItemSpriteSize
                                     canvasSize:kMTMenuItemCanvasSize];
        completeIcon.position = ccp(kMTChallengeMenuIconOffset,0);
        completeIcon.anchorPoint = ccp(0,0);
        [self addChild:completeIcon];
        
        objCompleteIcon = [CCSprite spriteWithFile:kMTChallengeMenuImage 
                                          index:56 
                                    textureSize:kMTMenuItemSpriteSize
                                     canvasSize:kMTMenuItemCanvasSize];
        objCompleteIcon.anchorPoint = ccp(0,0);        
        objCompleteIcon.position = ccp(kMTChallengeMenuIconOffset,0);        
        [self addChild:objCompleteIcon]; 
    }
    return self;
}

// Sprite: Label
//    Sprite
//

- (CGSize) contentSize{
    return CGSizeMake(kMTMenuItemSpriteSize * 1.5,
                      kMTMenuItemSpriteSize);
}

@end

@interface ChallengeMenuScene()

- (void)prepare;
- (CCLayer *)page:(int)pageID;

@end

@implementation ChallengeMenuScene

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ChallengeMenuScene *layer = [ChallengeMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


- (id)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}


// From 101 to 112, 3 x 4 items
// 

#define kMTPageCount 6

- (void)prepare{
    
    // Add Background
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];        
    CCSprite * image = [CCSprite spriteWithFile:@"Background_Right.png"];
    image.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:image z:-2];

    // Add back to main menu item

    CCMenu * menu = [CCMenu menuWithItems:nil];
    CCMenuItemFont * pauseButton = [CCMenuItemFont itemFromString:@"返回" 
                                                            block:^(id sender){
                                                                [[MTSharedManager instance] replaceSceneWithID:0];
                                                            }];
    pauseButton.position = ccp(700 - winSize.width/2,
                               50 - winSize.height/2);
    pauseButton.color = kMTColorActive;
    [menu addChild:pauseButton];
    [self addChild:menu];
    
    // Add the menu pages 
    
    NSMutableArray * pages = [NSMutableArray arrayWithCapacity:kMTPageCount];
    
    for (int i = 0; i < kMTPageCount; i++) {
        [pages addObject:[self page:i]];
    }
    
    scrollLayer = [CCScrollLayer nodeWithLayers:pages
                                    widthOffset:0];
	scrollLayer.pagesIndicatorPosition = ccp(winSize.width * 0.5f, 
                                             30.0f);
    
    [self addChild:scrollLayer];
    
}

- (CCLayer *)page:(int)pageID{
    CCLayer *page = [CCLayer node];
    CCMenu * menu = [CCMenu menuWithItems:nil];
    [CCMenuItemFont setFontSize:kMTFontSizeNormal];
    
    int startID = (pageID+1) * 100 + 1;
    int endID = (pageID+1) * 100 +12;
    for (int i = startID; i <= endID; i++) {
        ChallengeMenuItem * item = [ChallengeMenuItem itemWithIndex:i 
                                                              block:^(id sender){
            [[MTSharedManager instance] replaceSceneWithID:i];
        }];
        item.anchorPoint = ccp(0.5,0.5);           
        [menu addChild:item];
        
        item.isEnabled = ![[MTSharedManager instance] locked:i];
        item.completed = [[MTSharedManager instance] completed:i];
        item.objCompleted = [[MTSharedManager instance] objCompleted:i];        
    }
    
    [menu alignItemsInColumns:[NSNumber numberWithInt:3],
     [NSNumber numberWithInt:3],
     [NSNumber numberWithInt:3],
     [NSNumber numberWithInt:3],
     nil];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];     
    
    menu.position = ccp(winSize.width/2, winSize.height/2 - 50);
    
    // Add Header
    CCSprite * header  = [CCSprite spriteWithFile:@"MenuHeader.png"];
    header.position = ccp(100, 700);
    header.anchorPoint = ccp(0,0);
    [page addChild:header];
    
    // Add Lebel
    NSString * worldLabel = [NSString stringWithFormat:@"%d", pageID+1];
    CCLabelTTF * label = [CCLabelTTF labelWithString:worldLabel
                                            fontName:kMTFontCaption
                                            fontSize:kMTFontSizeNormal];
    label.color = kMTColorActive;
    label.position = ccpAdd(header.position, ccp(198,256-38));

    [page addChild:label];
    
    [page addChild:menu];
    return page;
}


@end
