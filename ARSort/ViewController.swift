//
//  ViewController.swift
//  ARSort
//
//  Created by CuiZihan on 2020/7/23.
//  Copyright © 2020 CuiZihan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var algorithmChooseView: UISegmentedControl!
    @IBOutlet weak var infoLabel: UILabel!
    
    // properties
    let algorithms: [String] = ["Bubble Sort", "Quick Sort", "Insert Sort"]
    var planeNode: SCNNode?
    var baseNode: SCNNode?
    var boxNodes: [SCNNode] = []
    var values: [Float] = []
    var updateCount: NSInteger = 0
    let semphore: DispatchSemaphore = DispatchSemaphore(value: 2)
    var sorter: Sorter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startButton.isHidden = true
        // Find a horizontal surface
        sceneView.showsStatistics = true
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        
        // Init value and boxNodes
        
        for i in 0..<20 {
            values.append(Float(i) * 1.0 / 20.0)
        }
        
        for i in 0..<20 {
            let box = SCNBox(width: 0.025, height: CGFloat(0.025 + 0.1 * values[i]), length: 0.025, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor(cgColor: CGColor(genericGrayGamma2_2Gray: CGFloat(values[i]), alpha: 1))
            boxNodes.append(SCNNode(geometry: box))
        }
        
        sorter = Sorter(for: values, sortDelegate: self, semphoreDelegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func startButtonPress(_ sender: Any) {
        print("Select \(algorithms[algorithmChooseView.selectedSegmentIndex])")
        startButton.isHidden = true
        resetButton.isHidden = true
        self.stopTracking()
        // self.swapBox(box1: 0, box2: 16)
        // sorter.sort(using: .bubbleSort)
        var alg: Sorter.algorithm
        switch algorithmChooseView.selectedSegmentIndex {
        case 0:
            alg = .bubbleSort
        case 1:
            alg = .quickSort
        case 2:
            alg = .insertSort
        default:
            alg = .bubbleSort
        }
        let operationQueue = OperationQueue()
        let group = DispatchGroup()
        group.enter()
        operationQueue.addOperation {
            self.sorter.sort(using: alg)
            group.leave()
        }
        
        group.notify(queue: .main, execute: {
            self.resetButton.isHidden = false
        })
        
    }

    @IBAction func resetButtonPress(_ sender: Any) {
        resetAll()
    }
    
    
}

extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
        
    
    // node添加到新的锚点上之后(一般在这个方法中添加几何体节点,作为node的子节点)
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //1.获取捕捉到的平地锚点,只识别并添加一个平面
        if let planeAnchor = anchor as? ARPlaneAnchor,node.childNodes.count < 1,updateCount < 1 {
            print("捕捉到平地")
            //2.创建一个平面    （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个长方形）
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
            plane.firstMaterial?.diffuse.contents = UIColor.black
            //4.创建一个基于3D物体模型的节点
            planeNode = SCNNode(geometry: plane)
            //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
            planeNode?.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
            //6.`SCNPlane`默认是竖着的,所以旋转一下以匹配水平的`ARPlaneAnchor`
            planeNode?.eulerAngles.x = -.pi / 2
            
            //7.更改透明度
            planeNode?.opacity = 0.0
            //8.添加到父节点中
            node.addChildNode(planeNode!)
            
            
            //9. 放置一系列的长方体
            for i in 0..<20 {
                boxNodes[i].position = SCNVector3Make(planeAnchor.center.x + (Float(i) / 20.0 - 0.5) / 2.0, (0.025 + 0.1 * values[i])/2.0, planeAnchor.center.z)
                node.addChildNode(boxNodes[i])
            }
        }
    }
    
    // 更新锚点和对应的node之前调用,ARKit会自动更新anchor和node,使其相匹配
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        // 只更新在`renderer(_:didAdd:for:)`中得到的配对的锚点和节点.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        updateCount += 1
        if updateCount > 10 {//平面超过更新10次,捕捉到的特征点已经足够多了,可以显示进入游戏按钮
            DispatchQueue.main.async {
                self.startButton.isHidden = false
                self.infoLabel.isHidden = true
            }
        }
        
        // 平面的中心点可以会变动.
        planeNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /*
         平面尺寸可能会变大,或者把几个小平面合并为一个大平面.合并时,`ARSCNView`自动删除同一个平面上的相应节点,然后调用该方法来更新保留的另一个平面的尺寸.(经过测试,合并时,保留第一个检测到的平面和对应节点)
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    // 更新锚点和对应的node之后调用
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    // 移除锚点和对应node后
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
    }
        
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("error: \(error.localizedDescription)")
        infoLabel.text = error.localizedDescription
    }
        
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session is interrupted")
        infoLabel.text = "session is interrupted"
    }
        
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        infoLabel.text = ""
        infoLabel.isHidden = true
        resetTracking()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateInfoLabel(session.currentFrame!, camera.trackingState)
    }
}


// private function

extension ViewController {
    private func resetAll() {
        self.infoLabel.isHidden = false
        self.startButton.isHidden = true
        //1.重置平面检测配置,重启检测
        resetTracking()
        //2.重置更新次数
        updateCount = 0
        
        
        let shuffledValues = values.shuffled()
        var newIndexes:[Int] = []
        
        for value in shuffledValues {
            for i in 0..<values.count {
                if value == values[i] {
                    newIndexes.append(i)
                }
            }
        }
        
        self.values = shuffledValues
        self.sorter = Sorter(for:values, sortDelegate: self, semphoreDelegate: self)
        
        
        var newBoxs:[SCNNode] = []
        for i in newIndexes {
            newBoxs.append(self.boxNodes[i])
        }
        
        for i in 0..<newBoxs.count {
            newBoxs[i].position = boxNodes[i].position
        }
        
        self.boxNodes = newBoxs
    }
    
    private func resetTracking() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Find a horizontal plane
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration,options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func stopTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .init(rawValue: 0)
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    private func updateInfoLabel(_ frame: ARFrame, _ state: ARCamera.TrackingState) {
        let message: String
        print("status")
        switch state {
        case .normal where frame.anchors.isEmpty:
            // 未检测到平面
            message = "移动设备来探测水平面."
            
        case .normal:
            // 平面可见,跟踪正常,无需反馈
            message = ""
            
        case .notAvailable:
            message = "无法追踪."
            
        case .limited(.excessiveMotion):
            message = "追踪受限-请缓慢移动设备."
            
        case .limited(.insufficientFeatures):
            message = "追踪受限-将设备对准平面上的可见花纹区域,或改善光照条件."
            
        case .limited(.initializing):
            message = "初始化AR中."
            
        case .limited(.relocalizing):
            message = ""
        case .limited(_):
            message = ""
        }
        print(message)
        
        infoLabel.text = message
        infoLabel.isHidden = message.isEmpty
    }
    
    private func swapBox(box1 i: Int, box2 j: Int) {
        let box1 = boxNodes[i]
        let box2 = boxNodes[j]
        let action1 = SCNAction.move(by: SCNVector3Make(0, -0.125, 0), duration: 0.1)
        let action2 = SCNAction.move(by: SCNVector3Make(0, 0.125, 0), duration: 0.1)
        let action3 = SCNAction.move(by: SCNVector3Make(box2.position.x - box1.position.x, 0, 0), duration: 0.1)
        let action4 = SCNAction.move(by: SCNVector3Make(box1.position.x - box2.position.x, 0, 0), duration: 0.1)
        let action5 = SCNAction.move(by: SCNVector3Make(0, 0.125, 0), duration: 0.1)
        let action6 = SCNAction.move(by: SCNVector3Make(0, -0.125, 0), duration: 0.1)
        
        let sequences1 = SCNAction.sequence([action1, action3, action5])
        let sequences2 = SCNAction.sequence([action2, action4, action6])
        
        // 获取信号量
        self.getSemphore()
        self.getSemphore()
        
        // 动画结束后再释放信号量
        box1.runAction(sequences1, completionHandler: self.releaseSemphore)
        box2.runAction(sequences2, completionHandler: self.releaseSemphore)
        
        boxNodes[i] = box2
        boxNodes[j] = box1
        
        print("swap return")
    }
}

extension ViewController: SortDelegate {
    func swap(i: Int, j: Int) {
        self.swapBox(box1: i, box2: j)
        let temp = values[i]
        values[i] = values[j]
        values[j] = temp
    }
}


extension ViewController: SemphoreDelegate {
    func getSemphore() {
        self.semphore.wait()
        // print("get semphore")
    }
    
    func releaseSemphore() {
        self.semphore.signal()
        // print("release semphore")
    }
}





