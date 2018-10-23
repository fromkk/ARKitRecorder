//
//  ViewController.swift
//  ARRecorderSample
//
//  Created by Kazuya Ueoka on 2017/11/17.
//  Copyright © 2017 Timers, Inc. All rights reserved.
//

import UIKit
import ARKit
import ARKitRecorder
import AVFoundation

class ViewController: UIViewController {
    
    var recorder: ARKitRecorder?
    
    enum State {
        case none
        case recording
    }
    
    var state: State = .none
    
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: self.view.bounds, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func layoutSceneView() {
        NSLayoutConstraint.activate([
            sceneView.widthAnchor.constraint(equalTo: view.widthAnchor),
            sceneView.heightAnchor.constraint(equalTo: view.heightAnchor),
            sceneView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sceneView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
    }
    
    lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 32.0
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleTap(button:)), for: .touchUpInside)
        return button
    }()
    
    private func layoutButton() {
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 64.0),
            button.heightAnchor.constraint(equalToConstant: 64.0),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -58.0),
            ])
    }
    
    @objc private func handleTap(button: UIButton) {
        if state == .none {
            recorder?.start(with: sceneView) { (error) in
                debugPrint(#function, "start", error)
            }
            state = .recording
        } else {
            recorder?.finish({ (url) in
                debugPrint(#function, "finish", url)
                
                self.state = .none
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sceneView)
        layoutSceneView()
        
        view.addSubview(button)
        layoutButton()
        
        recorder = ARKitRecorder(options: ARKitRecorder.Options())
        sceneView.delegate = recorder
        
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func handleTap(_ tapGesture: UITapGestureRecognizer) {
        let point: CGPoint = tapGesture.location(in: sceneView)
        guard let hitPosition = sceneView.hitTest(point, types: [.featurePoint]).first else { return }
        
        let position: SCNVector3 = SCNVector3(hitPosition.worldTransform.columns.3.x, hitPosition.worldTransform.columns.3.y, hitPosition.worldTransform.columns.3.z)
        
        let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.0)
        let white = SCNMaterial()
        white.diffuse.contents = UIColor.white
        box.materials = [white]
        let node = SCNNode(geometry: box)
        node.position = position
        sceneView.scene.rootNode.addChildNode(node)
    }
}

