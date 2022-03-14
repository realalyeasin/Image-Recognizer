import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

class ImageRecognition extends StatefulWidget {
  const ImageRecognition({Key? key}) : super(key: key);

  @override
  _ImageRecognitionState createState() => _ImageRecognitionState();
}

class _ImageRecognitionState extends State<ImageRecognition> {
  List? _results;
  File? _image;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1);
  }

  classifyImage(File image) async {
    var result = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading = false;
      _results = result;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future pickImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = image as File?;
      _loading = true;
    });
    classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.withOpacity(.9),
      appBar: AppBar(
        title: Text('Image Reconition'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.teal.withOpacity(.7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loading
                ? Container(
                    height: 400,
                    width: 400,
                  )
                : Container(
                    margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _image == null ? Container() : Image.file(_image!),
                        SizedBox(
                          height: 20,
                        ),
                        _image == null
                            ? Container()
                            : _results != null
                                ? Text(
                                    _results![0]["labels"],
                                  )
                                : Container(
                                    child: Text(""),
                                  )
                      ],
                    ),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            FloatingActionButton(
                backgroundColor: Colors.black,
                tooltip: 'Pick Image',
                child: Icon(
                  Icons.add_a_photo,
                  size: 20,
                  color: Colors.deepOrangeAccent,
                ),
                onPressed: () {
                  pickImage();
                })
          ],
        ),
      ),
    );
  }
}
