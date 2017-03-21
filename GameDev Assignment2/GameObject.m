//
//  GameObject.m
//  GameDev Assignment2
//
//  Created by robert moffat on 3/6/17.
//  Copyright © 2017 robert moffat. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "GameObject.h"

@implementation GameObject

-(GLKMatrix4)getTranslationMatrix{
    return GLKMatrix4MakeTranslation(_x, _y, _z);
}

-(GLKMatrix4)getRotationMatrix{
    GLKMatrix4 xRotMatrix = GLKMatrix4MakeRotation(_rotx, 1, 0, 0);
    GLKMatrix4 yRotMatrix = GLKMatrix4MakeRotation(_roty, 0, 1, 0);
    GLKMatrix4 zrotMatrix = GLKMatrix4MakeRotation(_rotz, 0, 0, 1);
    GLKMatrix4 totalRotMatrix = GLKMatrix4Multiply(xRotMatrix, yRotMatrix);
    totalRotMatrix = GLKMatrix4Multiply(totalRotMatrix, zrotMatrix);
    
    return totalRotMatrix;
}

-(void)setx:(int)x{
    _x = x;
}

-(void)sety:(int)y{
    _y = y;
}

-(void)setz:(int)z{
    _z = z;
}

-(void)setRotx:(int)rotx{
    _rotx = rotx;
}

-(void)setRoty:(int)roty{
    _roty = roty;
}

-(void)setRotz:(int)rotz{
    _rotz = rotz;
}



@end
