import UIKit

class ViewController: UIViewController {
    let filterList:[String] = ["CIBumpDistortion","CITwirlDistortion"]
    var filterListumber:Int = 1
    
    let rootUIImageView = UIImageView()
    var myRect = CGRect()
    var myInputCenter = CIVector()
    var myCIFilter = CIFilter()
    let myCIContext = CIContext(options: nil)
    var myCheckUIImage = UIImage()
    var viewWidth = CGFloat()
    var partsCounter = 0
    var partsNameArray:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWidth = self.view.bounds.width
        myRect = CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewWidth)
        myInputCenter = CIVector(x: viewWidth/2.0, y: viewWidth/2.0)
        
        rootUIImageView.frame = myRect
        self.view.addSubview(rootUIImageView)
        myCheckUIImage = makeCheckImage()
        
        makeParts(filterName: filterList[filterListumber])
        makeCIFilter()
    }
    func makeCIFilter(){
        if let output = myCIFilter.outputImage{
        let myImage = UIImage(cgImage: myCIContext.createCGImage(output, from: myRect)!)
        rootUIImageView.image = myImage
        }
    }
    func makeCheckImage()->UIImage{
        var myCheckImage = UIImage()
        let checkFilter = CIFilter(name: "CICheckerboardGenerator")
        checkFilter?.setValue(30.0, forKey: "inputWidth")
        if let myOutput = checkFilter?.outputImage{
            myCheckImage = UIImage(cgImage: myCIContext.createCGImage(myOutput, from: myRect)!)
        }
        return myCheckImage
    }
    func makeParts(filterName:String){
        myCIFilter = CIFilter(name: filterName)!
        let myCIImage = CIImage(image:myCheckUIImage)
        myCIFilter.setValue(myCIImage, forKey: "inputImage")
        let myLabelRect = CGRect(x: 0.0, y: viewWidth + 20.0, width: viewWidth, height: 20.0)
        let myLabel = UILabel(frame: myLabelRect)
        myLabel.textAlignment = .center
        myLabel.text = filterName
        self.view.addSubview(myLabel)
        partsNameArray.append(filterName)
        for i in myCIFilter.inputKeys{
            partsCounter += 1
            if (myCIFilter.value(forKeyPath: i) as? CIVector) != nil{
                myCIFilter.setValue(myInputCenter, forKey: i)
                let partsValue = myCIFilter.value(forKeyPath: i) as! CIVector
                putParts(counter: partsCounter,partsName: i + "(x)",partsValue: Float(partsValue.x),maxValue: Float(viewWidth) * 1.5,minValue: Float(viewWidth) * -0.5)
                partsCounter += 1
                putParts(counter: partsCounter,partsName: i + "(y)",partsValue: Float(partsValue.y),maxValue: Float(viewWidth) * 1.5,minValue: Float(viewWidth) * -0.5)
            }
             if (myCIFilter.value(forKeyPath: i) as? Double) != nil{
                let partsValue = myCIFilter.value(forKeyPath: i) as! Double
                if i == "inputRadius"{
                putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: Float(viewWidth),minValue: 0.0)
                }
                if i == "inputScale"{
                    putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: 5.0,minValue: -5.0)
                }
                if i == "inputAngle"{
                    putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: 10.0,minValue: -10.0)
                }
            }
        }
    }
    func putParts(counter:Int, partsName:String,partsValue:Float,maxValue:Float,minValue:Float){
        var myLabelRect = CGRect(x: 30.0, y: viewWidth - 20.0 + CGFloat(counter * 40), width: viewWidth, height: 20.0)
        let myLabel = UILabel(frame: myLabelRect)
        myLabel.text = partsName
        myLabel.tag = partsCounter + 20
        self.view.addSubview(myLabel)
        
        myLabelRect = CGRect(x: viewWidth - 100.0, y: viewWidth - 20.0 + CGFloat(counter * 40), width: 100.0, height: 20.0)
        let myValueLabel = UILabel(frame: myLabelRect)
        myValueLabel.text = String(partsValue)
        myValueLabel.tag = partsCounter + 10
        self.view.addSubview(myValueLabel)
        
        let mySliderRect = CGRect(x: 30.0, y: viewWidth + CGFloat(counter * 40), width: viewWidth - 60.0, height: 20.0)
        let mySlider = UISlider(frame: mySliderRect)
        mySlider.maximumValue = maxValue
        mySlider.minimumValue = minValue
        mySlider.value = partsValue
        mySlider.tag = partsCounter
        mySlider.addTarget(self, action: #selector(self.moveSlider), for: .touchDragInside)
        self.view.addSubview(mySlider)
    }
    @objc func moveSlider(sender:UISlider){
        let myLabel = self.view.viewWithTag(sender.tag + 10) as! UILabel
        myLabel.text = String(round(sender.value * 10)/10)
        let myNameLabel = self.view.viewWithTag(sender.tag + 20) as! UILabel
        if myNameLabel.text!.contains("(x)"){
            myInputCenter = CIVector(x: CGFloat(sender.value), y: myInputCenter.y)
            myCIFilter.setValue(myInputCenter, forKey: "inputCenter")
        }else if myNameLabel.text!.contains("(y)"){
            myInputCenter = CIVector(x: myInputCenter.x, y: CGFloat(sender.value))
            myCIFilter.setValue(myInputCenter, forKey: "inputCenter")
        } else{
            myCIFilter.setValue(sender.value, forKey: myNameLabel.text!)
        }
    makeCIFilter()
    }
}

