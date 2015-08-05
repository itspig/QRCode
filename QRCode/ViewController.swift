//
//  ViewController.swift
//  QRCode
//
//  Created by Nick Zhu on 15/8/5.
//  Copyright (c) 2015年 Nick Zhu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{

    @IBOutlet weak var labelQR: UILabel!
    
    //视频捕捉会话
    var session: AVCaptureSession?
    //画面预览层
    var videoPreViewLayer: AVCaptureVideoPreviewLayer?
    //锁定方块
    var autoLockView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //初始化捕捉会话
        session = AVCaptureSession()
        
        //指定设备是摄像头
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        //输入
        if let input = AVCaptureDeviceInput(device: device, error: nil) {
            
            session?.addInput(input)
        
        } else {
            println("无法使用摄像头")
            return
        }
        
        //输出
        let output = AVCaptureMetadataOutput()
        session?.addOutput(output)
        
        //添加元数据对象输出代理
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        //输出类型
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeFace]
        
        //视频预览层
        videoPreViewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreViewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreViewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreViewLayer)
        
        //启动会话
        session?.startRunning()
        
        //显示结果标签
        view.bringSubviewToFront(labelQR)
        
        //自动锁定框
        autoLockView = UIView()
        autoLockView?.layer.borderColor = UIColor.grayColor().CGColor
        autoLockView?.layer.borderWidth = 2
        view.addSubview(autoLockView!)
        view.bringSubviewToFront(autoLockView!)
        
    }

    //一旦视频捕捉到指定数据
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        //判断元数据是否有输出
        if metadataObjects == nil || metadataObjects.count == 0 {
            autoLockView?.frame = CGRectZero
            labelQR.text = "扫描中..."
            return
        }
        
        //如果是人脸
        if let obj = metadataObjects.first as? AVMetadataFaceObject {
            if obj.type == AVMetadataObjectTypeFace {
                let faceObject = videoPreViewLayer?.transformedMetadataObjectForMetadataObject(obj) as! AVMetadataFaceObject
                autoLockView?.frame = faceObject.bounds
                labelQR.text = "有人"
            }
        }
        
        if let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            let barCodeObject = videoPreViewLayer?.transformedMetadataObjectForMetadataObject(obj) as! AVMetadataMachineReadableCodeObject
            autoLockView?.frame = barCodeObject.bounds
            
            switch obj.type {
            case AVMetadataObjectTypeQRCode:
                if let decodeStr = obj.stringValue {
                    labelQR.text = "二维码: " + decodeStr
                }
            case AVMetadataObjectTypeEAN13Code:
                if let decodeStr = obj.stringValue {
                    labelQR.text = "商品码: " + decodeStr
                }
            default:
                return
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

