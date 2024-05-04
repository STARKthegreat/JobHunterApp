import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:job_hunter/service/api_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Job Hunter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = "Your suggestions will appear here.";
  bool _isUploading = false;
  bool _isLoading = false;
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _resumeTextController = TextEditingController();

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
                child: Row(
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
                            await getPDFtext().then(
                              (value) => setState(
                                () {
                                  _resumeTextController.text = value;
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
                          labelText: 'Job Description',
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
                      constraints:
                          const BoxConstraints(minWidth: 250, maxWidth: 600),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        _counter,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(_resumeTextController.text);
          print(_jobDescriptionController.text);
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
      type: FileType.custom,
    ).whenComplete(() => setState(() => _isUploading = false));

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
}