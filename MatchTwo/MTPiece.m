//
//  MTPiece.m
//  MatchTwo
//
//  Created by  on 11-8-1.
//  Copyright 2011年 StupidTent co. All rights reserved.
//

#import "MTPiece.h"
#import "CCTouchDispatcher.h"
#import "CCDrawingPrimitives+MT.h"
#import "MTGame.h"
#import "MTAbilityButton.h"

// Tile is a 512 x 512 texture, each grid is 64 * 64

CGRect rectForType(int type){
    int idX = type % 8;
    int idY = type / 8;
    return CGRectMake(idX * 64, idY * 64, 64, 64);
}


@implementation MTPiece

@synthesize row,column,type,enabled,hinted,pairedPiece,shufflePiece,game,ability;

- (void)setSelected:(BOOL)toBeSelected{
    if (!enabled) {
        return;
    }
    if (toBeSelected != selected) {
        selected = toBeSelected;
        if (selected) {
            [self runAction:[CCScaleTo actionWithDuration:kMTPieceScaleTime scale:1.25]];
        }else{
            [self runAction:[CCScaleTo actionWithDuration:kMTPieceScaleTime scale:1.0]];            
        }
    }
}

- (BOOL)selected{
    return selected;
}


- (id)initWithType:(int)theType{
    self = [super initWithFile:@"Tile.png" rect:rectForType(theType)];
    if (self) {
//        self.scale = kMTPieceSize/64;
        self.enabled = YES;
        self.type = theType;
        self.ability = @"";
        self.contentSize = CGSizeMake(kMTPieceSize, kMTPieceSize);        
        self.anchorPoint = ccp(0.5, 0.5);         
    }
    return self;
}


- (void)draw{

    CGPoint points[4] = {
        ccp(kMTPieceMargin, kMTPieceMargin),
        ccp(kMTPieceMargin, kMTPieceSize - kMTPieceMargin),
        ccp(kMTPieceSize-kMTPieceMargin, kMTPieceSize-kMTPieceMargin),
        ccp(kMTPieceSize-kMTPieceMargin, kMTPieceMargin)
    };    
    
    if (hinted || [game isAbilityActive:kMTAbilityHighlight]) {
        glColor4f(1.0, (100 + type*20)/255.0, 0.32, 0.5);
        ccDrawPolyFill(points, 4, YES);
    }else{
        glColor4f(0.9, 0.9, 0.9, 1.0);
        glLineWidth(1.0);
        ccDrawPoly(points, 4, YES);        
    }    
    [super draw];

}

- (NSString *)description{
    return [NSString stringWithFormat:@"Piece at Row: %d, Column: %d",row,column];
}


- (void)disappear{
    if (pairedPiece) {
        pairedPiece.hinted = NO;
    }
    self.enabled = NO;
    [self runAction:[CCScaleTo actionWithDuration:kMTPieceDisappearTime scale:0]];
    // Fly the badge to the upside, then ability will be activated
    [game flyBadge:badge forAbility:ability];
}

- (void)assignAbility:(NSString *)abilityName{
    NSAssert(ability == @"", @"Already Assigned Ability!");
    self.ability = abilityName;
    // Add a badge according to the ability name.
    badge = [MTAbilityButton spriteForButtonName:self.ability];
    badge.scale = kMTAbilityBadgeSize/kMTAbilityButtonSpriteSize;
    badge.anchorPoint = ccp(0.5,0.5);
    badge.position = ccp(kMTPieceSize - kMTAbilityBadgePadding,
                         kMTPieceSize - kMTAbilityBadgePadding);
    [self addChild:badge z:2];
}

- (void)shake{
    if (shaking) {
        return;
    }
    shaking = YES;
    id delay = [CCDelayTime actionWithDuration:kMTPieceDisappearTime/2];
    id rotate1 = [CCRotateBy actionWithDuration:kMTPieceDisappearTime/4 angle:5.0f];
    id rotate2 = [CCRotateBy actionWithDuration:kMTPieceDisappearTime/2 angle:-10.0f];
    id rotate3 = [CCRotateBy actionWithDuration:kMTPieceDisappearTime/4 angle:5.0f];    
    id resetShakingFlag = [CCCallBlock actionWithBlock:^{shaking = NO;}];
    [self runAction:[CCSequence actions:delay,
                     rotate1,
                     rotate2,
                     rotate3,
                     resetShakingFlag,
                     nil]];
}

- (void)shuffle{
    newRow = shufflePiece.row;
    newColomn = shufflePiece.column;
    id delay = [CCDelayTime actionWithDuration:kMTBoardShuffleWarningTime];   
    id move = [CCMoveTo actionWithDuration:kMTBoardShuffleTime
                                  position:[game positionForPiece:shufflePiece]
               ];
    id assignID = [CCCallBlock actionWithBlock:^(void){
        self.row = newRow;
        self.column = newColomn;           
    }];    
    [self runAction:[CCSequence actions:delay,
                    
                     assignID, move,
                     nil]];    
    
}


@end
