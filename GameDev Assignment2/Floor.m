//
//  Floor.m
//  GameDev Assignment2
//
//  Created by robert moffat on 3/6/17.
//  Copyright © 2017 robert moffat. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Floor.h"

GLfloat floor2VertexData[] =
{
    0.5f, 0.0f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.0f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.0f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.0f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.0f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.0f, 0.5f,         0.0f, 1.0f, 0.0f
};

@implementation Floor

-(id)init{
    self = [super init];
    if(self){
        
    }
    return self;
}

-(GLfloat *)getFloorVertices{
    return floor2VertexData;
}

@end
