//
//  GameViewController.swift
//  sunModel
//
//  Created by 张鑫 on 2017/6/9.
//  Copyright © 2017年 CrowForRui. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    var sunNode = SCNNode.init()//太阳模型
    var earthNode = SCNNode.init()//地球模型
    var moonNode = SCNNode.init()//月亮模型
    var earthGroupNode = SCNNode.init()//地球节点
    var sunHaloNode = SCNNode.init()//日晕模型
    var scnView = SCNView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 35)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        ship.isHidden = true
//        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        scnView  = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        self.configView()
    }
    
    func configView(){
        //添加模型
        self.addNodes()
        //动画
        self.roationNode()
        //光线
        self.addLight()
    }
    
    func addNodes(){
        self.sunNode.geometry = SCNSphere.init(radius: 2.5)
        self.earthNode.geometry = SCNSphere.init(radius: 1.0)
        self.moonNode.geometry = SCNSphere.init(radius: 0.5)
        
        self.moonNode.position = SCNVector3.init(1.5, 0, 0)
        self.earthGroupNode.addChildNode(self.earthNode)
        self.earthGroupNode.position = SCNVector3.init(10, 0, 0)
        self.scnView.scene?.rootNode.addChildNode(self.sunNode)
        
        //添加材质
        self.earthNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/earth-diffuse-mini.jpg"
        self.earthNode.geometry?.firstMaterial?.emission.contents = "art.scnassets/earth/earth-emissive-mini.jpg"
        self.earthNode.geometry?.firstMaterial?.specular.contents = "art.scnassets/earth/earth-specular-mini.jpg"
        self.moonNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/moon.jpg"
        self.sunNode.geometry?.firstMaterial?.multiply.contents = "art.scnassets/earth/sun.jpg"
        self.sunNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun.jpg"
        self.sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5
        self.sunNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        
        //设置材质贴图重复
        self.sunNode.geometry?.firstMaterial?.multiply.wrapS = SCNWrapMode.repeat
        self.sunNode.geometry?.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
        self.sunNode.geometry?.firstMaterial?.multiply.wrapT = SCNWrapMode.repeat
        self.sunNode.geometry?.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
        //接收亮度
        self.earthNode.geometry?.firstMaterial?.shininess = 0.1
        //和环境混合的强度？？？我也不清楚这个属性，有懂的请留言
        self.earthNode.geometry?.firstMaterial?.specular.intensity = 0.5
        self.moonNode.geometry?.firstMaterial?.specular.contents = UIColor.gray
        
        //添加其他模型
        self.sunHaloNode = SCNNode.init()
        self.sunHaloNode.geometry = SCNPlane.init(width: 25, height: 25)
        self.sunHaloNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun-halo.png"
        self.sunHaloNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        self.sunHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false //不需要写入缓存中
        self.sunHaloNode.opacity = 0.2
        self.sunNode.addChildNode(self.sunHaloNode)
        
    }
    
    //自转动画
    func roationNode(){
        self.earthNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))//沿着y轴自转
        //CA动画 月球自转
        let moonAnimation = CABasicAnimation.init(keyPath: "rotation")
        moonAnimation.duration = 27.32
        moonAnimation.toValue = NSValue.init(scnVector4: SCNVector4Make(0, 1, 0, .pi * 2))
        moonAnimation.repeatCount = MAXFLOAT
        self.moonNode.addAnimation(moonAnimation, forKey: "moonAnimation")
        //月球公转
        let moonRotationNode = SCNNode.init()
        moonRotationNode.addChildNode(self.moonNode)
        let moonRotationAnimation = CABasicAnimation.init(keyPath: "rotation")
        moonRotationAnimation.duration = 8//应该是27.3
        moonRotationAnimation.toValue = NSValue.init(scnVector4: SCNVector4Make(0, 1, 0, .pi * 2))
        moonRotationAnimation.repeatCount = MAXFLOAT
        moonRotationNode.addAnimation(moonRotationAnimation, forKey: "moon rotation around earth")
        self.earthGroupNode.addChildNode(moonRotationNode)
        
        let earthRotationNode = SCNNode.init()
        self.sunNode.addChildNode(earthRotationNode)
        earthRotationNode.addChildNode(self.earthGroupNode)
        
        let earthToSun = CABasicAnimation.init(keyPath: "rotation")
        earthToSun.duration = 50//应该是365
        earthToSun.toValue = NSValue.init(scnVector4: SCNVector4Make(0, 1, 0, .pi * 2))
        earthToSun.repeatCount = MAXFLOAT
        earthRotationNode.addAnimation(earthToSun, forKey: "earthToSun")
        
        //太阳自转
//        self.sunNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 5)))//不可以直接这样写，因为日晕是一个平面矩形，加载sunnode上，直接自转sunnode会导致日晕转
        let sunAnimation = CABasicAnimation.init(keyPath: "contentsTransform")
        sunAnimation.duration = 10.0
        sunAnimation.fromValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeTranslation(3, 3, 3)))
        sunAnimation.toValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeTranslation(3, 3, 3)))
        sunAnimation.repeatCount = MAXFLOAT
        self.sunNode.geometry?.firstMaterial?.diffuse.addAnimation(sunAnimation, forKey: "sun-texture")
    }
    
    func addLight(){
        let lightNode = SCNNode.init()
        lightNode.light = SCNLight.init()
        lightNode.light?.color = UIColor.black
        lightNode.light?.type = SCNLight.LightType.omni
        self.sunNode.addChildNode(lightNode)
        lightNode.light?.attenuationEndDistance = 20.0;
        lightNode.light?.attenuationStartDistance = 19.5;
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        lightNode.light?.color = UIColor.white
        self.sunHaloNode.opacity = 0.5
        SCNTransaction.commit()
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
