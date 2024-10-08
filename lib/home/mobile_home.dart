import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:job_hunter/service/api_service.dart';
import 'package:job_hunter/widgets/youtube_video_view_widget.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class MobileHomePage extends StatefulWidget {
  final String title;
  const MobileHomePage({super.key, required this.title});

  @override
  State<MobileHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MobileHomePage> {
  String _counter = "Your AI tips will appear here.";
  bool _isUploading = false;
  bool _isLoading = false;
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _resumeTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        _isUploading
                            ? const CircularProgressIndicator()
                            : Container(
                                margin: const EdgeInsets.all(16),
                                child: TextFormField(
                                  controller: _resumeTextController,
                                  readOnly: true,
                                  textAlign: TextAlign.left,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    constraints: BoxConstraints(
                                      maxWidth: 200,
                                      maxHeight: 250,
                                      minHeight: 200,
                                      minWidth: 100,
                                    ),
                                    labelText: 'Resume Text',
                                  ),
                                  maxLines: 200,
                                ),
                              ),
                        ElevatedButton(
                          onPressed: () async {
                            // Respond to button press
                            await getPDFtext()
                                .then(
                                  (value) => setState(
                                    () {
                                      _resumeTextController.text = value;
                                    },
                                  ),
                                )
                                .whenComplete(
                                  () => setState(
                                    () {
                                      _isUploading = false;
                                    },
                                  ),
                                );
                          },
                          child: const Text('Upload CV'),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.all(24),
                      child: TextFormField(
                        controller: _jobDescriptionController,
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          constraints: BoxConstraints(
                            maxWidth: 200,
                            maxHeight: 250,
                            minHeight: 200,
                            minWidth: 100,
                          ),
                          // labelText: 'Job Description',
                          hintText:
                              "Paste the job description here. If you don't have one, you can put n/a and proceed to ask gemini by clicking the send button below.",
                        ),
                        maxLines: 200,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Here are some suggestions to improve your CV:',
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(8),
                      constraints:
                          const BoxConstraints(minWidth: 250, maxWidth: 600),
                      decoration: BoxDecoration(
                        // border: Border.all(
                        //   color: Theme.of(context).colorScheme.primary,
                        // ),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _counter,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
              Container(
                padding: const EdgeInsets.all(8),
                height: 6000,
                width: 315,
                child: const Column(
                  children: [
                    Text(
                      'Watch this video to learn how to use the app:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: YoutubeVideoViewWidget(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint(_resumeTextController.text);
          debugPrint(_jobDescriptionController.text);
          _incrementCounter(
            resumeText: _resumeTextController.text,
            jobDescription: _jobDescriptionController.text,
          );
        },
        tooltip: 'Talk to Gemini!',
        child: const Icon(Icons.send),
      ),
    );
  }

  Future<String> getPDFtext() async {
    setState(() {
      _isUploading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      dialogTitle: "Select your CV",
      type: FileType.custom,
    );

    if (result != null) {
      var file = result.files.single.xFile;
      var bytes = await file.readAsBytes();
      PdfDocument doc = PdfDocument(inputBytes: Uint8List.fromList(bytes));
      String text = PdfTextExtractor(doc).extractText();
      doc.dispose();
      return text;
    } else {
      // User canceled the picker
      return "No file selected";
    }
  }

  void _incrementCounter(
      {String resumeText = "", String jobDescription = ""}) async {
    setState(() {
      _isLoading = true;
    });
    var response = await talkWithGemini(
            resumeText: resumeText, jobDescription: jobDescription)
        .whenComplete(
      () => setState(
        () {
          _isLoading = false;
        },
      ),
    );
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter = response;
    });
  }
}
