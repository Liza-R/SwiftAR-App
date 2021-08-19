//
//  ViewController.swift
//  SimpleARApp
//
//  Created by Elizaveta Rogozhina on 22.06.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate{

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var boxNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.showsStatistics = true//отображение статистики работы приложения
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        addBox()
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -1.0) {
        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)//создание куба с заданной длинной, шириной, высотой и радиусом рёбер
        let material = SCNMaterial()//создание материала объекта
        let color = UIColor(red: 0.680, green: 0.200, blue: 0.174, alpha: 0.98)//настройка цвета и прозрачности
        material.diffuse.contents = color
        //diffuse - свойство для присваивания светотени объекту отображения
        //contents - цвет объекта
        let scene = SCNScene()//создание пустой сцены
        boxNode = SCNNode(geometry: boxGeometry)//структурный элемент графа сцены, представляющий положение и преобразование в трехмерном координатном пространстве, к которому вы можете прикрепить геометрию, источники света, камеры или другой отображаемый контент.)
        boxNode?.geometry?.materials = [material]//присваивание материала нашему кубу
        boxNode?.position = SCNVector3(x: x, y: y, z: z)//расположение куба в реальном мире (x, y, z)
        scene.rootNode.addChildNode(boxNode!)//добавление куба на сцену
        //добавление жеста для перемещения объекта
        let gestRecog = UIPanGestureRecognizer(target: self, action: #selector(boxMove(gesture:)))
        self.sceneView.addGestureRecognizer(gestRecog)
        
        sceneView.scene = scene//присваивание реальной сцене (отображаемой через камеру) созданной сцены в коде
    }
    
    @objc func boxMove(gesture: UIPanGestureRecognizer){
        let tapLocation = gesture.location(in: self.sceneView)
        let results = self.sceneView.hitTest(tapLocation, types: .featurePoint)
        guard let result = results.first else { return }
        let translation = result.worldTransform.translation
        guard let node = self.boxNode else {
            self.addBox(x: translation.x, y: translation.y, z: translation.z)
            return
        }
            node.position = SCNVector3Make(translation.x, translation.y, translation.z)
        self.sceneView.scene.rootNode.addChildNode(self.boxNode!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
        //resultLabel.text = "\()"
        sceneView.session.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = frame.camera.transform
        let position = transform.columns.3
        resultLabel.text = "\(String(format: "Расстояние от уст-ва до объекта:: %.2f", position.z + 1))м;\nПараметры объекта:\nдлина: \(0.2)м, ширина: \(0.2)м, высота: \(0.2)м"
    }
}
