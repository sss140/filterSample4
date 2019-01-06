import UIKit

class ViewController: UIViewController {
    /*使用するCIFilterのリスト
    https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/
    から好みのフィルターをコピペ*/
    let filterList:[String] = ["CIColorControls","CIBumpDistortion","CITwirlDistortion",
                               "CIVortexDistortion","CITorusLensDistortion","CIHoleDistortion",
                               "CIBumpDistortionLinear","CIPinchDistortion","CICircularWrap",
                               "CICircleSplashDistortion","CIPixellate","CIPointillize",
                               "CILineOverlay","CIBoxBlur","CIComicEffect"]
    var filterListumber:Int = 0
    
    var viewWidth = CGFloat()
    var myRect = CGRect()
    
    var imageNameArray:[String] = []
    var myUIImageArray:[UIImage] = []
    
    let rootUIImageView = UIImageView()
    var filterButton = UIButton()
    var partsView = UIScrollView()
    var partsCounter = 0
    
    var myInputCenter = CIVector()
    var myCIFilter = CIFilter()
    
    let myCIContext = CIContext(options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWidth = self.view.bounds.width
        myRect = CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewWidth)
        myInputCenter = CIVector(x: viewWidth/2.0, y: viewWidth/2.0)
        
        makeRootUIImageView()//画像のUIImageViewを作成する。
        
        myUIImageArray.append(makeCheckImage())    //チェック柄のUIImageを作成する。それを配列に入れる。
        fileNameCheck()//bundle内のファイルを調べて画像ファイルのみ配列に格納する。
        if myUIImageArray.count > 0 {
        changeSizeofUIImage()//配列に入った画像ファイルを整形してUIImageに変換。
        }
        
        makeFilterButton(filterName: filterList[filterListumber])//フィルターを変更するボタンを作成する。
        makeParts(filterName: filterList[filterListumber])//パラメータを変更するUISliderを作成する。
        makeCIFilter()
    }
    
    //画像のUIImageViewを作成する。
    func makeRootUIImageView(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRootUIImageView(sender:)))
        rootUIImageView.isUserInteractionEnabled = true
        rootUIImageView.addGestureRecognizer(tapGesture)
        rootUIImageView.frame = myRect
        rootUIImageView.tag = 0
        self.view.addSubview(rootUIImageView)
    }
    //画像のUIImageViewがタップされたときの動作
    @objc func tapRootUIImageView(sender:UITapGestureRecognizer){
        sender.view!.tag = (sender.view!.tag + 1) % myUIImageArray.count
        print(myUIImageArray[sender.view!.tag])
        self.partsView.removeFromSuperview()
        makeParts(filterName: filterList[filterListumber])
        makeCIFilter()
    }
    //チェック柄のUIImageを作成する。
    func makeCheckImage()->UIImage{
        var myCheckImage = UIImage()
        let checkFilter = CIFilter(name: "CICheckerboardGenerator")
        checkFilter?.setValue(30.0, forKey: "inputWidth")
        if let myOutput = checkFilter?.outputImage{
            myCheckImage = UIImage(cgImage: myCIContext.createCGImage(myOutput, from: myRect)!)
        }
        return myCheckImage
    }
    
    //bundle内のファイルを調べて画像ファイルのみ配列に格納する。
    func fileNameCheck(){
        do {
            let files = try FileManager().contentsOfDirectory(atPath: Bundle.main.bundlePath)
            for picName in files{
                if picName.contains(".jpg"){
                    print(picName)
                    self.imageNameArray.append(picName)
                }
                if picName.contains(".png"){
                    print(picName)
                    self.imageNameArray.append(picName)
                }
            }
            } catch let error {
            print(error)
            }
    }
    
    //配列に入った画像ファイルを整形してUIImageに変換。
    func changeSizeofUIImage(){
        UIGraphicsBeginImageContextWithOptions(CGSize(width: viewWidth, height: viewWidth), false, 1.0)
        for imgString in imageNameArray{
            let myUIImage = UIImage(named:imgString)
            myUIImage!.draw(in: CGRect(x: 0.0, y: 0.0, width: viewWidth, height: viewWidth))
            let myImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            myUIImageArray.append(myImage)
        }
        UIGraphicsEndImageContext()
    }
    //フィルターを変更するボタンを作成する。
    func makeFilterButton(filterName:String){
        let myButtonRect = CGRect(x: 0.0, y: viewWidth + 00.0, width: viewWidth, height: 40.0)
        filterButton = UIButton(frame: myButtonRect)
        filterButton.backgroundColor = UIColor.black
        filterButton.setTitleColor(UIColor.white, for: .normal)
        filterButton.setTitle(filterName, for: .normal)
        filterButton.addTarget(self, action: #selector(self.tapFilterButton(sender:)), for: .touchUpInside)
        self.view.addSubview(filterButton)
    }
    @objc func tapFilterButton(sender:UIButton){
        filterListumber += 1
        filterListumber %= filterList.count
        filterButton.setTitle(filterList[filterListumber], for: .normal)
        filterButton.backgroundColor = UIColor.white
        UIView.animate(withDuration: 0.5, animations: {self.filterButton.backgroundColor = UIColor.black}, completion: nil)
        myInputCenter = CIVector(x: viewWidth/2.0, y: viewWidth/2.0)
        self.partsView.removeFromSuperview()
        makeParts(filterName: filterList[filterListumber])
        makeCIFilter()
    }
    
    //パラメータを変更するUISliderを作成する。
    func makeParts(filterName:String){
        partsCounter = 0
        myCIFilter = CIFilter(name: filterName)!
        let myCIImage = CIImage(image:myUIImageArray[rootUIImageView.tag])
        myCIFilter.setValue(myCIImage, forKey: "inputImage")
        
        let myPartsViewRect = CGRect(x: 0.0, y: viewWidth + 40.0, width: viewWidth, height: self.view.bounds.height - viewWidth - 40.0)
        partsView = UIScrollView(frame: myPartsViewRect)
        partsView.contentSize = .zero
        partsView.contentSize.width = viewWidth
        self.view.addSubview(partsView)
        
        for i in myCIFilter.inputKeys{
            
            if let myVal = myCIFilter.value(forKeyPath: i) as? CIVector{
                switch myVal.count{
                case 2:
                    myCIFilter.setValue(myInputCenter, forKey: i)
                    let partsValue = myCIFilter.value(forKeyPath: i) as! CIVector
                    partsCounter += 1
                    putParts(counter: partsCounter,partsName: i + "(x)",partsValue: Float(partsValue.x),maxValue: Float(viewWidth) * 1.5,minValue: Float(viewWidth) * -0.5)
                    partsCounter += 1
                    putParts(counter: partsCounter,partsName: i + "(y)",partsValue: Float(partsValue.y),maxValue: Float(viewWidth) * 1.5,minValue: Float(viewWidth) * -0.5)
                default:
                    print(myVal.count)
                }
            }
             if (myCIFilter.value(forKeyPath: i) as? Double) != nil{
                partsCounter += 1

                let partsValue = myCIFilter.value(forKeyPath: i) as! Double
                let maxPartsValue = Float(partsValue * 5.0 + 3.14)
                switch i{
                case "inputRadius":putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: Float(viewWidth + 100.0),minValue: -100.0)
                case "inputScale" :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: 15.0,minValue: -15.0)
                case "inputAngle"         :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputRefraction"    :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputWidth"         :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputNRNoiseLevel"  :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputNRSharpness"   :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputEdgeIntensity" :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputThreshold"     :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputContrast"      :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputBrightness"    :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                case "inputSaturation"    :putParts(counter: partsCounter,partsName: i ,partsValue: Float(partsValue),maxValue: maxPartsValue,minValue: maxPartsValue * -1.0)
                default:print(i)
                }
            }
        }
    }
    //パラメータを変更するUISliderとUILabelを作成する。
    func putParts(counter:Int, partsName:String,partsValue:Float,maxValue:Float,minValue:Float){
        var myLabelRect = CGRect(x: 30.0, y: CGFloat(counter * 40 - 20), width: viewWidth, height: 20.0)
        let myLabel = UILabel(frame: myLabelRect)
        myLabel.text = partsName
        myLabel.tag = partsCounter + 20
        self.partsView.addSubview(myLabel)
        
        myLabelRect = CGRect(x: viewWidth - 100.0, y: CGFloat(counter * 40 - 20), width: 100.0, height: 20.0)
        let myValueLabel = UILabel(frame: myLabelRect)
        myValueLabel.text = String(partsValue)
        myValueLabel.tag = partsCounter + 10
        self.partsView.addSubview(myValueLabel)
        
        let mySliderRect = CGRect(x: 30.0, y: CGFloat(counter * 40), width: viewWidth - 60.0, height: 20.0)
        let mySlider = UISlider(frame: mySliderRect)
        mySlider.maximumValue = maxValue
        mySlider.minimumValue = minValue
        mySlider.value = partsValue
        mySlider.tag = partsCounter
        mySlider.addTarget(self, action: #selector(self.moveSlider), for: .touchDragInside)
        self.partsView.contentSize.height += 40.0
        self.partsView.addSubview(mySlider)
    }
    
    //UISliderが動いたときの設定。
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
    
    //フィルターや画像が変更されたときの設定。
    func makeCIFilter(){
        if let output = myCIFilter.outputImage{
            let myImage = UIImage(cgImage: myCIContext.createCGImage(output, from: myRect)!)
            rootUIImageView.image = myImage
        }
    }
}

