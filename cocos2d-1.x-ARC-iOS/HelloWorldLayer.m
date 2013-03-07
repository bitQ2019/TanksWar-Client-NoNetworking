//
//  HelloWorldLayer.m
//  War
//
//  Created by mq on 13-1-4.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import<math.h>
// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize pomelo;
@synthesize name;
@synthesize channel;
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
// on "init" you need to initialize your instance
-(id) init
{   // always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        tagSprites=[[NSMutableArray alloc] init];
        buildingSprites=[[NSMutableArray alloc] init];
        //  从文件中读取数据
         CCSpriteBatchNode *tags=[CCSpriteBatchNode batchNodeWithFile:@"tags.png" capacity:24];
                   [self addChild:tags z:2 tag:100];
        NSString *filename=@"DataList.plist";
        NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:[self getActuralPath:filename ]];
        NSArray *nodes=[dict objectForKey:@"nodes"];
        for (id node in nodes)
        { 
            int x=[[node objectForKey:@"x"] floatValue   ];
            int y=[[node objectForKey:@"y"] floatValue];
            CCSprite *s=[CCSprite spriteWithBatchNode:tags  rect:CGRectMake(0, 0, 64, 64)];
            [tags addChild:s ];
            [s setPosition:ccp(x,y)];
            
            [tagSprites addObject:s];
        }
   
        
        playerResource=[[Resources alloc] init];
        [playerResource initialazation];
        CGSize size = [[CCDirector sharedDirector] winSize];
		// create and initialize a Label
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
        CCSprite *BackGround=[CCSprite spriteWithFile:@"map.png" rect:CGRectMake(0,0, 1024, 768)];
        BackGround.anchorPoint=ccp(0, 0);
        [self addChild:BackGround z:1   tag:TAG_BACKGROUND] ;
  
        //pomelo
        name = @"chenyl107";
        channel = @"junshi";
        
        
        if ([self initPomelo]) {
            [self connectToPomelo];
        }else{
            NSLog(@"pomelo初始化失败");
        }
        
        
        label=[CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(100, 100) alignment: UIViewAnimationCurveEaseIn fontName:@"Arial" fontSize:16];
        [label setString:[NSString stringWithFormat:@"石油：%i\n粮食：%i\n钢铁：%i\n锡矿：%i",playerResource.Fuel,playerResource.Crop,playerResource.Steel,playerResource.Xi]];
        label.position=ccp(120, 670);
        [self addChild:label z:2 tag:101];
        
        [CCMenuItemFont setFontName:@"Marker Felt"];
        [CCMenuItemFont setFontSize:40  ];
        CCMenuItemFont *militaryArea=[CCMenuItemFont itemFromString:@"资源区" target:self selector:@selector(sceneTransition:) ];
    
        CCMenu *changeScene=[CCMenu menuWithItems:militaryArea, nil];
        [changeScene alignItemsHorizontally];
        [changeScene setPosition:ccp(930, 730)];
        [self addChild:changeScene z:2 tag:102];
         [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        //[self schedule:@selector(addup) interval:1];
        //[self schedule:@selector(labelOfNum) interval:1.5];
        

	}
	return self;
 
}

-(NSString*) getActuralPath:(NSString *) file
{
    NSArray *path=[file componentsSeparatedByString:@"."    ];
    NSString *acturalPath=[[NSBundle mainBundle] pathForResource:[path objectAtIndex:0] ofType:[path objectAtIndex:1]];
    return acturalPath;
}
-(BOOL) initPomelo
{
    //初始化pomelo
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    pomelo = myDelegate.pomelo;
    if (pomelo != nil) {
        return TRUE;
    }else{
        return  FALSE;
    }
}
-(void)connectToPomelo
{
    //连接gate服务器得到分配的connect服务器
    
    [pomelo connectToHost:@"127.0.0.1" onPort:3014 withCallback:^(Pomelo *p){
        NSDictionary *params = [NSDictionary dictionaryWithObject:@"chenyl107" forKey:@"uid"];
        [pomelo requestWithRoute:@"gate.gateHandler.queryEntry" andParams:params andCallback:^(NSDictionary *result){
            
            [pomelo disconnectWithCallback:^(Pomelo *p){
                host = [result objectForKey:@"host"];
                port = [[result objectForKey:@"port"] intValue];
                
                //连接得到的connection服务器
                [pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p){
                    
                    
                    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                            name, @"username",
                                            channel, @"rid",
                                            nil];
                    [p requestWithRoute:@"connector.entryHandler.enter" andParams:params andCallback:^(NSDictionary *result){
                        NSArray *userList = [result objectForKey:@"users"];
                        for (NSString *name1 in userList) {
                            NSLog(@"%@",name1);
                            //只是为了看一下该频道里有多少人，没啥用 可与去掉
                            
                            
                            NSDictionary *params2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"military", @"category",
                                                     nil];
                            [p requestWithRoute:@"connector.entryHandler.getArchitecture" andParams:params2 andCallback:^(NSDictionary* responseData){
                               
                                
                                resources = [responseData objectForKey:@"Resources"];
                                
                                int count = [resources count];
                                
                                for (int i=0; i<count; i++) {
                                    
                                    NSLog(@"chenyl1");
                                    NSDictionary *resource =[resources objectAtIndex:i];
                                    NSNumber *xx = [resource objectForKey:@"pointx"];
                                    NSNumber *yy = [resource objectForKey:@"pointy"];
                                    NSString *pngg = [resource objectForKey:@"png"];
                                    CGPoint thep = CGPointMake( [xx floatValue],  [yy floatValue]);
                                    
                                    for (CCSprite *sprite in tagSprites)
                                    {
                                        if(fabs([sprite position].x - thep.x)<1.0)
                                        {
                                            
                                            
                                            
                                            self.isTouchEnabled=YES;
                                            
                                            CCSprite *Build=[CCSprite spriteWithFile:pngg];
                                            
                                            [buildingSprites addObject:Build];
                                            
                                            Build.position=thep;
                                            
                                            [self addChild:Build z:3];
                                            
                                        }
                                    }
                                    
                                    
                                }
                                
                                
                                
                                
                            }];
                            
                            
                        }
                        
                    }];
                    
                    
                }];
            }];
        }];
    }];
    
    

}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    
    
    CGPoint point;
    point=[self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:point];
    NSLog(@"%f",point.x);
    NSLog(@"%f",point.y);
    return TRUE;

}
-(void)selectSpriteForTouch:(CGPoint) point
{
    for (CCSprite *sprite in buildingSprites) {
        if (CGRectContainsPoint(sprite.boundingBox, point)) {
            selSprite=sprite;
            [self updateBuilding];
            return;
        }
    }
    for (CCSprite *sprite in tagSprites)
    {
        if (CGRectContainsPoint(sprite.boundingBox, point))
        {
            selSprite=sprite;
            [self ChoicePanel];
            return;
        }
    }
}
-(void)updateBuilding
{
    //self.isTouchEnabled=NO;
    [CCMenuItemFont setFontName:@"Marker Felt"];
    [CCMenuItemFont setFontSize:30];
    CCMenuItemFont  *Delete=[CCMenuItemFont itemFromString:@"拆除" target:self selector:@selector(delete:)];
    CCMenuItemFont *upGrade=[CCMenuItemFont itemFromString:@"升级" target:self selector:@selector(upgrade:)];
    CCMenu *menu=[CCMenu menuWithItems:Delete,upGrade,nil];
    [menu setPosition:ccp(selSprite.position.x+50, selSprite.position.y-50)];
    [menu alignItemsHorizontally];
    [self addChild:menu z:3 tag:103];
}
-(void) ChoicePanel
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCSprite *Panel=[CCSprite spriteWithFile:@"弹框.png"];
    Panel.position=ccp(size.width/2, size.height/2);
    [self addChild:Panel z:3 tag:3];
    CCSprite *Menu1=[CCSprite spriteWithFile:@"农田－menu.png" rect:CGRectMake(0, 0, 100, 100) ];
    CCSprite *Menu2=[CCSprite spriteWithFile:@"钢铁厂－menu.png" rect:CGRectMake(0,0,100,100) ];
    CCSprite *Menu3=[CCSprite spriteWithFile:@"石油厂－menu.png" rect:CGRectMake(0, 0,100, 100)];
    CCSprite *Menu4=[CCSprite spriteWithFile:@"稀矿场－menu.png" rect:CGRectMake(0, 0, 100, 100)];
    
    CCMenuItemSprite *menu1=[CCMenuItemSprite itemFromNormalSprite:Menu1 selectedSprite:nil target:self selector:@selector(Choicemenu1:) ];
    CCMenuItemSprite *menu2=[CCMenuItemSprite itemFromNormalSprite:Menu2 selectedSprite:nil target:self selector:@selector(Choicemenu2:)];
    CCMenuItemSprite *menu3=[CCMenuItemSprite itemFromNormalSprite:Menu3 selectedSprite:nil target:self selector:@selector(Choicemenu3:)];
    CCMenuItemSprite *menu4=[CCMenuItemSprite itemFromNormalSprite:Menu4 selectedSprite:nil target:self selector:@selector(Choicemenu4:)];
    //CCMenuItemSprite *menu3=[CCMenuItemSprite i]
    CCMenu *menu=[CCMenu menuWithItems:menu1,menu2,menu3,menu4,nil];
    [menu alignItemsVerticallyWithPadding:0];
    [menu setPosition:ccp(7*size.width/24,5*size.height/11 )];
    [self addChild:menu z:4 tag:4];
}
-(void)Choicemenu1:sender
{
    [self removeChildByTag:4 cleanup:YES];
    [self removeChildByTag:3 cleanup:YES];
    self.isTouchEnabled=YES;
    CCSprite *Build=[CCSprite spriteWithFile:@"农田.png"];
    [buildingSprites addObject:Build];
    Build.position=selSprite.position;
    [self addChild:Build z:3];
    [self rotateWrench];
    
    
    CGPoint myp = Build.position;
    [self saveToServer:&myp withPng:@"农田.png"];
    
    
}
-(void)Choicemenu2:sender
{
    [self removeChildByTag:4 cleanup:YES];
    [self removeChildByTag:3 cleanup:YES];
    self.isTouchEnabled=YES;
    CCSprite *Build=[CCSprite spriteWithFile:@"钢铁厂.png"];
    [buildingSprites addObject:Build];
    Build.position=selSprite.position;
    [self addChild:Build z:3];
    [self rotateWrench];
    CGPoint myp = Build.position;
    [self saveToServer:&myp withPng:@"building2.png"];
    
}
-(void)Choicemenu3:sender
{
    [self removeChildByTag:4 cleanup:YES];
    [self removeChildByTag:3 cleanup:YES];
    self.isTouchEnabled=YES;
    CCSprite *Build=[CCSprite spriteWithFile:@"石油厂.png"];
    [buildingSprites addObject:Build];
    Build.position=selSprite.position;
    [self addChild:Build z:3];
    [self rotateWrench];
    CGPoint myp = Build.position;
    [self saveToServer:&myp withPng:@"building2.png"];
    
}
-(void)Choicemenu4:sender
{
    [self removeChildByTag:4 cleanup:YES];
    [self removeChildByTag:3 cleanup:YES];
    self.isTouchEnabled=YES;
    CCSprite *Build=[CCSprite spriteWithFile:@"稀矿场.png"];
    [buildingSprites addObject:Build];
    Build.position=selSprite.position;
    [self addChild:Build z:3];
    [self rotateWrench];
    CGPoint myp = Build.position;
    [self saveToServer:&myp withPng:@"building2.png"];
    
}
-(void)saveToServer:(CGPoint *)point withPng:(NSString *)png
{
    NSLog(@"invoke");
    
   NSNumber *myx = [NSNumber numberWithFloat:point->x];
    NSNumber *myy = [NSNumber numberWithFloat:point->y];
    
    

    
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                name, @"username",
                                channel, @"rid",
                                myx, @"pointx",
                                myy, @"pointy",
                                png,@"png",
                                @"military",@"category",
                                nil];
        [pomelo requestWithRoute:@"connector.entryHandler.addArchitecture" andParams:params andCallback:^(NSDictionary *result){
            NSArray *userList = [result objectForKey:@"users"];
            for (NSString *name2 in userList) {
                NSLog(@"%@",name2);
                
                
            }
            
        }];


    
    
}
-(void) labelOfNum
{
   
    [label setString:[NSString stringWithFormat:@"石油：%i\n粮食：%i\n钢铁：%i\n锡矿：%i",playerResource.Fuel,playerResource.Crop,playerResource.Steel,playerResource.Xi]];
}
-(void)delete:(id)sender
{
    [self removeChildByTag:103 cleanup:YES];
    [self removeChild:selSprite  cleanup:YES];
    [buildingSprites removeObject:selSprite ];
    
}
-(void)upgrade:(id)sender
{
    [self removeChildByTag:103 cleanup:YES];
    //[self removeChild:selSprite cleanup:YES];
}
-(void)sceneTransition:(id)sender
{
    CCTransitionFade *tran=[CCTransitionFade transitionWithDuration:2 scene:[ResourceScene scene] withColor:ccWHITE];
    [[CCDirector sharedDirector] replaceScene:tran];
}
-(void) rotateWrench
{
    CCSprite *wrench=[CCSprite spriteWithFile:@"Wrench2.png" ];
    wrench.position=ccp(selSprite.position.x-50, selSprite.position.y+50);
    [self addChild:wrench z:2 tag:19];
    CCAction *rotate1=[CCRotateBy actionWithDuration:0.75 angle:60.0f];
    CCAction *rotate2=[CCRotateBy actionWithDuration:0.75 angle:-60.0f];
    CCSequence *sequence=[CCSequence actions: rotate1,rotate2,nil];
    CCRepeat *repeat=[CCRepeat actionWithAction:sequence  times:10 ];
    repeat.tag=20;
    CCAction *delete=[CCCallFuncN actionWithTarget:self selector:@selector(clean:) ];
    [wrench runAction:[CCSequence actions:repeat,delete,nil]];
        
}
-(void)clean:(id)sender
{
    [self removeChild:sender cleanup:YES];
}
-(void) showLeaveAlert
{
    //UIAlertView ＊alert=[UIAlertView ]
}
-(void)addup:(id)sender
{
    [playerResource setCrop:50];
    [playerResource setFuel:50];
    [playerResource setSteel:50];
    [playerResource setXi:50];
}
// on "dealloc" you need to release all your retained objects







@end
